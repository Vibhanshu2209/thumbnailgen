from imagekitio import ImageKit, ImageKitError

from config import IMAGEKIT_PRIVATE_KEY, TR_SHORTS, TR_SQUARE, TR_YOUTUBE


imagekit = ImageKit(
    private_key=IMAGEKIT_PRIVATE_KEY
)


def upload_file(file_bytes: bytes, file_name: str, folder_name: str, content_type: str = "image/png") -> str:

    """
    Upload the image to imagekit and return the CDN url
    """

    response = imagekit.files.upload(
        file=(file_name, file_bytes, content_type),
        file_name=file_name,
        folder=folder_name,
        is_private_file=False,
        use_unique_file_name=True
    )

    return response.url


def get_variants(base_url: str) -> dict:
    """
        Return 3 sizes variant URLs of the image
    """
    return {
        "youtube":f"{base_url}{TR_YOUTUBE}",
        "shorts": f"{base_url}{TR_SHORTS}",
        "square": f"{base_url}{TR_SQUARE}"
    }

