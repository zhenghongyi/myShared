#!usr/bin/env python3
# coding: utf-8

import sys,os,shutil,zipfile
from settings import Settings
from jsonParser import JSONParser
from myConfigParser import MyConfigParser
from datetime import datetime
import json
from util import replace
from plistlib import load
import smbfile

def usage():
    """使用说明"""
    usage = """\
    * $ python3 sdkHandler.py <project folder> <command> [option]
    <project folder> 项目文件夹
    <command> 指定命令
    option: 指定参数

    示例:
    # 更新到指定配置 -update 缩写 -u
    python3 sdkHandler.py /Users/xxx/Documents/Projects/LKMailSDK -update icbc

    # 使用xcframework方式打包 -archive 缩写 -a
    python3 sdkHandler.py /Users/xxx/Documents/Projects/LKMailSDK -archive xcframework

    # 使用framework方式打包 -archive 缩写 -a
    python3 sdkHandler.py /Users/xxx/Documents/Projects/LKMailSDK -archive framework
    """
    print(usage)

class SDKHandler(object):

    def __init__(self, sdkPath):
        self.sdkPath = sdkPath
        plist_path = os.path.join(self.sdkPath, 'LKMailSDK', 'Info.plist')
        with open(plist_path, 'rb') as fp:
            plist_dic = load(fp)
        
        self.market_version = plist_dic['CFBundleShortVersionString']
        self.build_version = plist_dic['CFBundleVersion']
    
    def update(self, target):
        self.target = target
        self.jsonParser = JSONParser()
        self.config = MyConfigParser()

        iniPath = os.getcwd()  + "/Input/" + target + "/settings.ini"
        if os.path.exists(iniPath):
            self.config.read(iniPath)

        self.update_hxphone_folder()
        self.update_version()
    
    def update_version(self):
        os.chdir('%s'% self.sdkPath)
        self.market_version = self.config.get('public', 'version')
        self.build_version = self.config.get('public', 'build')

        os.system('xcrun agvtool new-marketing-version %s'%(self.market_version))
        os.system('xcrun agvtool new-version -all %s'%(self.build_version))

    def update_hxphone_folder(self):
        remote_path = self.config.get('hxphone', 'hxphone_path')
        file_name = remote_path.split("/")[-1]
        # 远程访问需要先处理带括号的路径
        remote_path = remote_path.replace("(", "\(")
        remote_path = remote_path.replace(")", "\)")
        smbfile.download_file(remote_path)
        
        file_path = os.path.join(os.getcwd(), file_name)
        hxphone_path = os.path.join(os.getcwd(), "hxphone")
        zf = zipfile.ZipFile(file_path)
        try:
            zf.extractall(path=hxphone_path)
        except RuntimeError as e:
            print(e)
        zf.close()

        self.update_cmbrokerjs_file(hxphone_path)

        os.remove(file_path)
        local_path = self.sdkPath + "/LKMailSDK"
        # os.remove(local_path)
        shutil.rmtree(os.path.join(local_path, 'hxphone'))
        shutil.move(hxphone_path, local_path)
        pass

    def update_cmbrokerjs_file(self,  hxphone_path):
        os.rename(os.path.join(hxphone_path, 'static/js/cm_broker.sample.js'), os.path.join(hxphone_path, 'static/js/cm_broker.js'))
        cmbrokerjs_path = os.path.join(hxphone_path, 'static/js/cm_broker.js')
        # 替换内容
        old_content = """
window.CM_BROKER = {
"""
        new_content = """
window.CM_BROKER = {
    handleInvalidSession: function() {
       window.webkit.messageHandlers.handleInvalidSession.postMessage(null)
    },
    handleSyncSchedule: function () {
       window.webkit.messageHandlers.syncSchedule.postMessage(null)
    }
"""
        _ = replace(file=cmbrokerjs_path, old=old_content, new=new_content)
        pass

    def archive_xcframework(self):
        buildTarget = os.path.basename(self.sdkPath)
        
        curpath = os.path.abspath('.')

        os.chdir('%s'% self.sdkPath)

        # 编译
        os.system('xcodebuild -configuration Release -scheme %s -sdk iphonesimulator -derivedDataPath %s/Product clean build'%(buildTarget,curpath))
        os.system('xcodebuild -configuration Release -scheme %s -sdk iphoneos -derivedDataPath %s/Product build'%(buildTarget,curpath))

        os.system('xcodebuild -create-xcframework \
        -framework %s/Product/Build/Products/Release-iphoneos/%s.framework \
        -framework %s/Product/Build/Products/Release-iphonesimulator/%s.framework \
        -output    %s/Output/LKMailSDK.xcframework'%(curpath,buildTarget,curpath,buildTarget,curpath))
        # 压缩
        result_dir_path = os.path.join(curpath, 'Output/LKMailSDK.xcframework')
        os.chdir(curpath)
        zipname = self.zip_framework(result_dir_path, True)
        shutil.rmtree(result_dir_path)
        shutil.rmtree(os.path.join(curpath, 'Product'))
        os.system('open %s' % os.path.join(curpath, 'Output'))
        print("%s 打包成功"%zipname)
    
    def archive_framwork(self):
        buildTarget = os.path.basename(self.sdkPath)
        
        curpath = os.getcwd()

        os.chdir(self.sdkPath)

        # xcode build
        os.system('xcodebuild clean')
        os.system('xcodebuild -project LKMailSDK.xcodeproj -configuration "Release" -target LKMailSDK -sdk iphoneos')
        os.system('xcodebuild -project LKMailSDK.xcodeproj -configuration "Release" -target LKMailSDK -sdk iphonesimulator')
        # path
        simulator_path = os.path.join(os.getcwd(), 'build/Release-iphonesimulator/LKMailSDK.framework/LKMailSDK')
        iphoneos_path = os.path.join(os.getcwd(), 'build/Release-iphoneos/LKMailSDK.framework/LKMailSDK')
        product_path = os.path.join(os.getcwd(), 'build/LKMailSDK.framework')
        # 移除重复架构
        os.system('lipo %s -remove arm64 -output %s' % (simulator_path, simulator_path))
        # 复制其一到结果路径下
        shutil.copytree(os.path.join(os.getcwd(), 'build/Release-iphoneos/LKMailSDK.framework'), product_path)
        # 合并生成（直接凭空对两个进行合并，会只生成一个framework文件，而不是文件夹）
        os.system('lipo -create %s %s -output %s'%(simulator_path, iphoneos_path, os.path.join(product_path, 'LKMailSDK')))
        shutil.move(product_path, os.path.join(curpath, 'Output'))
        shutil.rmtree(os.path.join(os.getcwd(), 'build/'))
        # 压缩
        result_dir_path = os.path.join(curpath, 'Output/LKMailSDK.framework')
        os.chdir(curpath)
        zipname = self.zip_framework(result_dir_path)
        shutil.rmtree(result_dir_path)
        os.system('open %s' % os.path.join(curpath, 'Output'))
        print("%s 打包成功"%zipname)

    def zip_framework(self, dirpath, xc=False):
        def generate_product_name(xc):
            arcname = 'framework' if xc==False else 'xcframework'
            timeStr = datetime.now().strftime("%Y%m%d%H%M%S")
            if self.market_version is None or self.market_version=='$(MARKETING_VERSION)' or self.build_version=='$(CURRENT_PROJECT_VERSION)':
                return 'LKMailSDK_%s.%s.zip'%(timeStr, arcname)
            return 'LKMailSDK_v%s.%s_%s.%s.zip'%(self.market_version, self.build_version, timeStr, arcname)

        zipname = generate_product_name(xc)
        zip_path = os.path.join(os.getcwd(), 'Output', zipname)
        zip = zipfile.ZipFile(zip_path, 'w', zipfile.zlib.DEFLATED)
        os.chdir(dirpath) # 进入目标文件夹开始遍历
        for root, dirs, files in os.walk('.'):
            for file in files:
                full_path = os.path.join(root, file)
                zip.write(full_path)
        zip.close()
        return zipname


if __name__ == '__main__':
    args = sys.argv
    deploy_name = None
    args_count = len(args)
    if args_count < 3:
        usage()
        exit(0)
    
    sdkPath = args[1]
    handler = SDKHandler(sdkPath)
    command = args[2]
    option = args[3]
    if command == '-update' or command == '-u':
        handler.update(option)
    elif command == '-archive' or command == '-a':
        if option == 'framework':
            handler.archive_framwork()
        elif option == 'xcframework':
            handler.archive_xcframework()
        else:
            usage()
    else:
        usage()
