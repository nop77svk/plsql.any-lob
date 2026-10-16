#!/bin/bash
set -o errtrace
set -o errexit
set -o pipefail

ScriptPath=$( dirname "$0" | sed 's/^\(.\):/\/cygdrive\/\1/' | sed 's/\\/\//gi' )
BfileDirectory="${PHR_ANYLOB_TEST_BFILE_DIRECTORY:-DATA_PUMP_DIR}"

pushd "${ScriptPath}"

echo Removing old scripts
rm -rf generated

for Modus in clob blob nclob
do
	echo Spooling ${Modus} test scripts
	mkdir -p "generated/phr_${Modus}"

	if [ "${Modus}" == "blob" ]
	then
		ReverseType=varchar2
	else
		ReverseType=raw
	fi

	for Template in templates/*.tst.tpl
	do
		Method=$( basename "${Template}" .tst.tpl )
		Method="${Method/reverse/${ReverseType}}"
		gawk -f phr_anylob.tst.awk -v i_modus_operandi=${Modus} -v i_template_dir=templates -v i_bfile_directory="${BfileDirectory}" "${Template}" > "generated/phr_${Modus}/phr_${Modus}.${Method}.tst"
	done
done

popd
