if [ ! "$_ANT_INCLUDED_" == "1" ]; then 
_ANT_INCLUDED_=1



function feature_ant() {
	FEAT_NAME=ant
	FEAT_LIST_SCHEMA="1_9_5:binary"
	FEAT_DEFAULT_VERSION=1_9_5
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_ant_env() {
	ANT_HOME=$FEAT_INSTALL_ROOT
	export ANT_HOME=$FEAT_INSTALL_ROOT
}



function feature_ant_1_9_5() {
	FEAT_VERSION=1_9_5
	
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=http://www.eu.apache.org/dist/ant/binaries/apache-ant-1.9.5-bin.tar.gz
	FEAT_BINARY_URL_FILENAME=apache-ant-1.9.5-bin.tar.gz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=feature_ant_env

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/ant
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	
}



function feature_ant_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "STRIP"

}




fi