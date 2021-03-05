use strict;
use warnings;
use File::Bin qw/$Bin/;
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

my $rpt_list = "$Bin/db/report.gene.list";
die "can not find $rpt_list\n" if (!-e $rpt_list);

my %rpt_list_gene;
open IN, "$rptList" or die;
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
my $cmd = "python $Bin/bin/xlsx2csv.py $annotFile $csv";
system($cmd);

# check csv file
die "can not find $csv\n" if (!-e $csv);

# read csv file
my %gene_annot_info;








# output file
my $outfile = "$resdir/$name\.Gene_Level_CNV.Annot.xls";
open O, ">$outfile" or die;
print O "#SampleID\tGene\tChr\tStart\tEnd\tCopyNumber\tBinCount\tcnvType\treportCheck\tClinical_significance\tCancer_species\n";







