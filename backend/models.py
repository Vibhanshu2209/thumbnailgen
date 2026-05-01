from datetime import datetime, timezone
from typing import Optional, List
from uuid import uuid4


from sqlmodel import Field, Relationship, SQLModel

def _uuid() -> str:
    return str(uuid4())


def _now() -> datetime:
    return datetime.now(timezone.utc)


class Thumbnail(SQLModel, table=True): # if table=false or not given, it works only as a pydantic model
    id: str = Field(default_factory=_uuid, primary_key=True)

    job_id: str = Field(foreign_key="job.id")
    style_name: str = Field(default="")
    status: str = Field(default="not started")
    created_at: datetime = Field(default_factory=_now)
    error_message: Optional[str] = Field(default=None)


    job: Optional["Job"] = Relationship(back_populates="thumbnails")
    """
    here, job is optional, but if given, it will be a Job object
    this is a forward reference
    """


class Job(SQLModel, table=True):

    id: str = Field(default_factory=_uuid, primary_key=True)
    prompt: str = Field(default="")
    num_thumbnails: int = Field(default=1, gt=0, lt=4)
    headshot_url: str = Field(default="")
    status: str = Field(default="not started")
    created_at: datetime = Field(default_factory=_now)

    thumbnails: List[Thumbnail] = Relationship(back_populates="job")
    """
    current understanding:
    if we write job1 = Job(...) and then j.thumbnails, it will give the list of thumbnail objects 
    where "job" relates to the job1 and then from any item in the thumbnail object list, we can come back to the job1
    """

    

