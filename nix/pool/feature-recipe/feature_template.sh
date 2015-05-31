if [ ! "$_TEMPLATE_INCLUDED_" == "1" ]; then 
_TEMPLATE_INCLUDED_=1


function feature_template() {
	FEAT_NAME=template
	FEAT_LIST_SCHEMA="1_0_0@x64/binary 1_0_0@x86/binary"
	FEAT_DEFAULT_VERSION=1_0_0
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}



function feature_template_1_0_0() {
	#if FEAT_ARCH is not not null, properties FOO_ARCH=BAR will be selected and setted as FOO=BAR
	# if FOO_ARCH is empty, FOO will not be changed

	FEAT_VERSION=1_0_0

	# Dependencies
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES_x86=
	FEAT_BINARY_DEPENDENCIES_x64=

	# Properties for SOURCE flavour
	FEAT_SOURCE_URL="http://foo.com/template-1_0_0-src.zip"
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"

	# Properties for BINARY flavour
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=
	FEAT_BINARY_URL_x86="http://foo.com/bar"
	FEAT_BINARY_URL_FILENAME_x86="template-1_0_0-x86.zip"
	FEAT_BINARY_URL_PROTOCOL_x86="HTTP_ZIP"
	FEAT_BINARY_URL_x64="http://foo.com/bar"
	FEAT_BINARY_URL_FILENAME_x64="template-1_0_0-x86.zip"
	FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"

	# callback are list of functions
	# manual callback (with feature_callback)
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	# automatic callback each time feature is initialized, to init env var
	FEAT_ENV_CALLBACK=feature_template_setenv
	
	# File to test if feature is installed
	FEAT_INSTALL_TEST=$FEAT_INSTALL_ROOT/bin/template
	# PATH to add to system PATH
	FEAT_SEARCH_PATH=$FEAT_INSTALL_ROOT/bin

}

function feature_template_setenv()  {
	TEMPLATE_HOME=$FEAT_INSTALL_ROOT
	export TEMPLATE_HOME
}

function feature_template_install_binary() {
	
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"

	__feature_callback

}



function feature_template_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"

	__feature_callback

	cd "$SRC_DIR"

	make
	make install && __del_folder $SRC_DIR
}




fi