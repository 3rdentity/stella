if [ ! "$_GETOPT_INCLUDED_" == "1" ]; then 
_GETOPT_INCLUDED_=1

#https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gnu-getopt.rb
# TODO : patch makefile with macport recipe ?

function feature_getopt() {

	FEAT_NAME=getopt
	FEAT_LIST_SCHEMA="1_1_6/source"
	FEAT_DEFAULT_VERSION=1_1_6
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_getopt_1_1_6() {

	FEAT_VERSION=1_1_6

	FEAT_SOURCE_URL=http://frodo.looijaard.name/system/files/software/getopt/getopt-1.1.6.tar.gz
	FEAT_SOURCE_URL_FILENAME=getopt-1.1.6.tar.gz
	FEAT_SOURCE_CALLBACK=feature_getopt_1_1_6_patch
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/getopt
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV=
	
	FEAT_BUNDLE_LIST=
}


function feature_getopt_1_1_6_patch() {
	# https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gnu-getopt.rb

	feature_info gettext
	sed -i .bak 's,^\(CPPFLAGS=.*\),\1 '"-I$FEAT_INSTALL_ROOT/include"',' $SRC_DIR/Makefile
	sed -i .bak 's,^\(LDFLAGS=.*\),\1 '"-L$FEAT_INSTALL_ROOT/lib -lintl"',' $SRC_DIR/Makefile
}

function feature_getopt_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR=


	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$SRC_DIR" "DEST_ERASE STRIP"

	__feature_apply_source_callback
	
	cd "$SRC_DIR"
	make
	make prefix="$INSTALL_DIR" mandir=man install && __del_folder $SRC_DIR
}



fi