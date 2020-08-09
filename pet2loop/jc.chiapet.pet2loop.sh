#!/usr/bin/env bash
#
# Generate loop file using pet infile.
#
# Usage:   $0 <inf_pet> [ouf_loop] [EXT_BP]
# Default: $0 pet.X.txt loop.X.txt 500
# Infile: inf_pet
# Oufile: ouf_loop
#
# Jianhua Cao @ HZAU
# Last modified: 2018-4-11
# Ver 0.5
#
# DIR=$(cd $(dirname $0) && pwd)
source ~/bin/jc/jc.init.sh
CHRSP=$CHIAPET/jc.chiapet.chromSpliter.pl
CHRPL=$CHIAPET/jc.chiapet.pet2loopByChrom.pl

usage="$0 <inf_pet:txt> [ouf_loop:txt] [EXT_BP:500]"
if [ $# -lt 1 ]; then
	echo $usage
	exit 1
fi
inf_pet=$1 # e.g.: pet10.intra.txt
ouf_loop=${2:-'loop.'$inf_pet}
ext_bp=${3:-500}

### Split PET infile into tmp DIR by Chr.
echo [`date '+%F %T'`] Spliting PET by Chr. [ $inf_pet ] ...
${CHRSP} -i $inf_pet

tmpdir=${inf_pet}'.chr' # tmpdir created by SPLITER
if [[ ! -d $tmpdir ]]; then return 1; fi

cd $tmpdir
### PET2LOOP
for f in `ls |grep ^[1-9XY]`; do
	echo -n [`date '+%F %T'`] Generating Loops by PETs: $f ...
	${CHRPL} -p $f -e $ext_bp
	echo ' OK'
done
cat loop* >$ouf_loop && mv $ouf_loop .. && cd ..
rm -rf $tmpdir
