bam='/data3/Projects/panel889/210225_A00869_0418_BHWNFGDSXY/02_aln/210222048T.rmdup.bam'
bed='/home/wangce/workdir/database/humandb/panel/889genes_20191225.bed'
name='210222048T'
ref='/home/fulongfei/workdir/git_repo/CNVscan/ref'

if [ ! -d $PWD/$name ];then
	mkdir $PWD/$name
fi

python ../CNVscan.py -bam $bam -bed $bed -n $name -m cnv -od $PWD/$name -ref $ref
