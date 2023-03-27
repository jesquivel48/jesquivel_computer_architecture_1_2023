import numpy as np
from PIL import Image, ImageFilter
import os

def str2byte(textfile):
	width = 0
	height = 0
	res = b''
	tempstring = ''
	with open(textfile, 'rt') as f:
		byte = f.read()
		for element in byte:
			if element == ' ':
				res += (int(tempstring)).to_bytes(1, 'big')
				tempstring = ""
				width += 1
			else:
				tempstring += element
			if width == 640:
				height += 1
				width = 0
		return [res, 640, height]

os.system("rm -f decrypt_img.o decrypt_img new_img.txt decrypt_image.png")
os.system("nasm -f elf64 -o decrypt_img.o decrypt_img.asm")
os.system("ld -o decrypt_img decrypt_img.o")
os.system("./decrypt_img")

encImg = str2byte("enc_img.txt")
decImg = str2byte("dec_img.txt")

imge = Image.frombytes('L', (encImg[1], encImg[2]), encImg[0])
imgd = Image.frombytes('L', (decImg[1], decImg[2]), decImg[0])

bg = Image.new("RGBA", (1280, 960))
bg2 = Image.new("RGBA", (640, 480))



bg.paste(imge, (0, 0))
bg.paste(imgd, (640, 0))
bg.paste(bg2, (640, 480))

bg.save("decrypt_image.png", "PNG")
