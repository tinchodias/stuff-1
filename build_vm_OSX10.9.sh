#!/bin/bash

sw_vers -productVersion | grep 10.9 &> /dev/null

if [ ! ${?} -eq 0 ]; then
	echo "Exiting! This script was written SPECIFICALLY for OS X 10.9. You're running $(sw_vers -productVersion)."
	exit 1
fi

if [ -z "${1}" ]; then
	echo "Exiting! Please tell me where the pharo-vm directory is."
	exit 2
fi

ROOT=${1}

function fix_sources() {
	prev=$(pwd)
	cd ${ROOT}/image
	remove_deprecated_compiler_flags # do not comment this line. The build process will fail otherwise
	enable_debugging # comment this line if you want a fast / normal VM
	update_libgit2 # comment this line if you don't care about the libgit2 version
	cd ${prev}
}

# VM won't build wihout this fix
function remove_deprecated_compiler_flags() {
	src=$(cat <<EOF
Author fullName: 'bash'.
CogUnixConfig compile: 'compilerFlagsRelease
	^ {
		''-g0''. 
		''-O2''.
		''-msse2''. 
		''-D_GNU_SOURCE''. 
		''-DNDEBUG''. 
		''-DITIMER_HEARTBEAT=1''. 
		''-DNO_VM_PROFILE=1''. 
		''-DDEBUGVM=0'' }'.
Smalltalk snapshot: true andQuit: true.
EOF)
	./pharo generator.image eval ${src}
}

# for libgit2 development
function update_libgit2() {
	src=$(cat <<EOF
CMLibGit2 compile: 'downloadURL
	^ ''http://github.com/libgit2/libgit2/archive/v0.21.1.tar.gz'''.
CMLibGit2 compile: 'build

	gen 
		puts:
''
add_custom_command(OUTPUT "\${libGit2Installed}"
	COMMAND cmake -UGIT_THREADS -DCMAKE_INSTALL_PREFIX="\${installPrefix}" '', self configurationFlags, '' . 
	WORKING_DIRECTORY "\${libSourcesDir}"
	DEPENDS "\${unpackTarget}"
	COMMAND make
	COMMAND make install
	WORKING_DIRECTORY "\${libSourcesDir}"
	COMMENT "Building \${libName}"
)
'''.
CMLibGit2 compile: 'unpackedDirName
	^ ''libgit2-0.21.1'''.
CMOSXLibGit2 compile: 'libraryFileName
	^ ''libgit2.0.21.0.dylib'''.
CMLibGit2 compile: 'archiveMD5Sum
	^ ''cbf3422d54dd6f55f09855a6eb749f41'''.
Smalltalk snapshot: true andQuit: true.
EOF)
	./pharo generator.image eval ${src}
}

# enable debugging with XCode
function enable_debugging() {
	src=$(cat <<EOF
PharoVMBuilder compile: 'buildMacOSX32 
	"Build with freetype, cairo, osprocess"
	CogNativeBoostPlugin setTargetPlatform: #Mac32PlatformId.

	PharoOSXConfig new  
		generateForDebug;
		addExternalPlugins: #( FT2Plugin );
		addInternalPlugins: #( UnixOSProcessPlugin );
		addThirdpartyLibraries: #(
			''cairo'' 
			''libgit2''
			''libssh2'');
		generateSources; 
		generate.'.
Smalltalk snapshot: true andQuit: true.
EOF)
	./pharo generator.image eval ${src}
}

# libssh2 isn't linked correctly at the moment. rolling my own...
function create_xcode_project() {
	../scripts/extract-commit-info.sh
	rm -f CMakeCache.txt
	cmake -G Xcode .
	echo "Created XCode project at ${ROOT}/build/Pharo.xcodeproj."
}

function build_and_link_libssh2_32bit {
	pev=$(pwd)
	cd ${ROOT}
	cd ..
	
	if [ ! -e "libssh2/src/.libs/libssh2.dylib" ]; then
		which autoconf &>/dev/null
		if [ ! ${?} -eq 0 ]; then
			echo "installing Autoconf..."
			brew install autoconf
		fi
		which automake &>/dev/null
		if [ ! ${?} -eq 0 ]; then
			echo "installing Automake..."
			brew install automake
		fi
	
		if [ ! -e "libssh2" ]; then
			git clone --depth 1 git://git.libssh2.org/libssh2.git
		fi
		flags=${CFLAGS}
		export CFLAGS="${CFLAGS} -m32"
		cd libssh2
		./buildconf
		if [ ! ${?} -eq 0 ]; then
			echo "could not generate configure script for libssh2. Aborting..."
			export CFLAGS="${flags}"
			exit 5
		fi
		./configure
		if [ ! ${?} -eq 0 ]; then
			echo "there was an error during the configuration run of libssh2. Aborting..."
			export CFLAGS="${flags}"
			exit 6
		fi
		make
		if [ ! ${?} -eq 0 ]; then
			echo "there was an error building libssh2. Aborting..."
			export CFLAGS="${flags}"
			exit 7
		fi
		export CFLAGS="${flags}"
	fi
	echo "linking libssh2..."
	rm -f ${ROOT}/results/Pharo.app/Contents/MacOS/Plugins/libssh2.dylib
	ln -s $(pwd)/src/.libs/libssh2.dylib ${ROOT}/results/Pharo.app/Contents/MacOS/Plugins/
	cd ${prev}
}

# install dependencies
which brew &>/dev/null
if [ ! ${?} -eq 0 ]; then
	echo "homebrew not installed. Aborting..."
	exit 3
else
	brew list | grep cmake &>/dev/null
	if [ ! ${?} -eq 0 ]; then
		brew install cmake
	fi
	brew list | grep wget &>/dev/null
	if [ ! ${?} -eq 0 ]; then
		brew install wget
	fi
	brew list | grep git &>/dev/null
	if [ ! ${?} -eq 0 ]; then
		brew install git
	fi
fi

if [ ! -e /Applications/Xcode.app ]; then
	echo "Exiting! You don't have XCode. Please go and get that first."
	exit 4
fi

# install MacOSX10.6 SDK
if [ ! -e /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.6.sdk ]; then
	sudo cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs &&
		sudo wget http://files.pharo.org/vm/src/lib/MacOSX10.6.sdk.zip &&
		sudo unzip MacOSX10.6.sdk.zip &&
		sudo rm MacOSX10.6.sdk.zip
fi


cd ${ROOT}
echo "Cleaning up from possible previous builds..."
rm -rf build
rm -rf src
rm -rf results
rm -rf image
git checkout build
git checkout results
git checkout image
# ensure git repo is clean
git reset --hard HEAD
echo "Updating pharo-vm repository..."
git pull
cd image
echo "Getting a new generator image..."
./newImage.sh
echo "Fixing generated sources for OS X..."
fix_sources
echo "Generating sources..."
./pharo generator.image eval "PharoVMBuilder buildMacOSX32."
cd ../build
# fixes problems with OpenGL dependencies on OS X 1.9
sed -i "" 's-//#import <OpenGL/CGLMacro.h>-#import <OpenGL/GL.h>-' ../platforms/iOS/vm/OSX/sqSqueakOSXOpenGLView.m
"Building VM..."
bash build.sh
if [ ! ${?} -eq 0 ]; then
	echo "Build process exited with error. Aborting..."
	exit 5
fi
build_and_link_libssh2_32bit
echo "Creating XCode project for VM debugging..."
create_xcode_project
cd ${ROOT}

echo "Successfully built the VM. It's located in ${ROOT}/results"