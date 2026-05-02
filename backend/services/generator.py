import asyncio
import logging
from typing import List

from sqlmodel import Session, select
from database import engine
from models import Job, Thumbnail
from services.openai_service import generate_image
from services.imagekit_service import upload_file

logger = logging.getLogger(__name__)

STYLES = {
    "bold_dramatic": "High-contrast chiaroscuro lighting, deep shadows, cinematic atmosphere, intense color grading, sharp focus, hyper-realistic textures, moody and powerful composition.",
    
    "clean_minimal": "Soft diffused natural lighting, monochromatic palette with subtle accents, plenty of negative space, sleek lines, studio photography, airy and uncluttered aesthetic, high-end product design feel.",
    
    "vibrant_energy": "Saturated neon colors, dynamic motion blur, explosive composition, high-shutter speed capture, glowing light trails, electric atmosphere, vivid and high-key lighting.",
}



async def generate_single_thumbnail(thumbnail_id: str, prompt: str, image_url: str):

    job_id = ""
    style = ""

    logger.info(f"Starting to generate thumbnails for {thumbnail_id = } ")

    with Session(engine) as session:
        thumbobj = session.get(Thumbnail, thumbnail_id)
        thumbobj.status = "generating"
        job_id = thumbobj.job_id
        style = thumbobj.style_name
        session.add(thumbobj)
        session.commit()


    logger.debug(f"{job_id = }")
    logger.debug(f"{style = }")

    style_prompt = STYLES[style]

    try:
        image_bytes = generate_image(prompt=prompt, style_prompt=style_prompt, reference_image_url=image_url)
        url = upload_file(file_bytes=image_bytes, file_name=f"{thumbnail_id}.png", folder_name=f"thumbnails/{job_id}/")
        with Session(engine) as session:
            thumbobj = session.get(Thumbnail, thumbnail_id)
            thumbobj.image_url = url
            thumbobj.status = "completed"
            session.add(thumbobj)
            session.commit()

        logger.info(f"Thumbnail {thumbnail_id} generated and uploaded successfully")

    except Exception as e:
        logger.error(f"Error generating thumbnails for {thumbnail_id = }")
        with Session(engine) as session:
            thumbobj = session.get(Thumbnail, thumbnail_id)
            thumbobj.status = "failed"
            thumbobj.error_message = str(e)[:500]
            session.add(thumbobj)
            session.commit()


async def process_job(job_id: str):

    prompt = ""
    thumbnails = []
    thumb_ids = []
    image_url: str = ""

    with Session(engine) as session:
        jobobj = session.get(Job, job_id)
        jobobj.status = "processing"
        prompt = jobobj.prompt
        image_url = jobobj.original_image_url

        thumbnails = session.exec(
            select(Thumbnail).where(Thumbnail.job_id == job_id)
        ).all()
        thumb_ids = [t.id for t in thumbnails]


    tasks = [
        generate_single_thumbnail(t_id, prompt=prompt, image_url=image_url)
        for t_id in thumb_ids
    ]
    await asyncio.gather(*tasks, return_exceptions=True)

    with Session(engine) as session:
        thumbnails = session.exec(
            select(Thumbnail).where(Thumbnail.job_id == job_id)
        ).all()

        any_failed = any(t.status == "failed" for t in thumbnails)
        job = session.get(Job, job_id)
        job.status = "failed" if any_failed else "completed"

        session.add(job)
        session.commit()
        

