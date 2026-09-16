from PIL import Image

path = r"assets/images/Sherbeni Academy Logo-01 Horizontal.png"
im = Image.open(path)
im = im.convert("RGBA")
bbox = im.getbbox()

if bbox:
    im_cropped = im.crop(bbox)
    im_cropped.save(path)
    print(f"Image cropped successfully to {bbox}")
else:
    print("Image is completely transparent or couldn't be cropped.")
