#!/bin/bash
set -o errtrace
set -o errexit
set -o pipefail

ScriptPath=$( dirname "$0" | sed 's/^\(.\):/\/cygdrive\/\1/' | sed 's/\\/\//gi' )
Here=$PWD

pushd "${ScriptPath}"

echo Removing old scripts
rm -f generated/phr_*.typ

echo Spooling CLOB
gawk -f phr_anylob.typ.awk -v i_modus_operandi=clob phr_anylob.typ > generated/phr_clob.typ

echo Spooling BLOB
gawk -f phr_anylob.typ.awk -v i_modus_operandi=blob phr_anylob.typ > generated/phr_blob.typ

echo Spooling NCLOB
gawk -f phr_anylob.typ.awk -v i_modus_operandi=nclob phr_anylob.typ > generated/phr_nclob.typ

popd
