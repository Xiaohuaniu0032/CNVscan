import sys
import configparser
import argparse
import os
#import pandas as pd

def parse_args():
    AP = argparse.ArgumentParser("detect somatic copy number from capture NGS data")
    AP.add_argument('-bam',help='bam file',dest='bam')
    AP.add_argument('-bed',help='bed file',dest='bed')
    AP.add_argument('-n',help='sample name',dest='name')
    AP.add_argument('-fa',help='fasta file',dest='fasta',default='/data1/database/b37/human_g1k_v37.fasta')
    AP.add_argument('-m',help='analysis mode. can be [ref|cnv]',default='ref',dest='mode')
    AP.add_argument('-ref',help='control dir',dest='ref')
    AP.add_argument('-annot',help='cnv gene annot file (clinic info,cancer type)',default='/data1/workdir/wangce/database/humandb/ctDNA_report/CNV_annotation.xlsx',dest='annot')
    AP.add_argument('-od',help='out dir',dest='outdir')

    return AP.parse_args()
    



def main():
    args = parse_args()
    bin_dir = os.path.split(os.path.realpath(__file__))[0]
    config_file = bin_dir + '/config.ini'
    #print(config_file)
    config = configparser.ConfigParser()
    config.read(config_file)

    # software
    perl = config['software']['perl']
    py3  = config['software']['python3']
    bedtools = config['software']['bedtools']
    sambamba = config['software']['sambamba']
    rscript  = config['software']['Rscript']
    hg19 = config['db']['hg19']

    bin_dir = os.path.split(os.path.realpath(__file__))[0]

    runsh = args.outdir + '/cnv.%s.sh' % (args.name)
    #print("analysis mode is: ref...")
    f = open(runsh,'w')

    # cal depth
    cmd = "%s %s/bin/cal_depth.pl -bam %s -n %s -bed %s -sbb %s -outdir %s" % (perl,bin_dir,args.bam,args.name,args.bed,sambamba,args.outdir)
    f.write(cmd+'\n')

    # add gc
    depth_file = args.outdir + "/%s.targetcoverage.cnn" % (args.name)
    cmd = "%s %s/bin/add_gc.pl -bed %s -depth %s -bedtools_bin %s -fa %s -outdir %s" % (perl,bin_dir,args.bed,depth_file,bedtools,args.fasta,args.outdir)
    f.write(cmd+'\n')

    # infer sex
    sex_of = "%s/sex.txt" % (args.outdir)
    cmd = "%s %s/bin/infer_sex.py -cov %s -o %s" % (py3,bin_dir,depth_file,sex_of)
    f.write(cmd+'\n')

    # gc correct
    cmd = "%s %s/bin/gc_correct.r %s/%s.targetcoverage.cnn.with.gc.xls %s %s/%s.targetcoverage.cnn.with.gc.xls.gc.corrected.xls" % (rscript,bin_dir,args.outdir,args.name,sex_of,args.outdir,args.name)
    f.write(cmd+'\n')

    # lib normalize
    cmd = "%s %s/bin/normalize.pl -d %s/%s.targetcoverage.cnn.with.gc.xls.gc.corrected.xls -od %s" % (perl,bin_dir,args.outdir,args.name,args.outdir)
    f.write(cmd+'\n')

    if args.mode == 'ref':
        print("your analysis mode is -m <ref>")
        pass
    else:
        # check if -ref and -annot args are provided
        if args.ref and args.annot:
            pass
        else:
            print("[Error]: you need to specify -ref and -annot when your -m is cnv! program will exit.")
            exit()

        # make ref matrix
        ref_mat = "%s/ref_matrix.txt" % (args.outdir)
        cmd = "%s %s/bin/make_ref_matrix.pl %s %s" % (perl,bin_dir,args.ref,ref_mat)
        f.write(cmd+'\n')

        # calculate logR
        logR = "%s/%s.log2Ratio.xls" % (args.outdir,args.name)
        norm_file = "%s/%s.norm.xls" % (args.outdir,args.name)
        cmd = "%s %s/bin/cal_logR.pl %s %s %s" % (perl,bin_dir,norm_file,ref_mat,logR)
        f.write(cmd+'\n')

        # calculate gene-level copy number
        # out file is *.Gene_Level_CNV.tmp.xls
        cnvfile = "%s/%s.Gene_Level_CNV.tmp.xls" % (args.outdir,args.name)
        cmd = "%s %s/bin/Gene_Level_CNV.pl -i %s -o %s" % (perl,bin_dir,logR,cnvfile)
        f.write(cmd+'\n')

        # annot if report
        # out file is *.Gene_Level_CNV.xls
        cmd = "perl %s/bin/annot_if_report.pl %s %s" % (bin_dir,cnvfile,args.annot)
        f.write(cmd+'\n')

        # cal QC (0.2X/0.5X)
        # outfile is *.CNV.QC.xls
        depth = "%s/%s.depth.tmp" % (args.outdir,args.name)
        cmd = "%s %s/bin/statQC.pl %s %s" % (perl,bin_dir,depth,args.outdir)
        f.write(cmd+'\n')


    f.close()

if __name__ == "__main__":
    main()

