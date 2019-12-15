#!/bin/bash

dir_path="$1"
file_type="$2"
out_path="$3"
	
#function copy_file_to_new_dir() {
#	for file in `ls "$1" | tr " " "{\?}"`      #| tr " " "{\?}" 为解决目录或文件名有空格导致 for in 分割问题
#	do	
#		file=`tr "{\?}" " " <<<$file` #还原替换的字符
#		path="$1/$file"
#		if [ -d "$path" ]  #注意此处之间一定要加上空格，否则会报错
#		then
#			copy_file_to_new_dir "$path"
#		else
#			filename=$(basename "$path") #获取文件名，包括后缀
#			extension="${filename##*.}" #获取文件后缀
##			filename1="${filename%.*}" #获取文件名，不包括后缀
#			if [ "$extension" = "$file_type" ] ; then
#				if [ -d "$out_path" ] ;  then
#					echo $path
#					cp "$path" "$out_path"
#				fi
#			fi
#		fi
#	done
#}   
#
#
##执行
#copy_file_to_new_dir $dir_path


##方法二：
#function copy_file_to_new_dir() {
#	for file in `ls $1`       #注意此处这是两个反引号，表示运行系统命令
#	do
#		if [ -d $1"/"$file ]  #注意此处之间一定要加上空格，否则会报错
#		then
#			copy_file_to_new_dir $1"/"$file
#		else
#			path="$1/$file"
#			filename=$(basename "$path") #获取文件名，包括后缀
#			extension="${filename##*.}" #获取文件后缀
#			#filename1="${filename%.*}" #获取文件名，不包括后缀
#			if [ "$extension" = "$file_type" ] ; then
#				if [ -d "$out_path" ] ;  then
#					echo $path
#					cp "$path" "$out_path"
#				fi
#			fi
#		fi
#	done
#}
#
# shell的域分隔符即(IFS)，默认是空格回车和tab，所以这里需要指定IFS，并在循环执行前解析。这里避免路径或文件有空格的情况
#OLDIFS="$IFS"
#IFS=$'\n'
#copy_file_to_new_dir $dir_path
#IFS="$OLDIFS"


###方法三：
function copy_file_to_new_dir() {
	find "$1" -type f -name "*.$file_type" | while read file
	do
		cp "$file" "$out_path"
	done
}


copy_file_to_new_dir $dir_path

exit 0