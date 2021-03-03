use strict;
use warnings;
use File::Basename;


# https://www.qiagen.com/us/applications/next-generation-sequencing/dna-sequencing
# 2021/3/3
#
#
#
my ($depth,$outdir) = @ARGV; # *.depth.tmp

my $name = (split /\./, basename($depth))[0];
my $of = "$outdir/$name\.CNV.QC.xls";

open O, ">$of" or die;
print O "sample\tmean_depth\t0.2X_mean_cov\t0.5X_mean_cov\n";

# cal mean depth
my @depth;
open IN, "$depth" or die;
<IN>;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	push @depth, $arr[-2];
}
close IN;

my $target_n = @depth;

my $sum_depth = 0;
for (@depth){
	$sum_depth += $_;
}

my $mean_depth;
if ($sum_depth == 0){
	$mean_depth = 0;
}else{
	$mean_depth = sprintf "%.2f", $sum_depth/$target_n;
}

# cal 0.2X / 0.5X
my $x1 = 0.2 * $mean_depth;
my $x2 = 0.5 * $mean_depth;

my ($x1_cov_n,$x2_cov_n) = (0,0); # 0.2X/0.5X
open IN, "$depth" or die;
<IN>;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	if ($arr[-2] >= $x1){
		$x1_cov_n += 1;
	}

	if ($arr[-2] >= $x2){
		$x2_cov_n += 1;
	}
}
close IN;

my $x1_pct = sprintf "%.2f", $x1_cov_n / $target_n; # 99.5%
my $x2_pct = sprintf "%.2f", $x2_cov_n / $target_n; # 96%

print O "$name\t$mean_depth\t$x1_pct\t$x2_pct\n";
close O;

