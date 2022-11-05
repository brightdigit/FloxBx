#!/bin/sh

export MINT_PATH="$PWD/.mint"
MINT_ARGS="-n -m ../../Mintfile --silent"
MINT_RUN="mint run $MINT_ARGS"

mint bootstrap

if [ -z "$SRCROOT" ]; then
	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	PACKAGE_DIR="${SCRIPT_DIR}/../Packages/FloxBxKit"
else
	PACKAGE_DIR="${SRCROOT}/Packages/FloxBxKit" 	
fi


if [ "$LINT_MODE" == "NONE" ]; then
	exit
elif [ "$LINT_MODE" == "STRICT" ]; then
	SWIFTFORMAT_OPTIONS=""
	SWIFTLINT_OPTIONS="--strict"
	STRINGSLINT_OPTIONS="--config .strict.stringslint.yml"
else 
	SWIFTFORMAT_OPTIONS=""
	SWIFTLINT_OPTIONS=""
	STRINGSLINT_OPTIONS="--config .stringslint.yml"
fi

pushd $PACKAGE_DIR

if [ -z "$CI" ]; then
	$MINT_RUN swiftformat .
	$MINT_RUN swiftlint autocorrect
else 
	set -e
fi

$MINT_RUN periphery scan 
$MINT_RUN stringslint lint $STRINGSLINT_OPTIONS
$MINT_RUN swiftformat --lint $SWIFTFORMAT_OPTIONS .
$MINT_RUN swiftlint lint $SWIFTLINT_OPTIONS

popd
