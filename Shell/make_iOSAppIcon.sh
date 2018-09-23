#!/bin/bash

# 定义用到的变量
image_path=""

# 定义读取输入字符的函数
getImagePath() {
	echo -e "\n================================================"
	# 监听输入并且赋值给变量
	read -p "Enter origin image path: " image_path
	# 如果字符串的长度为零则为真为空值，从新监听，否则执行旋转函数
	if	test -z "$image_path"; then
		 getImagePath
	else
		# 如果文件存在且为目录则为真
		if test -d "$image_path"; then
			echo -e "\n------- [Error] the file path is directory --------"
			getImagePath
		else
			# 如果文件存在且可读则为真
			if test -r "$image_path"; then
				ext="\.jpeg|\.jpg|\.png|\.JPEG|\.JPG|\.PNG|\.gif|\.bmp"
				# get the images that need process.
				valid_img=$(echo "$image_path" | grep -E "${ext}")
				# 匹配到图片格式才处理
				if test -z "$valid_img"; then
					echo -e "\n------- [Error] the file is not's legal format --------"
					getImagePath
				else
					creatAppIcon	
				fi
			else			
				echo -e "\n------- [Error] the file path is not's find --------"
				getImagePath
			fi	
		fi
	fi
}

creatAppIcon() {
	echo -e "\n------- start processing -------"
	
	# 图片的上一级目录
	prev_path=$(dirname "$image_path")
	
	# 输出icon的目录
	icon_paht="${prev_path}/iOS_icon_`date +%Y%m%d_%H%M%S`"
	
	# 创建目录
	mkdir -p ${icon_paht}
	
	# 1024 icon 特别处理
	icon_1024_path="${icon_paht}/icon-1024.png"
	cp ${image_path} ${icon_1024_path}
	
	sips -s format png ${image_path} --out ${icon_1024_path} > /dev/null 2>&1
	[ $? -eq 0 ] && echo -e "info:\tresize copy 1024 successfully." || echo -e "info:\tresize copy 1024 failed."
	
	sips -z 1024 1024 ${icon_1024_path} > /dev/null 2>&1
	[ $? -eq 0 ] && echo -e "info:\tresize 1024 successfully." || echo -e "info:\tresize 1024 failed."
	
	prev_size_path=${icon_1024_path} #用于复制小图，减少内存消耗
	# 需要生成的图标尺寸
	icons=(180 167 152 120 87 80 76 60 58 40)
	for size in ${icons[@]}
	do
		size_path="${icon_paht}/icon-${size}.png"
		cp ${prev_size_path} ${size_path}
		prev_size_path=${size_path}
		sips -Z $size ${size_path} > /dev/null 2>&1
		[ $? -eq 0 ] && echo -e "info:\tresize ${size} successfully." || echo -e "info:\tresize ${size} failed."
	done
	
	# 转换1024图片为jpg，防止有透明区域导致上传 App Store 失败
	icon_1024_jpg_path="${icon_paht}/icon-1024.jpg"
	mv ${icon_1024_path} ${icon_1024_jpg_path}
	sips -s format jpeg ${icon_1024_jpg_path} --out ${icon_1024_jpg_path} > /dev/null 2>&1
	[ $? -eq 0 ] && echo -e "info:\tresize 1024 to jpg successfully." || echo -e "info:\tresize 1024 to jpg  failed."
	
	contents_json_path="${icon_paht}/Contents.json"
	# 生成图标对应的配置文件
	echo '{
		"images" : [
			{
				"size" : "20x20",
				"idiom" : "iphone",
				"filename" : "icon-40.png",
				"scale" : "2x"
			},
			{
				"size" : "20x20",
				"idiom" : "iphone",
				"filename" : "icon-60.png",
				"scale" : "3x"
			},
			{
				"size" : "29x29",
				"idiom" : "iphone",
				"filename" : "icon-58.png",
				"scale" : "2x"
			},
			{
				"size" : "29x29",
				"idiom" : "iphone",
				"filename" : "icon-87.png",
				"scale" : "3x"
			},
			{
				"size" : "40x40",
				"idiom" : "iphone",
				"filename" : "icon-80.png",
				"scale" : "2x"
			},
			{
				"size" : "40x40",
				"idiom" : "iphone",
				"filename" : "icon-120.png",
				"scale" : "3x"
			},
			{
				"size" : "60x60",
				"idiom" : "iphone",
				"filename" : "icon-120.png",
				"scale" : "2x"
			},
			{
				"size" : "60x60",
				"idiom" : "iphone",
				"filename" : "icon-180.png",
				"scale" : "3x"
			},
			{
				"idiom" : "ipad",
				"size" : "20x20",
				"scale" : "1x"
			},
			{
				"size" : "20x20",
				"idiom" : "ipad",
				"filename" : "icon-40.png",
				"scale" : "2x"
			},
			{
				"idiom" : "ipad",
				"size" : "29x29",
				"scale" : "1x"
			},
			{
				"size" : "29x29",
				"idiom" : "ipad",
				"filename" : "icon-58.png",
				"scale" : "2x"
			},
			{
				"idiom" : "ipad",
				"size" : "40x40",
				"scale" : "1x"
			},
			{
				"size" : "40x40",
				"idiom" : "ipad",
				"filename" : "icon-80.png",
				"scale" : "2x"
			},
			{
				"idiom" : "ipad",
				"size" : "76x76",
                "filename" : "icon-76.png",
				"scale" : "1x"
			},
			{
				"size" : "76x76",
				"idiom" : "ipad",
				"filename" : "icon-152.png",
				"scale" : "2x"
			},
			{
				"size" : "83.5x83.5",
				"idiom" : "ipad",
				"filename" : "icon-167.png",
				"scale" : "2x"
			},
			{
				"size" : "1024x1024",
				"idiom" : "ios-marketing",
				"filename" : "icon-1024.jpg",
				"scale" : "1x"
			}
		],
		"info" : {
			"version" : 1,
			"author" : "xcode"
		}
	}' > ${contents_json_path}
		
	echo -e "\n creat iOS AppIcon finished!"
	echo -e "\n------- end processing -------"
}


# 首先执行函数，填写1024图片的路径赋值
getImagePath


