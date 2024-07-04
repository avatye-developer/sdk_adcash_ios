#!/bin/bash
YELLOW='\033[1;33m'
NC='\033[0m'
SIGNING_CERTIFICATE='UGVSN5Z6SK'
SCHEME_NAME="AdCashFramework"

# build
SPEC_VERSION=$(grep "spec.version" "./${SCHEME_NAME}.podspec" | cut -d "\"" -f2)
echo -e "${YELLOW}StudioGuruBMSKit.podspec Version('$SPEC_VERSION')${NC}"
echo -e "${YELLOW}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}"
echo -e ""
read -p "'$SPEC_VERSION'XCFramework Archive 스크립트를 실행 [yes or no] : " isContinue


    if [ $isContinue == "yes" ]; then
        # ready        
        echo -e ".... ${YELLOW} StudioGuruBMSKit XCFramework Archiving .............${NC}"
        echo -e "${YELLOW}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}"

        echo -e ""

        # cleaning    
        echo -e "${YELLOW}.. archive clean${NC}"
        rm -rf ./SDK
        mkdir ./SDK
        echo -e "${YELLOW}.. archive clean -> finish${NC}"

        echo -e ""

        # iOS archive
        echo -e "${YELLOW}.. iOS archive${NC}"
        iosResult=$(xcodebuild archive -project ./${SCHEME_NAME}.xcodeproj -scheme "${SCHEME_NAME}" -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' -archivePath "./SDK/${SCHEME_NAME}-iOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES)
        if [[ $? == 0 ]]; then
            echo -e "${YELLOW}.. -> iOS archive -> success -> finish${NC}"
        else
            echo -e "${YELLOW}.. -> iOS archive -> failed -> exit${NC}"
            exit 1
        fi

        echo -e ""

        # iOS simulator archive
        echo -e "${YELLOW}.. iOS simulator archive${NC}"
        simulatorResult=$(xcodebuild archive -project ./${SCHEME_NAME}.xcodeproj -scheme "${SCHEME_NAME}" -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -archivePath "./SDK/${SCHEME_NAME}-iOS-Simulator" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES)
        if [[ $? == 0 ]]; then
            echo -e "${YELLOW}.. -> iOS-Simulator archive -> success -> finish${NC}"
        else
            echo -e "${YELLOW}.. -> iOS-Simulator archive -> failed exit${NC}"
            exit 1
        fi
        
        echo -e ""
        
        read -p "SwiftInterface name 이슈가 있을까요? [yes or no] : " isInteface
        if [ $isInteface == "yes" ]; then
            find . -name "*.swiftinterface" -exec sed -i '' -e 's/AdPopcornSSP\.//g' {} \;
            echo -e "${YELLOW}${SCHEME_NAME} swiftInterface file good Completed${NC}"
        else
            echo -e "${YELLOW}${SCHEME_NAME} swiftInterface file not Completed${NC}"
        fi
        
        echo -e ""

        # archive XCFramework
        echo -e "${YELLOW}.. XCFramework archive${NC}"
        xcframeworkResult=$(xcrun xcodebuild -create-xcframework  -framework "./SDK/${SCHEME_NAME}-iOS.xcarchive/Products/Library/Frameworks/${SCHEME_NAME}.framework" -framework "./SDK/${SCHEME_NAME}-iOS-Simulator.xcarchive/Products/Library/Frameworks/${SCHEME_NAME}.framework" -output "./SDK/${SCHEME_NAME}.xcframework")
        if [[ $? == 0 ]]; then
            echo -e "${YELLOW}.. -> XCFramework archive -> success -> finish${NC}"
        else
            echo -e "${YELLOW}.. -> XCFramework archive -> failed -> exit${NC}"
            exit 1
        fi

        echo -e ""

        # versioning XCFramework
        echo -e "${YELLOW}.. XCFramework versioning${NC}"
        /usr/libexec/PlistBuddy -c "Add :XCVersion string $SPEC_VERSION" ./SDK/${SCHEME_NAME}.xcframework/info.plist
        echo -e "${YELLOW}.. -> XCFramework versioning -> '$SPEC_VERSION'${NC}"

        echo -e ""

        # copy meta data @privacy-info
        read -p "PrivacyInfo 수동 설치 [yes or no] : " isPrivacy
        
        if [ $isPrivacy == "yes" ]; then
            echo -e "${YELLOW}.. collect PrivacyInfo.xcprivacy${NC}"
            cp "AdCashFramework/PrivacyInfo.xcprivacy" "./SDK/${SCHEME_NAME}.xcframework/ios-arm64/AdCashFramework.framework/"

            cp "AdCashFramework/PrivacyInfo.xcprivacy" "./SDK/${SCHEME_NAME}.xcframework/ios-arm64_x86_64-simulator/AdCashFramework.framework/"
            echo -e "${YELLOW}.. -> collect PrivacyInfo.xcprivacy -> finish${NC}"
        else
            echo -e "${YELLOW}.. -> not collect PrivacyInfo.xcprivacy -> finish${NC}"
        fi

        echo -e ""

        # copy meta data Assets xcassets
        echo -e "${YELLOW}.. Add Assets xcassets${NC}"
        mkdir -p "./SDK/${SCHEME_NAME}.xcframework/ios-arm64/Resources"
        mkdir -p "./SDK/${SCHEME_NAME}.xcframework/ios-arm64_x86_64-simulator/Resources"

        cp -r "./SDK/${SCHEME_NAME}-iOS.xcarchive/Products/Library/Frameworks/${SCHEME_NAME}.framework/Assets.car" "./SDK/${SCHEME_NAME}.xcframework/ios-arm64/Resources/"
        cp -r "./SDK/${SCHEME_NAME}-iOS-Simulator.xcarchive/Products/Library/Frameworks/${SCHEME_NAME}.framework/Assets.car" "./SDK/${SCHEME_NAME}.xcframework/ios-arm64_x86_64-simulator/Resources/"
        echo -e "${YELLOW}.. Add Assets xcassets -> finish${NC}"
        
        echo -e ""
        
        # clean archive
        echo -e "${YELLOW}.. clean archive { remove xcarchive }${NC}"
        rm -rf "./SDK/${SCHEME_NAME}-iOS.xcarchive"
        rm -rf "./SDK/${SCHEME_NAME}-iOS-Simulator.xcarchive"
        echo -e "${YELLOW}.. -> clean archive -> finish${NC}"

        echo -e ""

        # code signing
        echo -e "${YELLOW}.. XCFramework signing${NC}"
        codesign --timestamp -s "${SIGNING_CERTIFICATE}" "./SDK/${SCHEME_NAME}.xcframework"
        codesign --timestamp -s "${SIGNING_CERTIFICATE}" "./SDK/${SCHEME_NAME}.xcframework/ios-arm64/Resources/Assets.car"
        codesign --timestamp -s "${SIGNING_CERTIFICATE}" "./SDK/${SCHEME_NAME}.xcframework/ios-arm64_x86_64-simulator/Resources/Assets.car"
        echo -e "${YELLOW}.. -> XCFramework signing -> finish${NC}"
        
        # upload cocoapod
        echo -e ""
        
        read -p "XCFramework V$SPEC_VERSION Git Upload [yes or no] : " isDeploy
        
        if [ $isDeploy == "yes" ]; then
            echo -e "${YELLOW}'XCFramework Archive{$SPEC_VERSION}' -> Git Upload${NC}"
            git add .
            git commit -m "feat: version v${SPEC_VERSION} update"
            git push
            git tag v${SPEC_VERSION}
            git push origin v${SPEC_VERSION}
            echo -e "${YELLOW}${SCHEME_NAME} Git Upload Completed${NC}"
        else
            echo -e "${YELLOW}${SCHEME_NAME} Completed${NC}"
        fi
    else
        echo -e "${YELLOW}.. ${SCHEME_NAME} -> finish${NC}"
    fi
