if [ ! "$_PERL_INCLUDED_" == "1" ]; then 
_PERL_INCLUDED_=1


 
function __list_perl() {
	echo "5_18_2"
}

function __default_perl() {
	echo "5_18_2"
}


function __install_perl() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	mkdir -p $STELLA_APP_FEATURE_ROOT/perl

	if [ "$_VER" == "" ]; then
		__install_perl_$(__default_perl)
	else
		# check for version
		for v in $(__list_perl); do
			[ "$v" == "$_VER" ] && __install_perl_$_VER
		done
	fi

}
function __feature_perl() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_perl_$(__default_perl)
	else
		# check for version
		for v in $(__list_perl); do
			[ "$v" == "$_VER" ] && __feature_perl_$_VER
		done
	fi
}


# --------------------------------------
function __install_perl_5_18_2() {
	URL=http://www.cpan.org/src/5.0/perl-5.18.2.tar.gz
	VER=5_18_2
	FILE_NAME=perl-5.18.2.tar.gz
	__install_perl_internal
}


function __feature_perl_5_18_2() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/perl/5_18_2/bin/perl"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/perl/5_18_2"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="5_18_2"
	__feature_perl_internal
}

# --------------------------------------

function __install_perl_internal() { 
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/perl/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/perl/perl-$VER-src"
	BUILD_DIR=

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__feature_perl_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__download_uncompress "$URL" "$FILE_NAME" "$SRC_DIR" "DEST_ERASE STRIP"

		cd "$SRC_DIR"

		sh "$SRC_DIR/Configure" -des -Dprefix=$INSTALL_DIR \
	                  -Dvendorprefix=$INSTALL_DIR \
	                  -Dpager="/usr/bin/less -isR"  \
	                  -Duseshrplib

		#make -j$BUILD_JOB
		make
		# test are too long
		# make test
		make install

		__feature_perl_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** Perl installed"
			"$FEATURE_ROOT/bin/perl" --version

			__del_folder $SRC_DIR
		else
			echo "** ERROR"
		fi

	else
		echo " ** Already installed"
	fi
}
function __feature_perl_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : perl in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi

}


fi