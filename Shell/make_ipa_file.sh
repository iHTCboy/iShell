#!/bin/bash

# 定义用到的变量
appPath=""
outputPath=""
projectName=""

# 定义读取输入字符的函数
getAppPath() {
	# 输出换行，方便查看
	echo "\n================================================"
	# 监听输入并且赋值给变量
	read -p " Enter .app path: " appPath
	# 如果为空值，从新监听
	if test -z "$appPath"; then
		getAppPath
	fi
}

getOutputPath() {
	# 输出换行，方便查看
	echo "\n================================================"
	# 监听输入并且赋值给变量
	read -p " Enter output path: " outputPath

	if test -z "$outputPath"; then
		# 如果没有输出路径，默认输出到桌面
	  outputPath="Desktop"
	fi
}

getProjectName() {
	# 输出换行，方便查看
	echo "\n================================================"
	# 监听输入并且赋值给变量
	read -p " Enter Project Name: " projectName

	if test -z "$projectName"; then
		getProjectName
	fi
}

# 执行函数，给变量赋值
getAppPath
getOutputPath
getProjectName

# 切换到当前用户的home目录，方便创建桌面目录
cd ~

# 在输出路径下创建 Payload 文件夹
mkdir -p "${outputPath}/Payload"

# 将.app 文件复制到 输出路径的 Payload 文件夹下
cp -r "${appPath}" "${outputPath}/Payload/"

# 切换到输出路径
cd "${outputPath}"

# 将 Payload 文件夹压缩成 ipa 包
zip -r "${projectName}.ipa" Payload

# 删除当前路径下 Payload 文件夹【-r 就是向下递归，不管有多少级目录，一并删除 -f 就是直接强行删除，不作任何提示的意思】
rm -rf "Payload"

# 成功提示
echo "\n\n=====================【转换ipa完成】=========================\n"

echo ${outputPath}
## 打开输出的路径
#open -a Finder "${outputPath}"
# 从当前位置打开finder
open .

# 结束退出
exit 0
