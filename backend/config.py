import os
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "empty")
OPENAI_MODEL = os.getenv("MODEL", "gpt-4o")
OPENAI_IMAGE_MODEL = os.getenv("MODEL", "gpt-4o")
IMAGEKIT_PRIVATE_KEY = os.getenv("IMAGEKIT_PRIVATE_KEY", "empty")
IMAGEKIT_PUBLIC_KEY = os.getenv("IMAGEKIT_PUBLIC_KEY", "empty")
IMAGEKIT_URL_ENDPOINT = os.getenv("IMAGEKIT_URL_ENDPOINT", "empty")

TR_YOUTUBE = os.getenv("TR_YOUTUBE","?tr=w-1280,h-720,c-maintain_ratio,fo-auto")
TR_SHORTS = os.getenv("TR_SHORTS", "?tr=w-1080,h-1920,c-maintain_ratio,fo-auto")
TR_SQUARE = os.getenv("TR_SQUARE", "?tr=w-1080,h-1080,c-maintain_ratio,fo-auto")

DB_URL = "sqlite:///./thumbnailbuilder.db"
