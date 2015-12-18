import argparse
import os
import io
import math
import array
import struct
import png
import sys
from PIL import Image

HEADER_SIZE = 4 
BLOCK_SIZE = 4

parser = argparse.ArgumentParser(description="Convert binary file to PNG visualisation.")
parser.add_argument("inputPath", help="Path to be processed.")
parser.add_argument('--decode', action='store_true', help="Pass this to decode the image into a binary")

args = parser.parse_args()
inputPath = args.inputPath
outputPath = args.inputPath + ".png"

if args.decode:
	file = open(inputPath, 'r+b') # Open file in read binary mode
	outputFile = open(outputPath, 'wb')
	
	pngFile = png.Reader(file)
	
	pixels = pngFile.read_flat()[2]
	originalFileSize = struct.unpack('>I', pixels[0:HEADER_SIZE])[0]
	binaryArray = pixels[HEADER_SIZE:originalFileSize+HEADER_SIZE]
	outputFile.write(binaryArray)
	outputFile.close
else:
	fileSize = os.stat(inputPath).st_size # File size in bytes
	fileSizeWithHeader = fileSize + HEADER_SIZE
	paddedTotalFileSize = int(math.ceil(float(fileSizeWithHeader) / float(BLOCK_SIZE))) # In blocks
	squareSize = int(math.ceil(math.sqrt(paddedTotalFileSize)))
	
	file = open(inputPath, 'r+b') # Open file in read binary mode
	outputFile = open(outputPath, 'wb')
	
	imageArray = []
	print("Starting encoding...")
	for i in range(0, squareSize):
		rowArray = []
		for j in range(0, squareSize * BLOCK_SIZE):
			rawIndex = i * squareSize * BLOCK_SIZE + j
			if (rawIndex < 4):
				headerBytes = struct.unpack('4B', struct.pack('>I', fileSize))
				rowArray.append(headerBytes[rawIndex])
			elif (rawIndex < fileSizeWithHeader):
				byte = file.read(1)
				byteInt = byte[0]
				rowArray.append(byteInt)
			else:
				rowArray.append(0)
		imageArray.append(rowArray)
		sys.stdout.write(str(math.ceil((float(i) / squareSize) * 100)) + "% done\r")
		sys.stdout.flush()
	sys.stdout.write("Done.")

	pngWriter = png.Writer(
		width = squareSize,
		height = squareSize,
		alpha = True
	)
	pngWriter.write(outputFile, imageArray)
	outputFile.close()
	
	print("Generating thumbnail...")
	image = Image.open(outputPath)
	thumbnail = image.resize((500,500),Image.NEAREST)
	thumbnail.save(outputPath + ".thumb.png")
	print("Done.")