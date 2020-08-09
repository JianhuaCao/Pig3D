#!/usr/bin/env bash
#
# Plot heatmap using pet info file (tab-delim txt, 10-col).
#
# Jianhua Cao @ HZAU
# Last modified: 2019-7-30
# Ver0.2
#
usage () {
  echo -e "pet info file (10-col, tab txt) -> heatmap (pdf)"
  echo -e "Usage: `basename $0` [Option] <pet.txt>"
  echo -e "\t-c\tChrom, {all|1..18,X}, def: all"
  echo -e "\t-s\tStart location (kb),  def: 0.001, 1 bp (min)."
  echo -e "\t-e\tEnd location (kb),    def: 400000, 400 Mb (max, full)."
  echo -e "\t-r\tResolution (kb),      def: 100 Kb."
  echo -e "\t-l\tHeatmap Color code,   def: cjh.col4 (defined in gen_map.R)."
  echo -e "\t-h\tHelp"

  exit 0
}

pet2hmap () {
  local pet chr start end res color
  local i j
  pet=$inf_pet
  chr=$chrom
  start=$start_kb
  end=$end_kb
  res=$res_kb
  color=$hmap_color

  if [[ $chr = 'all' ]]; then
        for i in $(seq 18) X; do
            echo [INFO] Heatmating Chr. $i ...
            ${GenMat} -i $pet -c $i -s 0.001 -e 400000 -r $res
        done
    else
        echo [INFO] Heatmating Chr. $chr ...
        ${GenMat} -i $pet -c $chr -s $start -e $end -r $res
    fi

  local files_mat=("`ls heatmat*`")
  echo [INFO] Heatmaping [ ${#files_mat[*]} ] mat. [ Color: $color ]
  for j in ${files_mat[*]}; do
    echo [INFO] $j ...
    ${GenMap} $j $color
  done
  rm heatmat*

  return 0
}

### Main
source ~/bin/jc/jc.init.sh

# Constant
DIR=$(cd $(dirname $0) && pwd)
GenMat=$DIR/jc.chiapet.pet2hmap.gen_mat.pl
GenMap=$DIR/jc.chiapet.pet2hmap.gen_map.R

# Initialize defaults
chrom='all'    # Chrom {all | 1..18,X}, def: all
start_kb=0.001 # Kb, def: 1 bp (min)
end_kb=400000  # Kb, def: 400 Mb (max, full length)
res_kb=100     # Resolution, def: 100 Kb
hmap_color='cjh.col4' # HeatMapColor code defined in gen_map.R

while getopts :c:s:e:r:l:h opt; do
  case $opt in
    c ) chrom=$OPTARG;;
    s ) start_kb=$OPTARG;;
    e ) end_kb=$OPTARG;;
    r ) res_kb=$OPTARG;;
    l ) hmap_color=$OPTARG;;
    h ) usage;;
    : ) echo "Option -$OPTARG requires an argument."; usage;;
    \?) echo -e "Option -$OPTARG not allowed."; usage;;
  esac
done
shift $((OPTIND-1))

if [[ $# -lt 1 ]]; then usage; fi
inf_pet=$1 # pet info infile (10-col, tab-txt)
if [[ ! -f $inf_pet || ! $inf_pet =~ ^pet.*txt$ ]]; then return 1; fi
pet2hmap; msg $?
