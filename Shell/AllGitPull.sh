#!/bin/bash

# 定义用到的变量
directory_path=""

# 定义读取输入字符的函数
function getDirectoryPath() {
	# 输出换行，方便查看
	echo "================================================"
	# 监听输入并且赋值给变量
	read -p " Enter directory path: " directory_path
	# 如果为空值，从新监听
	if test -z "directory_path"; then
		getDirectoryPath
	else
		read_dir ${directory_path}
	fi
}

function read_dir(){
	for file in `ls $1`       #注意此处这是两个反引号，表示运行系统命令
	do
		if [ -d $1"/"$file ]  #注意此处之间一定要加上空格，否则会报错
		then
			#在此处处理目录即可
			echo "-----------------------------\n"
			echo "check directory:《" $file "》"
			echo "message:"
			cd $1"/"$file
			git pull
			echo "\n"
		fi
	done
}   


#读取第一个参数
getDirectoryPath

echo "\n------- finish processing -------"


