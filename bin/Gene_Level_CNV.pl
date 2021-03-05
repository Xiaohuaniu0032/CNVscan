use strict;
use warnings;
use Getopt::Long;

my ($logR,$gain_cutoff,$loss_cutoff,$target_num_cutoff,$cnv_pct_cutoff,$outfile);

GetOptions(
    "in|i:s" => \$logR,                    # Need
    "gain:f" => \$gain_cutoff,             # Default: 2.7
    "loss:f" => \$loss_cutoff,             # Default: 1.3
    "tnum:i" => \$target_num_cutoff,       # Default: 3
    "pct:f" => \$cnv_pct_cutoff,           # Default: 70%
    "o:s" => \$outfile,                    # Need
    ) or die "unknown args\n";

# input file: *.log2Ratio.xls
# output file: *.Gene_Level_CNV.xls

# filter rules:
# 1. skip gene with < 3 targets
# 2. skip target with low depth (<=30X)


# default value
if (not defined $gain_cutoff){
    $gain_cutoff = 2.7;
}

if (not defined $loss_cutoff){
    $loss_cutoff = 1.3;
}

if (not defined $target_num_cutoff){
    $target_num_cutoff = 3;
}

if (not defined $cnv_pct_cutoff){
    $cnv_pct_cutoff = 0.7; # 70%
}


open O, ">$outfile" or die;
#print O "sample\tgene\tchr\tstart\tend\tcopynumber\tcnvtype\n";
print O "#Sample\tGene\tChr\tStart\tEnd\tCopyNumber\tBinCount\tcnvType\n";


my %geneStartEnd;
my %geneChr;
my %geneCN;
my @genes;
my @sampleName;

open IN, "$logR" or die;
<IN>;
while (<IN>){
    chomp;
    my @arr = split /\t/;
    my $cn;
    
    push @{$geneCN{$arr[4]}}, $arr[-1]; # cn maybe NA

    $geneChr{$arr[4]} = $arr[1]; # gene's chr
 
    push @{$geneStartEnd{$arr[4]}}, $arr[2]; # pos
    push @{$geneStartEnd{$arr[4]}}, $arr[3]; # pos
    
    push @genes, $arr[4]; # gene list
    push @sampleName, $arr[0];

}
close IN;

my %geneRegion;
my %geneFlag;
my @uniqGenes;

# get uniq gene list and its start/end pos
for my $gene (@genes){
    if (!exists $geneFlag{$gene}){
        $geneFlag{$gene} = 1;
        my @reg = sort {$a <=> $b} @{$geneStartEnd{$gene}};
        $geneRegion{$gene}{"start"} = $reg[0];
        $geneRegion{$gene}{"end"} = $reg[-1];
        push @uniqGenes, $gene;
    }else{
        next;
    }
}

for my $gene (@uniqGenes){
    #print "$gene\n";

    # how many target
    my @cn = @{$geneCN{$gene}};
    my $target_n = scalar(@cn);

    # skip gene with only 1 or 2 targets
    if ($target_n < 3){
        print "$gene has $target_n target(s) [need >=3 by default], this gene will be skipped\n";
        next;
    }

    # how may target's value is NA
    my $na_num = 0;
    my @eff_cn;

    for my $cn (@cn){
        my $cn_str = "$cn"; # as string
        if ($cn_str eq 'NA'){
            $na_num += 1;
        }else{
            push @eff_cn, $cn; # eff cn
        }
    }

    # skip gene with > 2 NA targets
    if ($na_num > 2){
        print "$gene has $na_num NA target(s) [NA target num should <= 2 by default], this gene will be skipped\n";
        next;
    }

    # how many eff target
    my $eff_n = $target_n - $na_num;
    my $eff_pct = sprintf "%.2f", $eff_n/$target_n;

    # skip gene with < 3 eff target
    if ($eff_n < 3){
        print "$gene has $eff_n eff target [non-NA num should be >=3 by default], this gene will be skipped\n";
        next;
    }

    my $gain_num = 0;
    my $loss_num = 0;

    for my $cn (@eff_cn){
        if ($cn >= $gain_cutoff){
            $gain_num += 1;
        }

        if ($cn <= $loss_cutoff){
            $loss_num += 1;
        }
    }

    my ($gain_pct,$loss_pct) = (0,0);
    $gain_pct = sprintf "%.2f", $gain_num/scalar(@eff_cn);
    $loss_pct = sprintf "%.2f", $loss_num/scalar(@eff_cn);

    my $sum_cn;
    for my $cn (@eff_cn){
        $sum_cn += $cn;
    }

    my $mean_cn = sprintf "%.2f", $sum_cn/scalar(@eff_cn);


    my $cnvtype;
    if ($gain_pct >= $cnv_pct_cutoff and $mean_cn >= $gain_cutoff){
        $cnvtype = "gain"; # >= 2.7
    }elsif ($loss_pct >= $cnv_pct_cutoff and $mean_cn <= $loss_cutoff){
        $cnvtype = "loss"; # <= 1.3
    }else{
        $cnvtype = "normal";
    }

    print "$gene\t\($gain_num\,$loss_num\)\|$eff_n\|$target_n\|$na_num\t$mean_cn\t$cnvtype\n";

    my $start = $geneRegion{$gene}{"start"};
    my $end = $geneRegion{$gene}{"end"};

    print O "$sampleName[0]\t$gene\t$geneChr{$gene}\t$start\t$end\t$mean_cn\t$target_n\t$cnvtype\n";
}

close O;

