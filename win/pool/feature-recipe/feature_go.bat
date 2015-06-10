@echo off
call %*
goto :eof


:feature_go
	set "FEAT_NAME=go"
	set "FEAT_LIST_SCHEMA=1_4_2@x64:binary 1_4_2@x86:binary"
	set "FEAT_DEFAULT_VERSION=1_4_2"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_go_1_4_2
	set "FEAT_VERSION=1_4_2"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x86=https://storage.googleapis.com/golang/go1.4.2.windows-386.zip"
	set "FEAT_BINARY_URL_FILENAME_x86="
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"
	set "FEAT_BINARY_URL_x64=https://storage.googleapis.com/golang/go1.4.2.windows-amd64.zip"
	set "FEAT_BINARY_URL_FILENAME_x64="
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=feature_go_set_env

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\go.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

	
goto :eof

:feature_go_set_env
	set "GOROOT=!FEAT_INSTALL_ROOT!"
goto :eof

:feature_go_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"
goto :eof



