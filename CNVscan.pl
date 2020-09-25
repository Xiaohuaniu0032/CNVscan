use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use FindBin qw/$Bin/;
use List::Util qw(sum);
use POSIX qw(ceil);
use POSIX qw(floor);
use Data::Dumper;
use Config::Tiny;

my ($bam,$bed,$name,$mode,$outdir);
GetOptions(
    "bam:s" => \$bam,               # Need
    "bed:s" => \$bed,               # Need
    "name|n:s" => \$name,           # Need
    "m:s" => \$mode,                # default:cnv <mode can be [cnv|ref]>
    "od:s" => \$outdir,             # Need             
    ) or die "unknown args\n";

# default value
if (not defined $mode){
    $mode = "cnv";
}

# parse config.ini file
my $cfg_f = "$Bin/config.ini";
die "can not find config.ini under $Bin\n" if (!-e $cfg_f);
my $config = Config::Tiny->read ($cfg_f,"utf-8");

my $perl = $config->{software}{perl};
my $py3 = $config->{software}{python3};
my $sambamba = $config->{software}{sambamba};
my $bedtools = $config->{software}{bedtools};
my $fa = $config->{db}{hg19};
my $Rscript = $config->{software}{rscript};

# 

if ($mode eq "ref"){
    my $runsh = "$outdir/ref\.$name\.sh";
    open O, ">$runsh" or die;
    print "analysis mode is: ref...\n";

    # calculate depth
    my $cmd = "$perl $Bin/bin/cal_depth.pl -bam $bam -n $name -bed $bed -sbb $sambamba -outdir $outdir";
    print O "$cmd\n";

    # add gc
    my $depth_f = "$outdir/$name\.targetcoverage.cnn";
    $cmd = "$perl $Bin/bin/add_gc.pl -bed $bed -depth $depth_f -bedtools_bin $bedtools -fa $fa -outdir $outdir";
    print O "$cmd\n";

    # infer sex
    $cmd = "$py3 $Bin/bin/infer_sex.py -cov $outdir/$name\.targetcoverage.cnn -o $outdir/sex.txt";
    print O "$cmd\n";

    # gc correction
    my $sex_file = "$outdir/sex.txt";
    $cmd = "$Rscript $Bin/bin/gc_correct.r $outdir/$name\.targetcoverage.cnn.with.gc.xls $sex_file $outdir/$name\.targetcoverage.cnn.with.gc.xls.gc.corrected.xls";
    print O "$cmd\n";

    # lib normalize
    $cmd = "$perl $Bin/bin/normalize.pl -d $outdir/$name\.targetcoverage.cnn.with.gc.xls.gc.corrected.xls -od $outdir";
    print O "$cmd\n";

    close O;

}else{
    my $runsh = "$outdir/cnv\.$name\.sh";
    open O, ">$runsh" or die;
    print "analysis mode is: cnv...\n";

    # calculate depth
    my $cmd = "$perl $Bin/bin/cal_depth.pl -bam $bam -n $name -bed $bed -sbb $sambamba -outdir $outdir";
    print O "$cmd\n";

    # add gc
    my $depth_f = "$outdir/$name\.targetcoverage.cnn";
    $cmd = "$perl $Bin/bin/add_gc.pl -bed $bed -depth $depth_f -bedtools_bin $bedtools -fa $fa -outdir $outdir";
    print O "$cmd\n";

    # infer sex
    $cmd = "$py3 $Bin/bin/infer_sex.py -cov $outdir/$name\.targetcoverage.cnn -o $outdir/sex.txt";
    print O "$cmd\n";

    # gc correction
    my $sex_file = "$outdir/sex.txt";
    $cmd = "$Rscript $Bin/bin/gc_correct.r $outdir/$name\.targetcoverage.cnn.with.gc.xls $sex_file $outdir/$name\.targetcoverage.cnn.with.gc.xls.gc.corrected.xls";
    print O "$cmd\n";

    # lib normalize
    $cmd = "$perl $Bin/bin/normalize.pl -d $outdir/$name\.targetcoverage.cnn.with.gc.xls.gc.corrected.xls -od $outdir";
    print O "$cmd\n";

    # cal logR
    $cmd = "$perl $Bin/bin/cal_logR.pl";
    print O "$cmd\n";

    close O;
}

