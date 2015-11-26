if [ ! "$_vorbis_INCLUDED_" == "1" ]; then 
_vorbis_INCLUDED_=1



function feature_vorbis() {
	FEAT_NAME=vorbis
	FEAT_LIST_SCHEMA="1_3_5:source"
	FEAT_DEFAULT_VERSION=1_3_5
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}




function feature_vorbis_1_3_5() {
	FEAT_VERSION=1_3_5
	
	FEAT_SOURCE_DEPENDENCIES="libogg#DEV20150926"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.zip
	FEAT_SOURCE_URL_FILENAME=libvorbis-1.3.5.zip
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_vorbis_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libvorbis.a
	FEAT_SEARCH_PATH=
	
}


function feature_vorbis_link() {
	__link_feature_library "libogg#DEV20150926"
}

function feature_vorbis_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__feature_callback

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

}




fi