import cv2
import numpy as np 

img = cv2.imread("p1Win.png")
file1 = open("p1Win.txt", "r+")
print(img.shape)
for i in range(0,73):
	for j in range(0,174):
		for k in range(0,3):
			L = ["image1(", str(i),",", str(j),",", str(k), ") <= ",str(img[i][j][k]),";\n"]
			file1.writelines(L) 	

file1.close()		
