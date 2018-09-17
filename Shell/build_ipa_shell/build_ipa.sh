
#获取脚本执行目录
scrip_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#工程绝对路径
project_path=$(dirname "$scrip_path")

#工程名 将XXX替换成自己的工程名
project_name=BuildIPAExample

#scheme名 将XXX替换成自己的sheme名
scheme_name=BuildIPAExample

#project_type 项目如果是用cocoapod，就改为 xcworkspace，否则用 xcodeproj
project_type=xcodeproj

#打包模式 Debug/Release
development_mode=Debug

#build文件夹路径
build_path=${project_path}/build

#plist文件所在路径
exportOptionsPlistPath=${project_path}/build_ipa_shell/ExportOptions-dev.plist


echo "Place enter the number you want to export ? [ 1:app-store 2:ad-hoc 3:dev] "

read number
while([[ $number != 1 ]] && [[ $number != 2 ]] && [[ $number != 3 ]])
do
echo "Error! Should enter 1 or 2 or 3"
echo "Place enter the number you want to export ? [ 1:app-store 2:ad-hoc 3:dev] "
read number
done

if [ $number == 1 ];then
	development_mode=Release
	exportOptionsPlistPath=${project_path}/build_ipa_shell/ExportOptions-appstore.plist

elif [ $number == 2 ];then
	development_mode=Release
	exportOptionsPlistPath=${project_path}/build_ipa_shell/ExportOptions-adhoc.plist
else
	development_mode=Debug
	exportOptionsPlistPath=${project_path}/build_ipa_shell/ExportOptions-dev.plist
fi

#导出.ipa文件所在路径
exportIpaPath=${project_path}/ipa_files/${development_mode}

# 生成保存ipa文件的目录
if [ ! -d ${project_path}/ipa_files ];
then
mkdir -p ${project_path}/ipa_files;
fi

# 打包类型
if [ $project_type == "xcodeproj" ];
then
	project_build=project
else
	project_build=workspace
fi


# 进入项目目录，方便后面的操作
cd ${project_path}



echo '///-----------'
echo '/// 正在清理工程'
echo '///-----------'
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit


echo '///--------'
echo '/// 清理完成'
echo '///--------'
echo ''

echo '///-----------'
echo '/// 正在编译工程:'${development_mode}
echo '///-----------'
xcodebuild \
archive -${project_build} ${project_path}/${project_name}.${project_type} \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit

echo '///--------'
echo '/// 编译完成'
echo '///--------'
echo ''

echo '///----------'
echo '/// 开始ipa打包'
echo '///----------'
xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

if [ -e $exportIpaPath/$scheme_name.ipa ]; then
echo '///----------'
echo '/// ipa包已导出'
echo '///----------'
open $exportIpaPath
else
echo '///-------------'
echo '/// ipa包导出失败 '
echo '///-------------'
fi
echo '///------------'
echo '/// 打包ipa完成  '
echo '///-----------='
echo ''

# 打开生成ipa的目录
open ${exportIpaPath}

# echo '///-------------'
# echo '/// 开始发布ipa包 '
# echo '///-------------'

# if [ $number == 1 ];then

# #验证并上传到App Store
# # 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
# altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
# "$altoolPath" --validate-app -f ${exportIpaPath}/${scheme_name}.ipa -u XXX -p XXX -t ios --output-format xml
# "$altoolPath" --upload-app -f ${exportIpaPath}/${scheme_name}.ipa -u  XXX -p XXX -t ios --output-format xml
# else

# #上传到Fir
# # 将XXX替换成自己的Fir平台的token
# fir login -T XXX
# fir publish $exportIpaPath/$scheme_name.ipa

# fi

exit 0


