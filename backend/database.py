from sqlmodel import SQLModel, create_engine, Session
from config import DB_URL

engine = create_engine(DB_URL, echo=True,
                       connect_args={"check_same_thread": False}
                       # sqlite limitation, not needed for postgres etc.
                       )


def create_tables():
    """
    It is called by async context manager and create all the tables using the models
    which inherits SQLModel and given table=true
    example: class Thumbnail(SQLModel, table=True)
    """
    SQLModel.metadata.create_all(engine)



def get_session():
    with Session(engine) as session:
        yield session