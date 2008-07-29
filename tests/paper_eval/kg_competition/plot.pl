#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Std;

my %options=();
getopts("w",\%options);
my $workstation = 0; $workstation = $options{w} if defined($options{w});

defined($ARGV[0]) || die "Must specify run names";
my @runnames = @ARGV; # -> column names

my @names = ("Bowtie -n 1",
             "Maq -n 1",
             "Soap -v 1",
             "Bowtie",
             "Maq",
             "Soap");

system("cp headerinc.tex kg.tex") == 0 || die ("Must have headerinc.tex");
open(KG, ">>kg.tex") || die "Could not open >>kg.tex";
print KG "\\begin{document}\n";
print KG "\\begin{table}[tp]\n";
print KG "\\scriptsize\n";
#print KG "\\begin{tabular}{lrrrrr}";
print KG "\\begin{tabular}{lrrrr}";
if($workstation) {
	print KG "\\multicolumn{5}{c}{2.4 GHz Intel Core 2 workstation with 2 GB of RAM}\\\\\n";
} else {
	print KG "\\multicolumn{5}{c}{2.4 GHz AMD Opteron 850 server with 32 GB of RAM}\\\\\n";
}
print KG "\\toprule\n";
#print KG " & \\multirow{2}{*}{CPU Time} & Wall clock & Bowtie  & \\multicolumn{2}{c}{Reads mapped} \\\\\n";
#print KG " &                            & time       & Speedup & Overall    & w/r/t Bowtie \\\\[3pt]\n";
print KG " & \\multirow{2}{*}{CPU Time} & Wall clock & Bowtie  & Reads  \\\\\n";
print KG " &                            & time       & Speedup & mapped \\\\[3pt]\n";
print KG "\\toprule\n";

my $bowtieSecs = 0;
my $bowtiePct = 0;
my $rows = 0;
for(my $ni = 0; $ni <= $#runnames; $ni++) {
	my $n = $runnames[$ni];
	next if $n =~ /^-/; # No results for this tool; don't print a row
	# Print \midrule before all rows except the first
	if($rows > 0) {
		print KG "\\midrule\n";
	}
	$rows++;
	my $l = readfline("whole.results.$n.txt", 0);
	my @ls = split(/,/, $l);
	my $rt = toMinsSecsHrs($ls[1]);
	my $wrt = toMinsSecsHrs($ls[2]);
	my $pct = trim($ls[3]);
	my $isBowtie = ($n =~ /bowtie/i);
	$bowtieSecs = $ls[2] if $isBowtie;
	$bowtiePct = $pct if $isBowtie;
	my $speedup = ($isBowtie ? "-" : sprintf("%2.1fx", $ls[2] * 1.0 / $bowtieSecs));
	my $moreReads = ($isBowtie ? "-" : sprintf("%2.1f\\%%", abs($pct - $bowtiePct) * 100.0 / $bowtiePct));
	my $moreReadsSign = ($pct >= $bowtiePct)? "+" : "-";
	$moreReadsSign = "" if $isBowtie;
	print KG "$names[$ni] & $rt & $wrt & $speedup & ";
	printf KG "%2.1f\\%%", $pct;
	#print KG " & $moreReadsSign$moreReads \\\\";
	print KG "\\\\";
}
print KG "\n";

print KG "\\bottomrule\n";
print KG "\\end{tabular}\n";
print KG "\\caption{";
print KG
	"CPU time for mapping 8.96M 35bp Illumina/Solexa reads against the whole human ".
	"genome on a ";
if($workstation) {
	print KG "workstation with a 2.40GHz Intel Core 2 Q6600 processor and 2 GB of RAM. ";
} else {
	print KG "server with a 2.4 GHz AMD Opteron 850 processor and 32 GB of RAM. ";
}
print KG
	"Reads were originally extracted as part of the 1000-Genomes project pilot. ".
	"They were downloaded from the NCBI Short Read archive, accession \\#SRR001115. ".
	"Reference sequences were the ".
	"contigs of Genbank human genome build 36.3. ".
	"Soap was not run against the whole-human reference because its ".
	"memory footprint exceeds physical RAM. ".  
	"For the Maq runs, the ".
	"reads were first divided into chunks of 2M reads each, ".
	"as per the Maq Manual.".
	"}\n";
print KG "\\end{table}\n";
print KG "\\end{document}\n";
close(KG);

sub trim {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readlines {
	my $f = shift;
	my @ret;
	open(FILE, $f) || die "Could not open $f";
	while(<FILE>) {
		chomp;
		push(@ret, $_)
	}
	return @ret;
}

sub readfline {
	my $f = shift;
	my $l = shift;
	my @ret;
	open(FILE, $f) || die "Could not open $f";
	while(<FILE>) {
		chomp;
		push(@ret, $_)
	}
	return $ret[$l] if $l <= $#ret;
	return "";
}

sub toMinsSecsHrs {
	my $s = shift;
	my $hrs  = int($s / 60 / 60);
	my $mins = int(($s / 60) % 60);
	my $secs = int($s % 60);
	while(length($secs) < 2) { $secs = "0".$secs; }
	if($hrs > 0) {
		while(length($mins) < 2) { $mins = "0".$mins; }
		return $hrs."h:".$mins."m:".$secs."s";
	} else {
		return $mins."m:".$secs."s";
	}
}

sub commaize {
	my $s = shift;
	return $s if length($s) <= 3;
	my $t = commaize(substr($s, 0, length($s)-3)) . "," . substr($s, length($s)-3, 3);
	return $t;
}
