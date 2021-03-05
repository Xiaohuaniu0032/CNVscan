/home/fulongfei/miniconda3/bin/perl /data1/workdir/fulongfei/git_repo/CNVscan/bin/cal_depth.pl -bam /data3/Projects/panel889/210225_A00869_0418_BHWNFGDSXY/02_aln/210222048T.rmdup.bam -n 210222048T -bed /home/wangce/workdir/database/humandb/panel/889genes_20191225.bed -sbb /home/fulongfei/miniconda3/bin/sambamba -outdir /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T
/home/fulongfei/miniconda3/bin/perl /data1/workdir/fulongfei/git_repo/CNVscan/bin/add_gc.pl -bed /home/wangce/workdir/database/humandb/panel/889genes_20191225.bed -depth /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.targetcoverage.cnn -bedtools_bin /home/fulongfei/miniconda3/bin/bedtools -fa /data1/database/b37/human_g1k_v37.fasta -outdir /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T
/home/fulongfei/miniconda3/bin/python3 /data1/workdir/fulongfei/git_repo/CNVscan/bin/infer_sex.py -cov /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.targetcoverage.cnn -o /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/sex.txt
/home/fulongfei/miniconda3/bin/Rscript /data1/workdir/fulongfei/git_repo/CNVscan/bin/gc_correct.r /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.targetcoverage.cnn.with.gc.xls /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/sex.txt /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.targetcoverage.cnn.with.gc.xls.gc.corrected.xls
/home/fulongfei/miniconda3/bin/perl /data1/workdir/fulongfei/git_repo/CNVscan/bin/normalize.pl -d /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.targetcoverage.cnn.with.gc.xls.gc.corrected.xls -od /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T
/home/fulongfei/miniconda3/bin/perl /data1/workdir/fulongfei/git_repo/CNVscan/bin/make_ref_matrix.pl /home/fulongfei/workdir/git_repo/CNVscan/ref /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/ref_matrix.txt
/home/fulongfei/miniconda3/bin/perl /data1/workdir/fulongfei/git_repo/CNVscan/bin/cal_logR.pl /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.norm.xls /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/ref_matrix.txt /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.log2Ratio.xls
/home/fulongfei/miniconda3/bin/perl /data1/workdir/fulongfei/git_repo/CNVscan/bin/Gene_Level_CNV.pl -i /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.log2Ratio.xls -o /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.Gene_Level_CNV.xls
/home/fulongfei/miniconda3/bin/perl /data1/workdir/fulongfei/git_repo/CNVscan/bin/statQC.pl /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T/210222048T.depth.tmp /home/fulongfei/workdir/git_repo/CNVscan/test/210222048T