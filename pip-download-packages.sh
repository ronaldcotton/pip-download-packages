#!/bin/bash
# downloads both wheel and source files for offline use
# requires python and pip installed.
# Tested in RHEL 8.0

# change pip, downloadDir, and downloadArray depending on your needs.
# if downloadArray only contains the name of the package, it downloads the stable
# version.
pip="pip3"
downloadDir="/tmp"
downloadArray=( "pip:19.3.1"
                "wheel:0.33.6"
                "setuptools:41.6.0"
		"six" )

# The downloading command depends on the version of pip installed.
# `pip install --download` was the method for pip before 8.0.0 and 'pip download' thereafter.
pipMajorVersion=$($pip list --format=legacy | grep pip | sed -u 's/pip (\([0-9]\).*/\1/')
[ "$pipMajorVersion" -lt "8" ] || downloadCMD="install" && downloadCMD="download"

# setupDirs
# /src holds the source for the package, /whl holds the wheel file for
# offline installation.  Choose whichever package you prefer.
function setupDirs {
	[ ! -d "$downloadDir/src" ] || mkdir -p $downloadDir/src
	[ ! -d "$downloadDir/whl" ] || mkdir -p $downloadDir/whl
}

# pip-download
# download package and dependencies for pip offline install.
function pipDownload {
	downloadArray=("$@")
	for dl in "${downloadArray[@]}"; do
		dlKey="${dl%%:*}"
		dlValue="${dl##*:}"
		if [[ "$dlKey" == "$dlValue" ]]; then
			$pip $downloadCMD $dlKey -d $downloadDir/whl
	       		$pip $downloadCMD $dlKey -d $downloadDir/src --no-binary :all:
		else	
			$pip $downloadCMD ${dlKey}==${dlValue} -d $downloadDir/whl
			$pip $downloadCMD ${dlKey}==${dlValue} -d $downloadDir/src --no-binary :all:
		fi
	done
}

### Main
setupDirs
pipDownload "${downloadArray[@]}"

