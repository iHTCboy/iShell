#!/bin/bash


# 定义用到的变量
ExecutableFilePath=""

# 定义读取输入字符的函数
getExecutableFilePath() {
	# 输出换行，方便查看
	echo "================================================"
	# 监听输入并且赋值给变量
	read -p " Enter Mach-O executable file path: " ExecutableFilePath
	# 如果为空值，从新监听
	if test -z "$ExecutableFilePath"; then
		echo "Error! Should enter file path "
		getExecutableFilePath
	fi
}

getExecutableFilePath

echo "Place enter the number select minimum supported system version for the app? [ 1:gt iOS9 2:lt iOS7 3:iOS7.X~8.X] "

read number
while([[ $number != 1 ]] && [[ $number != 2 ]] && [[ $number != 3 ]])
do
echo "Error! Should enter 1 or 2 or 3"
echo "Place enter the number you want to export ? [ 1:app-store 2:ad-hoc 3:dev] "
read number
done


if [ $number != 3 ];then
	app_size=$(echo `size ${ExecutableFilePath} | awk '{print $1}' | grep -E '[0-9]' | awk '{sum += $1}; END {print sum/1000/1000}'`)
	echo 'executable file size:' ${app_size} 'MB'
	if [ $number == 1 ];then
		#iOS 9.0 或更高版本    500 MB    针对二进制文件中所有“__TEXT”部分的总和。
		#因为bc和awk都支持浮点数，可以使用bc进行处理：
		if [ `echo "$app_size > 500" | bc` -eq 1 ];then
			echo '❌ [Error]' ${app_size} 'MB，' '不符合苹果 iOS9 小于 500 MB 的要求！'
		else
			echo '⭕️ [Success]' ${app_size} 'MB，' '符合苹果 iOS9 小于 500 MB 的要求！'
		fi
	else
		#低于 iOS 7.0         80 MB     针对二进制文件中所有“__TEXT”部分的总和。
		if [ `echo "$app_size > 80" | bc` -eq 1 ];then
			echo '❌ [Error]' ${app_size} 'MB，' '不符合苹果 iOS7 小于 80 MB 的要求！'
		else
			echo '⭕️ [Success]' ${app_size} 'MB，' '符合苹果 iOS7 小于 80 MB 的要求！'
		fi
	fi
else
	app_size=$(echo `size "$ExecutableFilePath" | awk '{print $1 "," $10}' | tail -n +2`)
	# iOS 7.X 至 iOS 8.X 每个架构最大为 60 MB
	# echo $app_size 
	# 53329920,armv7) 57475072,arm64)
	arch_arr=(`echo $app_size | tr ' ' ' '`) 
	for each in ${arch_arr[@]}
	do
		size=`echo $each | awk -F',' '{print $1}' | awk '{sum += $1}; END {print sum/1000/1000}'`
		arch=`echo $each | awk -F',' '{print $2}'`
		# echo ${arch/%)/}  # 如果字符串arch以)结尾，则用空替换它
		echo ${arch/%)/} 'executable file size:' ${size} 'MB'
		if [ `echo "$size > 60" | bc` -eq 1 ];then
			echo '❌ [Error]' ${arch/%)/} 'size:' ${size} 'MB，' '不符合苹果 iOS 7.X 至 iOS 8.X 每个架构最大为 60 MB 的要求！'
		else
			echo '⭕️ [Success]' ${arch/%)/} 'size:' ${size} 'MB，' '符合苹果 iOS 7.X 至 iOS 8.X 每个架构最大为 60 MB 的要求！'
		fi
	done
fi


