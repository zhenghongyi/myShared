import os, sys, shutil
import subprocess
from datetime import datetime
from biplist import *

"""
示例:
    $ python3 ChangeLog.py iOS项目文件夹 上次版本号tag'
"""

if __name__ == '__main__':
	argv = sys.argv
	if len(argv) < 2:
		print('请输入项目路径')
		sys.exit()
	elif len(argv) < 3:
		print('请输入上次版本号')
		sys.exit()

	projectDirPath = argv[1]
	pro_name = projectDirPath.split("/")[-1]

	os.chdir(projectDirPath)
	curPath = os.getcwd()

	lastTag = argv[2]

	infoPlistPath = os.path.join(curPath, pro_name + "/info.plist")
	if os.path.exists(infoPlistPath):
		try:
			dataDic = readPlist(infoPlistPath)
			newVersion = dataDic["CFBundleShortVersionString"] + "." + dataDic["CFBundleVersion"]
		except Exception as e:
		    print(e)

	url_sh = 'git remote get-url origin'
	result = subprocess.run(url_sh, capture_output=True, shell=True)
	remote_url = str(result.stdout, encoding="utf-8")
	if remote_url.startswith('git@') :
		temp = remote_url.split('@')[-1]
		remote_url = temp[0:-5]
		remote_url = "https://" + remote_url.replace(":", "/")

	# 1. git log 
	feat_sh = 'git log HEAD...{lastTag} --grep feat: --pretty=format:"%s([%h]({remoteUrl}/commits/%h))"'.format(lastTag=lastTag, remoteUrl=remote_url)
	result = subprocess.run(feat_sh, capture_output=True, shell=True)
	feat_log = str(result.stdout, encoding="utf-8").splitlines()

	fix_sh = 'git log HEAD...{lastTag} --grep fix: --pretty=format:"%s([%h]({remoteUrl}/commits/%h))"'.format(lastTag=lastTag, remoteUrl=remote_url)
	result = subprocess.run(fix_sh, capture_output=True, shell=True)
	fix_log = str(result.stdout, encoding="utf-8").splitlines()

	version_Log = "# {newVersion} ({nowDate})".format(newVersion=newVersion, nowDate=str(datetime.now().date()))

	if len(fix_log) > 0:
		version_Log += '\n\n\n' + "### Bug Fixes"
		for log in fix_log:
			version_Log += '\n' + '*' + log[4:]
	
	if len(feat_log) > 0:
		version_Log += '\n\n\n' + '### Features' + '\n'
		for log in feat_log:
			version_Log += '\n' + '*' + log[5:]

	# 2. add to CHANGELOG.md
	mdContent = version_Log + '\n\n\n' + open('CHANGELOG.md', 'r').read()
	with open('CHANGELOG.md', mode='w+') as file:
		file.write(mdContent)

