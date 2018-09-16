#!/bin/bash

# 定义用到的变量
project_path=""

# 定义读取输入字符的函数
function getProjectPath() {
	# 输出换行，方便查看
	echo "================================================"
	# 监听输入并且赋值给变量
	read -p " Enter project path: " project_path
	# 如果为空值，从新监听
	if test -z "$project_path"; then
		getProjectPath
	else
		read_dir ${project_path}
	fi
}

function read_dir(){
	for file in `ls $1`       #注意此处这是两个反引号，表示运行系统命令
	do
		if [ -d $1"/"$file ]  #注意此处之间一定要加上空格，否则会报错
		then
			read_dir $1"/"$file
		else
			#在此处处理文件即可
			file_path="$1/$file"
			if `file ${file_path} | grep -q 'Mach-O'` ; then
				find_world=$(echo `nm -u ${file_path} | grep -E 'dlopen|method_exchangeImplementations|performSelector|respondsToSelector|dlsym'`)
				# -n 字符串	字符串的长度不为零则为真
				if [ -n "$find_world" ] ; then
					echo '-----------------------------\n'
					echo ${file_path}
					echo '包含字段：'
					echo ${find_world}
					echo '\n'
				fi
			fi
		fi
	done
}   


#读取第一个参数
getProjectPath

echo "------- end processing -------"


