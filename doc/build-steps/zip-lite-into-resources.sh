#!/bin/sh

cd "${BUILT_PRODUCTS_DIR}"
#cd "${PROJECT_DIR}/build/${CONFIGURATION}"
product="OsiriX Lite.app"
dest="${UNLOCALIZED_RESOURCES_FOLDER_PATH}/OsiriX Lite.zip"
rm -f "${dest}"
zip -qr "${dest}" . -i "${product}"