#!/usr/bin/env bash
#
# Functions for wrapper use
#
# Jianhua Cao @ HZAU
# Last modified: 2017-11-24
# Ver0.3
#
########## Global Settings: DIR
#
BIN=~/bin
JC=$BIN/jc
LIB=$JC/lib
CHIAPET=$JC/chiapet

########## Public Environment
#
# Softwares & Tools, JAVA JAR
JAR_PICARD=$BIN/picard/picard.jar
JAR_JUICER=$BIN/juicer
JAR_CHRHMM=$BIN/ChromHMM
JAR_WEBIN=$BIN/webin-cli-3.0.1.jar

#
CUTADP=cutadapt
BOWTIE=bowtie2
SAMTOOLS=samtools
BEDTOOLS=bedtools
BCFTOOLS=bcftools
IGVTOOLS=igvtools
MACS=macs2
BDG2BW=bedGraphToBigWig
SOAP=SOAPdenovo-127mer
SOAPFUSION=SOAPdenovo-fusion

#
# Private Script Registration
# XSAM_CHR=${PUB}/cjh.pub.xsam_chr.pl
# BAM2RC=${DIR_ROOT}/rna/cjh.rna.bam2rawcounts.R
# pet2hmap: generate heatmap using pet.intra.txt
# GEN_MAT=${ROOT_PIP}/pet2hmap/cjh.3d.gen_mat.pl # generate heat matrix (hmat)
# GEN_MAP=${ROOT_PIP}/pet2hmap/cjh.3d.gen_map.R  # generate heatmap using hmat
# UMP=$LIB/jc.sam.ump.pl
# DDP=$LIB/jc.sam.ddp.pl


########## Constrant & Declaration
#
# Adapter (ADP)
#
# TruSeq ADP full length
# ADP_TRUSEQ_FWD='AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC' # 34-bp
# ADP_TRUSEQ_REV='AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT' # 58-bp

# ADP_TRUSEQ_REV_TRUNC='AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA' # (truncated R2, 34-bp)
# ADP_TRUSEQ_FWD='AGATCGGAAGAGCACACGTCTGAAC' # 25-bp
# ADP_TRUSEQ_REV='AGATCGGAAGAGCGTCGTGTAGGGA' # 25-bp
ADP_TRUSEQ_FWD='AGATCGGAAGAGCACACGTCTGAACTCCAGTCA' # 33-bp, cutadapt use
ADP_TRUSEQ_REV='AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT' # 33-bp

# ADP_NEXTERA_FWD='CTGTCTCTTATACACATCTCCGAGCCCACGAGAC' # NexTera AdapterR1
# ADP_NEXTERA_REV='CTGTCTCTTATACACATCTGACGCTGCCGACGA' # NexTera AdapterR2
#



# BridgeLinker (BRL), preceding 'A' and tailing 'T' added!
# Multiplex BRL, totally 20-bp
BLGA_FWD='ACGCGATATCTTATCTGACT' # original BRL
BLGA_REV='AGTCAGATAAGATATCGCGT'
BLTG_FWD='ACGCTGTATCTTATCTGACT'
BLTG_REV='AGTCAGATAAGATACAGCGT'
BLAG_FWD='ACGCAGTATCTTATCTGACT'
BLAG_REV='AGTCAGATAAGATACTGCGT'
BLCA_FWD='ACGCCATATCTTATCTGACT'
BLCA_REV='AGTCAGATAAGATATGGCGT'

# Tn5 mosaic end (ME) sequence: 'CTGTCTCTTATACACATCT' # 19-bp
TN5ME_CIRCLE='CTGTCTCTTATACACATCTAGATGTGTATAAGAGACAG' # 38-bp, All-seq used !

# In-Fusion Homology Arm (ARM)
ARM_FWD='TCGACGAATTCGGCC' # 15-bp
ARM_REV='CCGGTGCATGCTCTA' # 15-bp
#
EXT_FWD='GTCACTCGACGAATTCGGCC' # extension homology arm (fwd)
EXT_REV='AGTGTCCGGTGCATGCTCTA' # extension homoloyg arm (rev)
# ADP=(
#   [0]='AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC' # TruSeq AdapterR1
#   [1]='AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT' # TruSeq AdapterR2
#   # [1]='AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA' # TruSeq AdapterR2 (truncated)
#   [2]='CTGTCTCTTATACACATCTCCGAGCCCACGAGAC' # NexTera AdapterR1
#   [3]='CTGTCTCTTATACACATCTGACGCTGCCGACGA' # NexTera AdapterR2
#   [4]='ACGCGATATCTTATCTGACT' # ChIA-PET Bridge Linker R1 (forward)
#   [5]='AGTCAGATAAGATATCGCGT' # ChIA-PET Bridge Linker R2 (reverse)
#   )
#
# BRL=(
#   # [0]='ACGCGATATCTTATCTGACT' # ChIA-PET Bridge Linker R1 (forward)
#   # [1]='AGTCAGATAAGATATCGCGT' # ChIA-PET Bridge Linker R2 (reverse)
#   [0]='TCGACGAATTCGGCC' # In-Fusion Homology Arm R1 (forward)
#   [1]='CCGGTGCATGCTCTA' # In-Fusion Homology Arm R2 (reverse)
#   )


########## Genome Assembly
#
# Pig
#
GENOME=~/genome/ssc/11\.1 # Genome ROOT DIR
# GENOME_IDX=$GENOME/bt/Sus_scrofa.Sscrofa11.1.dna.toplevel # Bowtie2 index
GENOME_IDX=~/genome/pSV3-neo/bt/pSV3-neo

# GSIZE=2.44e9 # genome size, ssc11.1
GSIZE=2.5e9 # UCSC: fetchChromSizes susScr11 > susScr11.chrom.sizes
# GENOME_FA=$GENOME/fa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa # FASTA genome
# GENOME_GTF=$GENOME/gtf/Sus_scrofa.Sscrofa11.1.90.chr.cjh.gtf # Ensembl GTF annotation
GENOME_SIZE=$GENOME/ssc11.1.chrom.sizes # Genome size file: mandatory suffix: chrom.sizes
CHROM_SIZES=$GENOME/ssc11.1.chrom.sizes
#
# Mouse
#
# GENOME=~/genome/mmu/GRCm38
#
# GENOME_IDX=$GENOME/bt/Mus_musculus.GRCm38.dna.primary_assembly
#
# Genome size file: mandatory suffix: chrom.sizes
# bedtools genomecov -g ${GENOME_SIZE}
# java -Xmx16g -jar ${JAR_JUICER} pre $oufpre $oufhic ${CHROM_SIZES}
#
# GENOME_SIZE=$GENOME/GRCm38.chrom.sizes
# CHROM_SIZES=$GENOME/GRCm38.chrom.sizes
# GSIZE=2.73e9 # UCSC: fetchChromSizes mm10 > mm10.chrom.sizes

show_msg () { # Show error message according to code (0~255)
  code=$1

  local MSG=(
    [0]='OK.'
    [1]='Infile exception.'
    [2]='Unexpected mode. {pe|se}'
    [3]='Unexpected tech. {ts|nx}'
    [4]='Unexpected class. {chip|rna|chia}'
    [5]='Unexpected file.'
    [6]='Unexpected sign.'
    )

  if [[ $code -gt 0 ]]; then
    echo ${MSG[$code]}
    exit 0
  fi

  return 0
}

# green(){
#   echo -e " [ \033[32m$1\033[0m ]"
# }

# red(){
#   echo -e " [ \033[31m$1\033[0m ]"
# }

# msg () {
#   if [[ $1 -gt 0 && $1 < ${#MSG[@]} ]]; then red "${MSG[$1]}";fi
# }

msg () (
  code=$1

  MSG=(
    [0]='OK'
    [1]='Infile exception'
    [2]='Unexpected mode {pe|se}'
    [3]='Unexpected tech {ts|nx}'
    [4]='Unexpected class {chip|rna|chia}'
    [5]='Unexpected file'
    [6]='Unexpected sign'
    )

  green () { echo -e " [ \033[32m$1\033[0m ]"; } # Don't miss semi-colon(;);
  red ()   { echo -e " [ \033[31m$1\033[0m ]"; }

  if [[ $code -eq 0 ]]; then
    green "${MSG[$code]}"
  elif [[ $code -gt 0 && $1 -lt ${#MSG[@]} ]]; then
    red "${MSG[$code]}"
  else
    red "Unexpected msg code"
  fi
)
