# -*- coding: utf-8 -*-
from __future__ import division
import Image,os,json,re,RGB2hex


def traverse():
	filesPath_list= []
	files_path= []
	dir = raw_input('please input the path:')
	for root, dirs, files in os.walk(dir):
		for name in files:
			if name[-3:]=='png' and 'position' in name:
				filesPath_list.append(root)
				files_path.append(root+'/'+name)
	return filesPath_list,files_path

if __name__ =="__main__":
	picpath_list,pic_path = traverse()
	print picpath_list,pic_path
	for path in pic_path:
		pixel_array2= []
		min_x = []
		max_x = []
		min_y = []
		max_y = []
		json_print ='{"rect":['
		pixel_array = []
		im = Image.open(path)
		pixel = im.getcolors(maxcolors=256)
		size = im.size
		for i in range(len(pixel)):
			pixel_array.append(pixel[i][1])
		for pixel in pixel_array:
			Coordinate_array = []
			if pixel[3]!=0:
				pixel_array2.append(pixel)
				for lenth in range(size[0]):
					for width in range(size[1]):
						if im.getpixel((lenth,width)) == pixel:
							Coordinate_array.append((lenth,width))
				newX_Coordinate = Coordinate_array[0][0]
				newX_Coordinate2 = int(Coordinate_array[len(Coordinate_array)-1][0])+1
				newY_Coordinate = Coordinate_array[0][1]
				newY_Coordinate2 = int(Coordinate_array[len(Coordinate_array)-1][1])+1
				print pixel
				min_x.append('%.3f'%(newX_Coordinate/size[0]))
				max_x.append('%.3f'%(newX_Coordinate2/size[0]))
				min_y.append('%.3f'%(newY_Coordinate/size[1]))
				max_y.append('%.3f'%(newY_Coordinate2/size[1]))		
		for i in range(len(min_x)):
			print pixel_array2[i]
			if i==(len(min_x)-1):
				json_print = json_print+'{"id":'+'"'+hex(RGB2hex.rgb2hex(pixel_array2[i][0:3]))+'"'+','+'"min_x":'+min_x[i]+','+'"max_x":'+max_x[i]+','+'"min_y":'+min_y[i]+','+'"max_y":'+max_y[i]+'}]}'
			else:
				json_print = json_print+'{"id":'+'"'+hex(RGB2hex.rgb2hex(pixel_array2[i][0:3]))+'"'+','+'"min_x":'+min_x[i]+','+'"max_x":'+max_x[i]+','+'"min_y":'+min_y[i]+','+'"max_y":'+max_y[i]+'},'
	
		file_object = open(path[:-3]+'json', 'w')
		file_object.write(json_print)
		file_object.close()



