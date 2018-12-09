#!/bin/sh
#test with codesign -vvv

source $PROJECT_DIR/doc/build-steps/identity.conf

chmod -R 777 "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/"

function cs {
  codesign --timestamp --force --sign "$IDENTITY" "$1"
}

function cse {
  codesign --timestamp --force \
    --sign "$IDENTITY" \
    -o runtime \
    --entitlements "$PROJECT_DIR/miele-lxiv-${CONFIGURATION}.entitlements" \
    "$1"
}

#if [[ ${CONFIGURATION} != "Development" ]] ; then
#cs  "$TARGET_BUILD_DIR/$FRAMEWORKS_FOLDER_PATH/MieleAPI.framework"
#cs  "$TARGET_BUILD_DIR/$FRAMEWORKS_FOLDER_PATH/libpng16.16.30.0"
cs  "$TARGET_BUILD_DIR/$FRAMEWORKS_FOLDER_PATH/libjpeg.9.dylib"

#cse "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/odt2pdf.zip"
#cse "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/odt2pdf"
cse "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/dciodvfy"
cse "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/dcmdump"
cse "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/dsr2html"
cse "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/echoscu"

# commented out because done automatically by Xcode
#cse "$TARGET_BUILD_DIR/$EXECUTABLE_FOLDER_PATH/Decompress"
#cse "$TARGET_BUILD_DIR/$EXECUTABLE_FOLDER_PATH/DICOMPrint"
#cse "$TARGET_BUILD_DIR/$EXECUTABLE_FOLDER_PATH/dcmpsprt"
#cse "$TARGET_BUILD_DIR/$EXECUTABLE_FOLDER_PATH/dcmprscu"

cse "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/OsiriX Lite.zip"
#cse "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/LXIV Launcher.zip"

#codesign --resource-rules Rules.plist -f -s "$IDENTITY" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/"
echo "code signed"
#fi
