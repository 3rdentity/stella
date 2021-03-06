if [ ! "$_TEMPLATEGO_INCLUDED_" == "1" ]; then 
_TEMPLATEGO_INCLUDED_=1


function feature_template-go() {
	FEAT_NAME="template-go"
	FEAT_LIST_SCHEMA="snapshot:source"
	FEAT_DEFAULT_VERSION="snapshot"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}


function feature_template-go_snapshot() {
	FEAT_VERSION="snapshot"
	FEAT_SOURCE_DEPENDENCIES="go-build-chain#1_4_2"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL="https://github.com/pborman/getopt/archive/master.zip"
	FEAT_SOURCE_URL_FILENAME="master.zip"
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=
	
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/getopt"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}


function feature_template-go_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$FEAT_INSTALL_ROOT/src/getopt"
	BUILD_DIR=

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME"

	# get dependencies
	cd "$SRC_DIR"
	cd Godeps
	GOPATH="$INSTALL_DIR" godep restore

	cd "$INSTALL_DIR"
	GOPATH="$INSTALL_DIR" go install getopt
}

fi
