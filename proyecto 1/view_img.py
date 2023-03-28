from PIL import Image, ImageFilter
import os

# Inserta cada byte en una lista y se transforma a bytes, devuelve el ancho y el largo de la imagen
def str2byte(textfile):
	width = 0
	height = 0

	with open(textfile, 'r') as f:
	    byte = f.read()
	    res = [int(n) for n in byte.split()]
	
	height = int(len(res)/640) 
	res = bytes(res)
	return [res, 640, height]

# Comandos de consola para llamar a la funcion de desencriptar imagenes en x86
os.system("rm -f decrypt_img.o decrypt_img dec_img.txt decrypt_image.png")
os.system("nasm -f elf64 -o decrypt_img.o decrypt_img.asm")
os.system("ld -o decrypt_img decrypt_img.o")
os.system("./decrypt_img")

# Se guardan los valores obtenidos en bytes
encImg = str2byte("enc_img.txt")
decImg = str2byte("dec_img.txt")

# Se crean las imagenes basadas en los bytes obtenidos
imge = Image.frombytes('L', (encImg[1], encImg[2]), encImg[0])
imgd = Image.frombytes('L', (decImg[1], decImg[2]), decImg[0])

# Crea un fondo
bg = Image.new("RGB", (encImg[1]+decImg[1], encImg[2]))
bg2 = Image.new("RGB", (decImg[1], decImg[2]))


# Inserta las figura en el fondo
bg.paste(imge, (0, 0))
bg.paste(imgd, (encImg[1], 0))
bg.paste(bg2, (decImg[1], decImg[2]))


# Guarda la imagen con el nombre decrypt_image
bg.save("decrypt_image.png", "PNG")
