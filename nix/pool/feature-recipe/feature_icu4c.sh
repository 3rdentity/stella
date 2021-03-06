if [ ! "$_icu4c_INCLUDED_" == "1" ]; then
_icu4c_INCLUDED_=1



function feature_icu4c() {
	FEAT_NAME=icu4c
	FEAT_LIST_SCHEMA="55_1:source"
	FEAT_DEFAULT_VERSION=55_1
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_icu4c_55_1() {
	FEAT_VERSION=55_1

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL="https://ssl.icu-project.org/files/icu4c/55.1/icu4c-55_1-src.tgz"
	FEAT_SOURCE_URL_FILENAME=icu4c-55_1-src.tgz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/icuinfo
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}


function feature_icu4c_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"




	AUTO_INSTALL_CONF_FLAG_PREFIX=
	# --enable-rpath make binaries and shared libs correctly linked
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-samples --disable-tests --enable-static --enable-rpath"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__auto_build "$FEAT_NAME" "$SRC_DIR/source" "$INSTALL_DIR"

}


fi
