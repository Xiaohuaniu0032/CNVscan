use strict;
use warnings;
use FindBin qw/$Bin/;
use File::Basename;
#use Spreadsheet::ParseExcel; # https://metacpan.org/pod/Spreadsheet::ParseExcel
#use Spreadsheet::ParseXLSX; # https://metacpan.org/pod/Spreadsheet::ParseXLSX


my ($cnvRes,$annotFile) = @ARGV;

#
#	注释是否报出
#	报出规则:
#		1) bin < 5 不报出
#		2) 常见< 4,不常见< 6 的不报出 (在report.gene.list中的为常见)
#
#

my $DIR = dirname($Bin);
my $rpt_list = "$DIR/db/report.gene.list";
die "can not find $rpt_list\n" if (!-e $rpt_list);

my %rpt_list_gene;
open IN, "$rpt_list" or die;
while (<IN>){
    chomp;
    my @arr = split /\s/;
    for my $g (@arr){
        $rpt_list_gene{$g} = 1;
    }
}
close IN;

my $resdir = dirname($cnvRes);
my $name = (split /\./, basename($cnvRes))[0];


# convert XLSX into CSV file
my $csv = "$resdir/CNV_annotation.csv";
my $cmd = "python $DIR/bin/xlsx2csv.py $annotFile $csv";
system($cmd);

# check csv file
die "can not find $csv\n" if (!-e $csv);

# read csv file
my %gene_annot_info;
open IN, "$csv" or die;
<IN>;
while (<IN>){
    chomp;
    my @arr = split /\,/;
    $gene_annot_info{$arr[0]} = "$arr[1]\t$arr[2]";
}
close IN;


# output file
my $outfile = "$resdir/$name\.Gene_Level_CNV.xls";
open O, ">$outfile" or die;
print O "#SampleID\tGene\tChr\tStart\tEnd\tCopyNumber\tBinCount\treportCheck\tClinical_significance\tCancer_species\n";



open IN, "$cnvRes" or die;
<IN>;
while (<IN>){
    chomp;
    my @arr = split /\t/;

    my (@if_report,$clin_signif,$cancer_type);

    # check bin count
    if ($arr[-2] >= 5){
        # check copy number
        if (exists $rpt_list_gene{$arr[1]}){
            # need >= 4
            if ($arr[-3] >= 4){
                push @if_report, "PASS";
            }else{
                push @if_report, "常见基因拷贝数需要>=4";
            }
        }else{
            # need >= 6
            if ($arr[-3] >= 6){
                push @if_report, "PASS";
            }else{
                push @if_report, "非常见基因拷贝数需要>=6";
            }
        }
    }else{
        push @if_report, "bin count<5";

        # check copy number
        if (exists $rpt_list_gene{$arr[1]}){
            # need >= 4
            if ($arr[-3] < 4){
                push @if_report, "常见基因拷贝数需要>=4";
            }
        }else{
            # need >= 6
            if ($arr[-3] < 6){
                push @if_report, "非常见基因拷贝数需要>=6";
            }
        }
    }

    if (exists $gene_annot_info{$arr[1]}){
        my @val = split /\t/, $gene_annot_info{$arr[1]};
        $clin_signif = $val[0];
        $cancer_type = $val[1];
    }else{
        $clin_signif = '.';
        $cancer_type = '.';
    }

    my $if_report = join ";", @if_report;

    pop @arr;
    my $line = join "\t", @arr;
    print O "$line\t$if_report\t$clin_signif\t$cancer_type\n";
}
close IN;
close O;

# rm csv file
if (-e $csv){
    print "[INFO]: csv file will be removed\n";
    `rm $csv`;
}










