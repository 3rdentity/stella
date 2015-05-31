if [ ! "$_STELLA_COMMON_FEATURE_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_FEATURE_INCLUDED_=1

# --------- API -------------------

function __list_active_features() {
	echo "$FEATURE_LIST_ENABLED"
}


function __list_feature_version() {
	local _SCHEMA=$1

	__internal_feature_context $_SCHEMA
	echo $FEAT_LIST_SCHEMA
}


function __feature_init() {
	local _SCHEMA=$1
	local _OPT="$2"
	local _opt_hidden_feature=OFF
	local o
	for o in $_OPT; do 
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
	done

	__internal_feature_context $_SCHEMA
	

	_flag=0
	local a
	for a in $FEATURE_LIST_ENABLED; do
		[ "$FEAT_NAME#$FEAT_VERSION" == "$a" ] && _flag=1
	done

	if [ "$_flag" == "0" ]; then
		__feature_inspect $FEAT_SCHEMA_SELECTED
		if [ "$TEST_FEATURE" == "1" ]; then

			if [ ! "$FEAT_BUNDLE" == "" ]; then
				local p	
				local save_FEAT_SCHEMA_SELECTED=$FEAT_SCHEMA_SELECTED

				FEAT_BUNDLE_MODE=$FEAT_BUNDLE
				for p in $FEAT_BUNDLE_ITEM; do	
					__feature_init $p "HIDDEN"
				done
				FEAT_BUNDLE_MODE=

				# re-compute bundle variables
				FEAT_SCHEMA_SELECTED=$save_FEAT_SCHEMA_SELECTED
				__internal_feature_context $FEAT_SCHEMA_SELECTED
				if [ ! "$_opt_hidden_feature" == "ON" ]; then
					FEATURE_LIST_ENABLED="$FEATURE_LIST_ENABLED $FEAT_NAME#$FEAT_VERSION"
				fi
				if [ ! "$FEAT_SEARCH_PATH" == "" ]; then
					PATH="$FEAT_SEARCH_PATH:$PATH"
				fi
				
			else

				
				if [ ! "$_opt_hidden_feature" == "ON" ]; then
					FEATURE_LIST_ENABLED="$FEATURE_LIST_ENABLED $FEAT_NAME#$FEAT_VERSION"
				fi
				if [ ! "$FEAT_SEARCH_PATH" == "" ]; then
					PATH="$FEAT_SEARCH_PATH:$PATH"
				fi

				
			fi

			local c
			for c in $FEAT_ENV_CALLBACK; do
				$c
			done
			

		fi

	fi
	
}



# get information on feature (from catalog)
function __feature_catalog_info() {
	local _SCHEMA=$1
	__internal_feature_context $_SCHEMA
}




# look for information about an installed feature
function __feature_match_installed() {
	local _SCHEMA=$1

	local _tested=
	local _found=

	if [ "$FEAT_BUNDLE_MODE" == "" ]; then

		__translate_schema "$_SCHEMA" "__VAR_FEATURE_NAME" "__VAR_FEATURE_VER" "__VAR_FEATURE_ARCH" "__VAR_FEATURE_FLAVOUR"


		[ ! "$__VAR_FEATURE_VER" == "" ] && _tested=$__VAR_FEATURE_VER
		[ ! "$__VAR_FEATURE_ARCH" == "" ] && _tested="$_tested"@"$__VAR_FEATURE_ARCH"

		if [ -d "$STELLA_APP_FEATURE_ROOT/$__VAR_FEATURE_NAME" ]; then
			# for each detected version
			for _f in  "$STELLA_APP_FEATURE_ROOT"/"$__VAR_FEATURE_NAME"/*; do
				if [ "$_tested" == "" ]; then
					_found=$_f
				else
					case $_f in
						*"$_tested"*)
							_found=$_f
						;;
						*);;
					esac
				fi
			done
		fi

		if [ ! "$_found" == "" ]; then
			# we fix the found version with the flavour of the requested schema
			[ ! "$__VAR_FEATURE_FLAVOUR" == "" ] && __internal_feature_context "$__VAR_FEATURE_NAME"#"$(__get_filename_from_string $_found)"/"$__VAR_FEATURE_FLAVOUR"
			[ "$__VAR_FEATURE_FLAVOUR" == "" ] && __internal_feature_context "$__VAR_FEATURE_NAME"#"$(__get_filename_from_string $_found)"
		else
			# empty info values
			__internal_feature_context
		fi
	else
		__internal_feature_context $_SCHEMA

	fi

}

# test if a feature is installed
# AND retrieve informations based on actually installed feature (looking inside STELLA_APP_FEATURE_ROOT) OR from feature recipe if not installed
# do not use default values from feature recipe to search installed feature
function __feature_inspect() {
	local _SCHEMA=$1
	TEST_FEATURE=0

	__feature_match_installed $_SCHEMA

	if [ ! "$FEAT_SCHEMA_SELECTED" == "" ]; then
		if [ ! "$FEAT_BUNDLE" == "" ]; then
			local p
			local _t=1
			local save_FEAT_SCHEMA_SELECTED=$FEAT_SCHEMA_SELECTED
			
			
			FEAT_BUNDLE_MODE="$FEAT_BUNDLE"
			for p in $FEAT_BUNDLE_ITEM; do
				TEST_FEATURE=0
				__feature_inspect $p
				[ "$TEST_FEATURE" == "0" ] && _t=0
			done
			FEAT_BUNDLE_MODE=
			FEAT_SCHEMA_SELECTED=$save_FEAT_SCHEMA_SELECTED
			__internal_feature_context $FEAT_SCHEMA_SELECTED
			TEST_FEATURE=$_t
			if [ "$TEST_FEATURE" == "1" ]; then
				[ "$VERBOSE_MODE" == "0" ] || echo " ** BUNDLE Detected in $save_FEAT_INSTALL_ROOT"
			fi
		else
			if [ "$FEAT_INSTALL_TEST" == "" ]; then
				TEST_FEATURE=1
			else
				if [ -f "$FEAT_INSTALL_TEST" ]; then
					TEST_FEATURE=1
					[ "$VERBOSE_MODE" == "0" ] || echo " ** FEATURE Detected in $FEAT_INSTALL_ROOT"
				fi
			fi
		fi
	else
		__feature_catalog_info $_SCHEMA
	fi
}






function __feature_remove() {
	local _SCHEMA=$1
	local _OPT="$2"

	local o
	local _opt_internal_feature=OFF
	local _opt_hidden_feature=OFF
	for o in $_OPT; do 
		[ "$o" == "INTERNAL" ] && _opt_internal_feature=ON
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
	done

	__feature_inspect $_SCHEMA	

	if [ ! "$FEAT_SCHEMA_OS_RESTRICTION" == "" ]; then
		if [ ! "$FEAT_SCHEMA_OS_RESTRICTION" == "$STELLA_CURRENT_OS" ]; then
			return
		fi
	fi

	local _save_app_feature_root=
	if [ "$_opt_internal_feature" == "ON" ]; then
		_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
		STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT
		_save_app_cache_dir=$STELLA_APP_CACHE_DIR
		STELLA_APP_CACHE_DIR=$STELLA_INTERNAL_CACHE_DIR
		_save_app_temp_dir=$STELLA_APP_TEMP_DIR
		STELLA_APP_TEMP_DIR=$STELLA_INTERNAL_TEMP_DIR
	fi

	if [ ! "$_opt_hidden_feature" == "ON" ]; then
		__remove_app_feature $_SCHEMA
	fi

	if [ "$TEST_FEATURE" == "1" ]; then

		if [ ! "$FEAT_BUNDLE" == "" ]; then
			echo " ** Remove bundle $FEAT_NAME version $FEAT_VERSION"
			__del_folder $FEAT_INSTALL_ROOT

			local save_FEAT_SCHEMA_SELECTED=$FEAT_SCHEMA_SELECTED
			FEAT_BUNDLE_MODE="$FEAT_BUNDLE"
			for p in $FEAT_BUNDLE_ITEM; do
				__feature_remove $p "HIDDEN"
				
			done
			FEAT_BUNDLE_MODE=
			FEAT_SCHEMA_SELECTED=$save_FEAT_SCHEMA_SELECTED
			__internal_feature_context $FEAT_SCHEMA_SELECTED

		else
			echo " ** Remove $FEAT_NAME version $FEAT_VERSION from $FEAT_INSTALL_ROOT"
			__del_folder $FEAT_INSTALL_ROOT
		fi
	fi
	

	if [ "$_opt_internal_feature" == "ON" ]; then
		STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
		STELLA_APP_CACHE_DIR=$_save_app_cache_dir
		STELLA_APP_TEMP_DIR=$_save_app_temp_dir
	fi

}

function __feature_install_list() {
	local _list=$1

	for f in $_list; do
		__feature_install $f
	done
}

function __feature_install() {
	local _SCHEMA=$1
	local _OPT="$2"

	local o
	local _opt_internal_feature=OFF
	local _opt_hidden_feature=OFF
	for o in $_OPT; do 
		[ "$o" == "INTERNAL" ] && _opt_internal_feature=ON
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
	done

	if [ "$_SCHEMA" == "required" ]; then
		__stella_features_requirement_by_os $STELLA_CURRENT_OS
	else

		local _flag=0
		local a

		__internal_feature_context $_SCHEMA
		
		if [ ! "$FEAT_SCHEMA_SELECTED" == "" ]; then

			if [ ! "$FEAT_SCHEMA_OS_RESTRICTION" == "" ]; then
				if [ ! "$FEAT_SCHEMA_OS_RESTRICTION" == "$STELLA_CURRENT_OS" ]; then
					return
				fi
			fi

			local _save_app_feature_root=
			if [ "$_opt_internal_feature" == "ON" ]; then
				_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
				STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT
				_save_app_cache_dir=$STELLA_APP_CACHE_DIR
				STELLA_APP_CACHE_DIR=$STELLA_INTERNAL_CACHE_DIR
				_save_app_temp_dir=$STELLA_APP_TEMP_DIR
				STELLA_APP_TEMP_DIR=$STELLA_INTERNAL_TEMP_DIR
			fi
			if [ ! "$_opt_hidden_feature" == "ON" ]; then
				__add_app_feature $_SCHEMA
			fi

			
			if [ "$FORCE" == "1" ]; then
				TEST_FEATURE=0
				__del_folder $FEAT_INSTALL_ROOT
			else
				__feature_inspect $FEAT_SCHEMA_SELECTED
			fi


			if [ "$TEST_FEATURE" == "0" ]; then


				mkdir -p $FEAT_INSTALL_ROOT

				# dependencies
				save_FORCE=$FORCE
				FORCE=0
				local dep
				local _f_dep=0
				local save_FEAT_SCHEMA_SELECTED=$FEAT_SCHEMA_SELECTED

				if [ "$FEAT_SCHEMA_FLAVOUR" == "source" ]; then
					for dep in $FEAT_SOURCE_DEPENDENCIES; do
						echo "Installing dependency $dep"
						__feature_install $dep
						_f_dep=1
					done
				fi

				if [ "$FEAT_SCHEMA_FLAVOUR" == "binary" ]; then
					for dep in $FEAT_BINARY_DEPENDENCIES; do
						echo "Installing dependency $dep"
						__feature_install $dep
						_f_dep=1
					done
				fi
				FORCE=$save_FORCE

				FEAT_SCHEMA_SELECTED=$save_FEAT_SCHEMA_SELECTED
				[ "$_f_dep" == "1" ] && __internal_feature_context $FEAT_SCHEMA_SELECTED

				# Bundle
				if [ ! "$FEAT_BUNDLE" == "" ]; then
					FEAT_BUNDLE_MODE=$FEAT_BUNDLE
					local save_FEAT_SCHEMA_SELECTED=$FEAT_SCHEMA_SELECTED
					if [ ! "$FEAT_BUNDLE_ITEM" == "" ]; then
						save_FORCE=$FORCE
					
						FORCE=0

						local _flag_hidden
						if [ "$FEAT_BUNDLE_MODE" == "LIST" ]; then
							_flag_hidden=
						else
							_flag_hidden="HIDDEN"
						fi

						
						local p
						for p in $FEAT_BUNDLE_ITEM; do
							__feature_install $p "$_OPT $_flag_hidden"
						done
						
						FORCE=$save_FORCE
						
					fi
					FEAT_BUNDLE_MODE=
					FEAT_SCHEMA_SELECTED=$save_FEAT_SCHEMA_SELECTED
					__internal_feature_context $FEAT_SCHEMA_SELECTED
					# automatic call of callback
					__feature_callback
				else
					echo " ** Installing $FEAT_NAME version $FEAT_VERSION in $FEAT_INSTALL_ROOT"
					feature_"$FEAT_NAME"_install_"$FEAT_SCHEMA_FLAVOUR"
				fi

				__feature_inspect $FEAT_SCHEMA_SELECTED
				if [ "$TEST_FEATURE" == "1" ]; then
					echo "** Feature $_SCHEMA is installed"
					__feature_init "$FEAT_SCHEMA_SELECTED" $_OPT
				else
					echo "** Error while installing feature $FEAT_SCHEMA_SELECTED"
					#__del_folder $FEAT_INSTALL_ROOT
					# Sometimes current directory is lost by the system
					cd $STELLA_APP_ROOT
				fi
				
			else
				echo "** Feature $_SCHEMA already installed"
				__feature_init "$FEAT_SCHEMA_SELECTED" $_OPT
			fi



			if [ "$_opt_internal_feature" == "ON" ]; then
				STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
				STELLA_APP_CACHE_DIR=$_save_app_cache_dir
				STELLA_APP_TEMP_DIR=$_save_app_temp_dir
			fi


		else
			echo " ** Error unknow feature $_SCHEMA"
		fi
	fi
}






# ----------- INTERNAL ----------------


function __feature_init_installed() {
	local _flag=
	
	# init internal features
	# internal feature are not prioritary over app features
	if [ ! "$STELLA_APP_FEATURE_ROOT" == "$STELLA_INTERNAL_FEATURE_ROOT" ]; then
		
		_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
		STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT


		for f in "$STELLA_INTERNAL_FEATURE_ROOT"/*; do
			if [ -d "$f" ]; then
				_flag=0
				# check for official feature
				for a in $__STELLA_FEATURE_LIST; do
					if [ "$a" == "$(__get_filename_from_string $f)" ]; then
						# for each detected version
						for v in  "$f"/*; do
							[ -d "$v" ] && __feature_init "$(__get_filename_from_string $f)#$(__get_filename_from_string $v)" "INTERNAL HIDDEN"
						done
					fi
				done
			fi
		done
		STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
	fi

	for f in  "$STELLA_APP_FEATURE_ROOT"/*; do
		if [ -d "$f" ]; then
			_flag=0
			# check for official feature
			for a in $__STELLA_FEATURE_LIST; do
				if [ "$a" == "$(__get_filename_from_string $f)" ]; then
					# for each detected version
					for v in  "$f"/*; do
						[ -d "$v" ] && __feature_init "$(__get_filename_from_string $f)#$(__get_filename_from_string $v)"
					done
				fi
			done
		fi
	done

	# TODO log
	[ ! "$FEATURE_LIST_ENABLED" == "" ] && echo "** Features initialized : $FEATURE_LIST_ENABLED"
}




function __feature_reinit_installed() {
	FEATURE_LIST_ENABLED=
	__feature_init_installed
}


function __feature_callback() {
	local p

	if [ ! "$FEAT_BUNDLE" == "" ]; then
		for p in $FEAT_BUNDLE_CALLBACK; do
			$p
		done
	else

		if [ "$FEAT_SCHEMA_FLAVOUR" == "source" ]; then
			for p in $FEAT_SOURCE_CALLBACK; do
				$p
			done
		fi
		if [ "$FEAT_SCHEMA_FLAVOUR" == "binary" ]; then
			for p in $FEAT_BINARY_CALLBACK; do
				$p
			done
		fi
	fi
}


function __internal_feature_context() {
	local _SCHEMA=$1

	FEAT_ARCH=
	
	local TMP_FEAT_SCHEMA_NAME=
	local TMP_FEAT_SCHEMA_VERSION=
	FEAT_SCHEMA_SELECTED=
	FEAT_SCHEMA_FLAVOUR=
	FEAT_SCHEMA_OS_RESTRICTION=


	FEAT_NAME=
	FEAT_LIST_SCHEMA=
	FEAT_DEFAULT_VERSION=
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR=
	FEAT_VERSION=
	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=
	FEAT_BINARY_DEPENDENCIES=
	FEAT_BINARY_CALLBACK=
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST=
	FEAT_INSTALL_ROOT=
	FEAT_SEARCH_PATH=
	FEAT_ENV_CALLBACK=
	FEAT_BUNDLE_ITEM=
	FEAT_BUNDLE_CALLBACK=
	# MERGE / NESTED / LIST
	FEAT_BUNDLE=
	

	[ ! "$_SCHEMA" == "" ] && __select_schema $_SCHEMA "FEAT_SCHEMA_SELECTED"

	if [ ! "$FEAT_SCHEMA_SELECTED" == "" ]; then
		
		__translate_schema $FEAT_SCHEMA_SELECTED "TMP_FEAT_SCHEMA_NAME" "TMP_FEAT_SCHEMA_VERSION" "FEAT_ARCH" "FEAT_SCHEMA_FLAVOUR" "FEAT_SCHEMA_OS_RESTRICTION"

		# set install root (FEAT_INSTALL_ROOT)
		if [ "$FEAT_BUNDLE_MODE" == "" ]; then
			if [ ! "$FEAT_ARCH" == "" ]; then
				FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"/"$TMP_FEAT_SCHEMA_NAME"/"$TMP_FEAT_SCHEMA_VERSION"@"$FEAT_ARCH"
			else
				FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"/"$TMP_FEAT_SCHEMA_NAME"/"$TMP_FEAT_SCHEMA_VERSION"
			fi
		else
			if [ "$FEAT_BUNDLE_MODE" == "MERGE" ]; then
				FEAT_INSTALL_ROOT="$FEAT_BUNDLE_PATH"
			fi
			if [ "$FEAT_BUNDLE_MODE" == "NESTED" ]; then
				FEAT_INSTALL_ROOT="$FEAT_BUNDLE_PATH"/"$TMP_FEAT_SCHEMA_NAME"
			fi
			if [ "$FEAT_BUNDLE_MODE" == "LIST" ]; then
				if [ ! "$FEAT_ARCH" == "" ]; then
					FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"/"$TMP_FEAT_SCHEMA_NAME"/"$TMP_FEAT_SCHEMA_VERSION"@"$FEAT_ARCH"
				else
					FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"/"$TMP_FEAT_SCHEMA_NAME"/"$TMP_FEAT_SCHEMA_VERSION"
				fi
			fi
		fi

		# grab feature info
		source $STELLA_FEATURE_RECIPE/feature_$TMP_FEAT_SCHEMA_NAME.sh
		feature_$TMP_FEAT_SCHEMA_NAME
		feature_"$TMP_FEAT_SCHEMA_NAME"_"$TMP_FEAT_SCHEMA_VERSION"

		# bundle path
		if [ ! "$FEAT_BUNDLE" == "" ]; then
			if [ "$FEAT_BUNDLE" == "LIST" ]; then
				FEAT_BUNDLE_PATH=
			else
				FEAT_BUNDLE_PATH="$FEAT_INSTALL_ROOT"
			fi
		fi

		# set url dependending on arch
		if [ ! "$FEAT_ARCH" == "" ]; then
			local _tmp="FEAT_BINARY_URL_$FEAT_ARCH"
			FEAT_BINARY_URL=${!_tmp}
			_tmp="FEAT_BINARY_URL_FILENAME_$FEAT_ARCH"
			FEAT_BINARY_URL_FILENAME=${!_tmp}
			_tmp="FEAT_BINARY_URL_PROTOCOL_$FEAT_ARCH"
			FEAT_BINARY_URL_PROTOCOL=${!_tmp}
			_tmp="FEAT_BUNDLE_ITEM_$FEAT_ARCH"
			FEAT_BUNDLE_ITEM=${!_tmp}
			_tmp="FEAT_BINARY_DEPENDENCIES_$FEAT_ARCH"
			FEAT_BINARY_DEPENDENCIES=${!_tmp}
		fi


	fi
}




# pick a feature schema by filling some values with default one
function __select_schema() {
	local _SCHEMA=$1
	local _RESULT_SCHEMA=$2

	local _FILLED_SCHEMA=


 	[ ! "$_RESULT_SCHEMA" == "" ] && unset -v $_RESULT_SCHEMA

	__translate_schema "$_SCHEMA" "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR"


	local _official=0
	for a in $__STELLA_FEATURE_LIST; do
		[ "$a" == "$_TR_FEATURE_NAME" ] && _official=1
	done


	if [ "$_official" == "1" ]; then

		# grab feature info
		source $STELLA_FEATURE_RECIPE/feature_$_TR_FEATURE_NAME.sh
		feature_$_TR_FEATURE_NAME

		# fill schema with default values
		[ "$_TR_FEATURE_VER" == "" ] && _TR_FEATURE_VER=$FEAT_DEFAULT_VERSION
		[ "$_TR_FEATURE_ARCH" == "" ] && _TR_FEATURE_ARCH=$FEAT_DEFAULT_ARCH
		[ "$_TR_FEATURE_FLAVOUR" == "" ] && _TR_FEATURE_FLAVOUR=$FEAT_DEFAULT_FLAVOUR


		_FILLED_SCHEMA="$_TR_FEATURE_NAME"#"$_TR_FEATURE_VER"
		[ ! "$_TR_FEATURE_ARCH" == "" ] && _FILLED_SCHEMA="$_FILLED_SCHEMA"@"$_TR_FEATURE_ARCH"
		[ ! "$_TR_FEATURE_FLAVOUR" == "" ] && _FILLED_SCHEMA="$_FILLED_SCHEMA"/"$_TR_FEATURE_FLAVOUR"
		
		# check filled schema exists
		
		local _flag=0
		local l
		for l in $FEAT_LIST_SCHEMA; do
			if [ "$_TR_FEATURE_NAME"#"$l" == "$_FILLED_SCHEMA" ]; then
				[ ! "$_RESULT_SCHEMA" == "" ] && eval $_RESULT_SCHEMA=$_FILLED_SCHEMA
			fi
		done
	fi

}


# split schema properties
# feature schema name[#version][@arch][/flavour][:os_restriction] in any order
#				@arch could be x86 or x64
#				/flavour could be binary or source
# example: wget:ubuntu#1_2@x86/source
function __translate_schema() {
	local _schema=$1

	local _VAR_FEATURE_NAME=$2
	local _VAR_FEATURE_VER=$3
	local _VAR_FEATURE_ARCH=$4
	local _VAR_FEATURE_FLAVOUR=$5
	local _VAR_FEATURE_OS_RESTRICTION=$6

	[ ! "$_VAR_FEATURE_NAME" == "" ] && unset -v $_VAR_FEATURE_NAME
	[ ! "$_VAR_FEATURE_VER" == "" ] && unset -v $_VAR_FEATURE_VER
	[ ! "$_VAR_FEATURE_ARCH" == "" ] && unset -v $_VAR_FEATURE_ARCH
	[ ! "$_VAR_FEATURE_FLAVOUR" == "" ] && unset -v $_VAR_FEATURE_FLAVOUR
	[ ! "$_VAR_FEATURE_OS_RESTRICTION" == "" ] && unset -v $_VAR_FEATURE_OS_RESTRICTION

	local _char=


	_char=":"
	if [ -z "${_schema##*$_char*}" ]; then
		[ ! "$_VAR_FEATURE_OS_RESTRICTION" == "" ] && eval $_VAR_FEATURE_OS_RESTRICTION=$(echo $_schema | cut -d':' -f 2 | cut -d'#' -f 1 | cut -d'@' -f 1 | cut -d'/' -f 1)
	fi

	_char="#"
	if [ -z "${_schema##*$_char*}" ]; then
		[ ! "$_VAR_FEATURE_VER" == "" ] && eval $_VAR_FEATURE_VER=$(echo $_schema | cut -d'#' -f 2 | cut -d':' -f 1 | cut -d'@' -f 1 | cut -d'/' -f 1)
	fi

	_char="@"
	if [ -z "${_schema##*$_char*}" ]; then
		[ ! "$_VAR_FEATURE_ARCH" == "" ] && eval $_VAR_FEATURE_ARCH=$(echo $_schema | cut -d'@' -f 2 | cut -d':' -f 1 | cut -d'#' -f 1 | cut -d'/' -f 1)
	fi

	_char="/"
	if [ -z "${_schema##*$_char*}" ]; then
		[ ! "$_VAR_FEATURE_FLAVOUR" == "" ] && eval $_VAR_FEATURE_FLAVOUR=$(echo $_schema | cut -d'/' -f 2 | cut -d':' -f 1 | cut -d'#' -f 1 | cut -d'@' -f 1)
	fi

	[ ! "$_VAR_FEATURE_NAME" == "" ] && eval $_VAR_FEATURE_NAME=$(echo $_schema | cut -d'/' -f 1 | cut -d':' -f 1 | cut -d'#' -f 1 | cut -d'@' -f 1)
}



# --------------- DEPRECATED ---------------------------------------------


# TODO : migrate to separate recipe (or erase?)
function __texinfo() {
	URL=http://ftp.gnu.org/gnu/texinfo/texinfo-5.1.tar.xz
	VER=5.1
	FILE_NAME=texinfo-5.1.tar.xz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/texinfo-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/texinfo-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	
	__auto_install "configure" "texinfo" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}

function __bc() {
	#http://www.gnu.org/software/bc/bc.html

	URL=http://alpha.gnu.org/gnu/bc/bc-1.06.95.tar.bz2
	VER=1.06.95
	FILE_NAME=bc-1.06.95.tar.bz2
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"	
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/bc-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/bc-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=
	
	__auto_install "configure" "bc" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

function __file5() {
	URL=ftp://ftp.astron.com/pub/file/file-5.15.tar.gz
	VER=5.15
	FILE_NAME=file-5.15.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/file-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/file-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="--disable-static"

	__auto_install "configure" "file" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}

function __m4() {

	URL=http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
	VER=1.4.17
	FILE_NAME=m4-1.4.17.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"	
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/m4-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/m4-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__auto_install "configure" "m4" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

function __binutils() {
	#TODO configure flag
	URL=http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.bz2
	VER=2.23.2
	FILE_NAME=binutils-2.23.2.tar.bz2
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/binutils-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/binutils-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX="AR=ar AS=as"
	AUTO_INSTALL_FLAG_POSTFIX="--host=$CROSS_HOST --target=$CROSS_TARGET \
  	--with-sysroot=${CLFS} --with-lib-path=/tools/lib --disable-nls \
  	--disable-static --enable-64-bit-bfd"

	__auto_install "configure" "binutils" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}









fi
