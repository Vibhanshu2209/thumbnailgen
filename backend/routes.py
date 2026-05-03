import json
import logging
import os
import random
import asyncio

from fastapi import APIRouter, HTTPException, UploadFile, Depends, File
from fastapi.responses import StreamingResponse
from sqlmodel import Session, select
from database import get_session, engine


from schemas.models import CreateJobRequest, JobResponse, Thumbnail, Job, CreateJobResponse, ThumbnailResponse
from services import *

logger = logging.getLogger(__name__)


router = APIRouter(prefix="/api")


@router.post("/upload-image")
async def upload_reference_image(file: UploadFile = File(...)):
    contents = await file.read()

    url = upload_file(
        file_bytes=contents,
        file_name=f"{file.filename}" or "temp.png",
        folder_name="reference_images",
        content_type=file.content_type or "content/png"
    )

    return {"url": url}


@router.post("/jobs", response_model=CreateJobResponse)
async def create_job(request: CreateJobRequest, session: Session = Depends(get_session)):
    if request.num_thumbnails < 1 or request.num_thumbnails > 3:
        raise HTTPException(
            status_code=400, detail="number of thumbnails must be between 1 and 3")

    job = Job(
        prompt=request.prompt,
        num_thumbnails=request.num_thumbnails,
        original_image_url=request.original_image_url
    )
    session.add(job)

    i = list(STYLES.keys())[random.randint(0, len(STYLES.keys())-1)]
    style = STYLES[request.style] if request.style != None else STYLES[i]

    thumb = Thumbnail(job_id=job.id, style_name=style)
    session.add(thumb)

    session.commit()

    asyncio.create_task(process_job(job.id))

    return CreateJobResponse(job_id=job.id, style=style)


@router.get("/jobs", response_model=list[JobResponse])
async def list_jobs(session: Session = Depends(get_session)):
    all_jobs = session.exec(
        select(Job)
    ).all()

    if not all_jobs:
        raise HTTPException(404, "No Data Found, job list empty")

    jobs_response = []
    for j in all_jobs:
        job_resp = JobResponse(
            id=j.id,
            image_url=j.original_image_url,
            num_thumbnails=j.num_thumbnails,
            prompt=j.prompt,
            status=j.status
        )
        jobs_response.append(job_resp)

    return jobs_response


@router.get("/jobs/{job_id}", response_model=JobResponse)
async def get_job(job_id: str, session: Session = Depends(get_session)):
    job = session.get(Job, job_id)
    if not job:
        raise HTTPException(404, f"Job {job_id} not found")

    thumbnails_for_job = session.exec(
        select(Thumbnail).where(Thumbnail.job_id == job_id)).all()

    thumbs_response = []
    for t in thumbnails_for_job:
        variants = get_variants(t.image_url) if t.image_url else None
        thumb_resp = ThumbnailResponse(
            id=t.id,
            style_name=t.style_name,
            status=t.status,
            error_message=t.error_message,
            variants=variants
        )
        thumbs_response.append(thumb_resp)

    job_response = JobResponse(
        id=job_id,
        prompt=job.prompt,
        image_url=job.original_image_url,
        status=job.status,
        thumbnails=thumbs_response,
        num_thumbnails=job.num_thumbnails
    )

    return job_response


@router.get("/jobs/{job_id}/stream")
async def stream_job(job_id: str):

    async def event_generator():
        sent_thumbnails = set()
        while True:
            with Session(engine) as session:
                job = session.get(Job, job_id)
                if not job:
                    yield f"event: error\n data: {json.dumps({"error", "Job not found"})}"
                    return
                thumbnails = session.exec(
                    select(Thumbnail).where(Thumbnail.job_id == job_id)
                ).all()


                for t in thumbnails:
                    if t.id in sent_thumbnails: continue

                    if t.status == "processed":
                        variants = get_variants(t.image_url)
                        data = json.dumps({
                            "thumbnail_id" : t.id,
                            "style_name" : t.style_name,
                            "image_url": t.image_url,
                            "variants": variants
                        })

                        yield f"event: thumbnail READY \n Response: {data}"
                        sent_thumbnails.add(t.id)

                    elif t.status == "failed":
                        data = json.dumps({
                            "thumbnail_id" : t.id,
                            "style_name" : t.style_name,
                            "image_url": t.image_url,
                            "variants": variants
                        })

                        yield f"event: thumbnail FAILED \n Response: {data}"
                        sent_thumbnails.add(t.id)

                    all_done = all(t.status in ("completed", "failed") for t in thumbnails)
                    if all_done and len(sent_thumbnails) == len(thumbnails):
                        data = json.dumps({
                            "job_id": job_id,
                            "status": job.status
                        })
                        yield f"event: job COMPLETED \n Response: {data}"
                        return
                    
            await asyncio.sleep(5)        



    return StreamingResponse(
        content=event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no"
        }
    )
