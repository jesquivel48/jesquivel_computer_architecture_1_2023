import numpy as np
from PIL import Image
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

os.system("rm -f decrypt_img.o decrypt_img new_img.txt")
os.system("nasm -f elf64 -o decrypt_img.o decrypt_img.asm")
os.system("ld -o decrypt_img decrypt_img.o")
os.system("./decrypt_img")

encImg = str2byte("test.txt")
decImg = str2byte("new_img.txt")

imge = Image.frombytes('L', (encImg[1], encImg[2]), encImg[0])
imgd = Image.frombytes('L', (decImg[1], decImg[2]), decImg[0])



imge.show()
imgd.show()
