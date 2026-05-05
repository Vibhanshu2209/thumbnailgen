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
    print("Contents availalbe for file")

    url = upload_file(
        file_bytes=contents,
        file_name=file.filename or "temp.png",
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
        thumbnails_for_job = session.exec(
            select(Thumbnail).where(Thumbnail.job_id == j.id)).all()

        thumbs_response = []
        for t in thumbnails_for_job:
            variants = get_variants(t.image_url) if t.image_url else None
            thumb_resp = ThumbnailResponse(
                id=t.id,
                style_name=t.style_name,
                status=t.status,
                created_at=t.created_at,
                error_message=t.error_message,
                image_url=t.image_url,
                variants=variants
            )
            thumbs_response.append(thumb_resp)

        job_resp = JobResponse(
            id=j.id,
            image_url=j.original_image_url,
            num_thumbnails=j.num_thumbnails,
            prompt=j.prompt,
            status=j.status,
            thumbnails=thumbs_response
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
            created_at=t.created_at,
            error_message=t.error_message,
            image_url=t.image_url,
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
        logger.info(f"Starting event stream for job {job_id}")
        # sent_thumbnails = set()
        while True:
            yield f"event: thumbnail READY \n Response: {json.dumps({'message': 'Thumbnail is ready!'})}\n\n"
        #     with Session(engine) as session:
        #         job = session.get(Job, job_id)
        #         if not job:
        #             logger.error(f"Job {job_id} not found in database")
        #             return
        #         logger.debug(f"Retrieved job {job_id} with status {job.status}")
                
        #         thumbnails = session.exec(
        #             select(Thumbnail).where(Thumbnail.job_id == job_id)
        #         ).all()
        #         logger.debug(f"Retrieved {len(thumbnails)} thumbnails for job {job_id}")

        #         for t in thumbnails:
        #             logger.info(f"Checking thumbnail {t.id} with status {t.status} for job {job_id}")
        #             if t.id in sent_thumbnails:
        #                 logger.debug(f"Thumbnail {t.id} already sent, skipping")
        #                 continue

        #             if t.status == "processed":
        #                 logger.info(f"Thumbnail {t.id} is processed, sending READY event")
        #                 variants = get_variants(t.image_url)
        #                 data = json.dumps({
        #                     "thumbnail_id" : t.id,
        #                     "style_name" : t.style_name,
        #                     "image_url": t.image_url,
        #                     "variants": variants
        #                 })

        #                 yield f"event: thumbnail READY \n Response: {data}"
        #                 sent_thumbnails.add(t.id)
        #                 logger.debug(f"Sent READY event for thumbnail {t.id}")

        #             elif t.status == "failed":
        #                 logger.warning(f"Thumbnail {t.id} failed with error: {t.error_message}")
        #                 variants = get_variants(t.image_url) if t.image_url else None
        #                 data = json.dumps({
        #                     "thumbnail_id" : t.id,
        #                     "style_name" : t.style_name,
        #                     "image_url": t.image_url,
        #                     "variants": variants
        #                 })

        #                 yield f"event: thumbnail FAILED \n Response: {data}"
        #                 sent_thumbnails.add(t.id)
        #                 logger.debug(f"Sent FAILED event for thumbnail {t.id}")
                    
        #             else:
        #                 logger.debug(f"Thumbnail {t.id} has status '{t.status}', still processing...")

        #         all_done = all(t.status in ("processed", "failed") for t in thumbnails)
        #         logger.debug(f"All done check for job {job_id}: {all_done} (sent: {len(sent_thumbnails)}/{len(thumbnails)})")
                
        #         if all_done and len(sent_thumbnails) == len(thumbnails):
        #             logger.info(f"All thumbnails processed for job {job_id}, sending job COMPLETED event")
        #             data = json.dumps({
        #                 "job_id": job_id,
        #                 "status": job.status
        #             })
        #             yield f"event: job COMPLETED \n Response: {data}"
        #             logger.info(f"Event stream completed for job {job_id}")
        #             return
                    
        #         logger.debug(f"Job {job_id} not complete, waiting before next check")
            await asyncio.sleep(5)        

    logger.info(f"Setting up event stream for job {job_id}")

    return StreamingResponse(
        content=event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no"
        }
    )
