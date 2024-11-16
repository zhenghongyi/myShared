import sys, os
from subprocess import call
def usage():
    """使用说明"""
    usage =\
"""
********************************************************************************
* $ python3 xcf.py folder scheme [custom_module]
*
* custom_module : 可选值, 用于scheme和导出包名不一致的情况
********************************************************************************
"""
    print(usage)

if __name__ == "__main__":
    args = sys.argv
    args_count = len(args)
    print("hello")
    if args_count < 2:
        usage()
        exit(0)
    else:
        PROJECT_DIR = args[1]
        if len(args) > 2:
            SCHEME = args[2]
        else:
            SCHEME = os.path.basename(PROJECT_DIR)
        if len(args) > 3:
            FRAMEWORK_NAME = args[3]
        else:
            FRAMEWORK_NAME = SCHEME
        # Type a script or drag a script file from your workspace to insert its path.
        # set framework folder name
        FRAMEWORK_FOLDER_NAME=".xcframework"
        #xcframework path
        FRAMEWORK_PATH="{PROJECT_DIR}/{FRAMEWORK_FOLDER_NAME}/{FRAMEWORK_NAME}.xcframework".format(PROJECT_DIR=PROJECT_DIR, FRAMEWORK_FOLDER_NAME=FRAMEWORK_FOLDER_NAME, FRAMEWORK_NAME=FRAMEWORK_NAME)
        # set path for iOS simulator archive
        SIMULATOR_ARCHIVE_PATH="{PROJECT_DIR}/{FRAMEWORK_FOLDER_NAME}/simulator.xcarchive".format(PROJECT_DIR=PROJECT_DIR, FRAMEWORK_FOLDER_NAME=FRAMEWORK_FOLDER_NAME)
        # set path for iOS device archive
        IOS_DEVICE_ARCHIVE_PATH="{PROJECT_DIR}/{FRAMEWORK_FOLDER_NAME}/iOS.xcarchive".format(PROJECT_DIR=PROJECT_DIR, FRAMEWORK_FOLDER_NAME=FRAMEWORK_FOLDER_NAME)
        cmd = '''
        cd {PROJECT_DIR}
        rm -rf "{PROJECT_DIR}/{FRAMEWORK_FOLDER_NAME}"
        echo "Deleted {FRAMEWORK_FOLDER_NAME}"
        mkdir "{FRAMEWORK_FOLDER_NAME}"
        echo "Archiving {FRAMEWORK_NAME}"
        xcodebuild archive -scheme {SCHEME} -destination="iOS Simulator" -archivePath "{SIMULATOR_ARCHIVE_PATH}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
        xcodebuild archive -scheme {SCHEME} -destination="iOS" -archivePath "{IOS_DEVICE_ARCHIVE_PATH}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
        #Creating XCFramework
        xcodebuild -create-xcframework -framework {SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/{FRAMEWORK_NAME}.framework -framework {IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/{FRAMEWORK_NAME}.framework -output "{FRAMEWORK_PATH}"
        rm -rf "{SIMULATOR_ARCHIVE_PATH}"
        rm -rf "{IOS_DEVICE_ARCHIVE_PATH}"
        open "{PROJECT_DIR}/{FRAMEWORK_FOLDER_NAME}"
        '''.format(PROJECT_DIR=PROJECT_DIR, FRAMEWORK_FOLDER_NAME=FRAMEWORK_FOLDER_NAME, SCHEME=SCHEME,
                    FRAMEWORK_NAME=FRAMEWORK_NAME, SIMULATOR_ARCHIVE_PATH=SIMULATOR_ARCHIVE_PATH, 
                    IOS_DEVICE_ARCHIVE_PATH=IOS_DEVICE_ARCHIVE_PATH, FRAMEWORK_PATH=FRAMEWORK_PATH)
        
        print(cmd)
        call(cmd, shell=True)
