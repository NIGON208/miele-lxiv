#!/bin/sh

cd "${BUILT_PRODUCTS_DIR}"
product="LXIV Launcher.app"
dest="${UNLOCALIZED_RESOURCES_FOLDER_PATH}/LXIV Launcher.zip"
rm -f "$dest"
zip -qr "${dest}" . -i "${product}"

