#!/bin/bash

##
# GNU tools have the priority when existing
DATE_TOOL="date"
if command -v gdate 1>/dev/null 2>&1
then
        DATE_TOOL="gdate"
fi

##
# Snapshot date
YEAR=$(${DATE_TOOL} "+%Y")
TODAY_DATE=$(${DATE_TOOL} "+%Y%m%d")
TODAY_DATE_HUMAN=$(${DATE_TOOL})

##
# Archive folder
ARCH_DIR="archives/${YEAR}"
if [ ! -d ${ARCH_DIR} ]
then
	mkdir -p ${ARCH_DIR}
fi

##
# Retrieve the latest file
POR_FILE_PFX="por_all"
SNPSHT_DATE="$(ls ${POR_FILE_PFX}_????????.{csv,.csv.bz2} 2> /dev/null)"
if [ "${SNPSHT_DATE}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${SNPSHT_DATE}; do echo > /dev/null; done
	SNPSHT_DATE="$(echo ${myfile} | sed -E "s/${POR_FILE_PFX}_([0-9]+)\.csv.*/\1/" | xargs basename)"
else
	echo
	echo "[$0:$LINENO] No Geonames-derived POR list CSV dump can be found."
	echo "Expecting a file named like '${POR_FILE_PFX}_YYYYMMDD.csv'"
	echo
	exit -1
fi
if [ "${SNPSHT_DATE}" != "" ]
then
	SNPSHT_DATE_HUMAN="$(${DATE_TOOL} -d ${SNPSHT_DATE})"
else
	SNPSHT_DATE_HUMAN="$(${DATE_TOOL} --date='yesterday')"
fi

#
echo "On the remote host:"
echo "./getDataFromGeonamesWebsite.sh && ./aggregateGeonamesPor.sh && ./extract_por_from_geonames.sh && ./extract_por_from_geonames.sh --clean && cp -f por_intorg_${TODAY_DATE}.csv dump_from_geonames.csv && bzip2 por_intorg_${TODAY_DATE}.csv"
echo "time diff -Naur ${POR_FILE_PFX}_${SNPSHT_DATE}.csv ${POR_FILE_PFX}_${TODAY_DATE}.csv > ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv"
echo "bzip2 ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv"
echo "ls -laFh --color por*"
echo
echo "On the local host:"
echo "rsync -av myuser@remote:~/dev/geo/opentraveldata/tools/por_intorg_${TODAY_DATE}.csv.bz2 ./"
echo "rsync -av myuser@remote:~/dev/geo/opentraveldata/tools/${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv.bz2 ./"
echo "bunzip2 -k por_intorg_${TODAY_DATE}.csv.bz2 && mv por_intorg_${TODAY_DATE}.csv dump_from_geonames.csv && ln -s dump_from_geonames.csv por_intorg_${TODAY_DATE}.csv && rm -f por_intorg_${SNPSHT_DATE}.csv && mv por_intorg_${TODAY_DATE}.csv.bz2 ${ARCH_DIR}"
echo "bunzip2 ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv.bz2"
echo "patch -p0 --dry-run < ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv"
echo "patch -p0 < ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv && mv ${POR_FILE_PFX}_${SNPSHT_DATE}.csv ${POR_FILE_PFX}_${TODAY_DATE}.csv && rm -f ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv"
echo "ls -laFh por*"
echo
echo "Still on the laptop, usual workflow, for instance:"
echo "* In the tools/ sub-directory:"
echo "./make_optd_por_public.sh"
echo "./make_optd_por_public.sh --clean"
echo "* In the opentraveldata/ sub-directory:"
echo "git diff"
echo "git add optd_por_public.csv optd_por_public_all.csv"
echo "git diff --cached optd_por_public_all.csv|grep "^+"|wc -l"
echo "git commit -m \"[POR] Integrated the last updates of Geonames; nnn POR have been updated\""
echo "git push"
echo
echo "On the remote host again:"
echo "mv por_intorg_${TODAY_DATE}.csv.bz2 ${ARCH_DIR}/ && rm -f ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv.bz2 ${POR_FILE_PFX}_${SNPSHT_DATE}.csv"
echo "ls -laFh --color por*"


