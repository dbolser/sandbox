#!/usr/bin/perl -w

## The aim of this script is to (crudly) assess the effect of the 454
## reads on the contig N50

use strict;
use Bio::Assembly::IO;




## The contig gap data
my $scaff_gff_file = "Data/Illumina_Assembly-1.0.+gaps.gff3";

## The mapping data
my $mapping_results_file = "Mapping/Illumina-1.0_Scaffold000001_vs_Liverpool_454-0.125/mapping/454Contigs.ace.tab";



## Read in the gaps from the assembly

my %gap;

open GFF, '<', $scaff_gff_file
  or die "pain\n";

while( my $row = <GFF> ){
  chomp($row);
  
  my @col = split(/\t/, $row);
  
  next unless $col[2] eq 'gap';
  
  my %dat = split(/=|;/, $col[8]);
  
  next if
    $col[4] - $col[3] == 100;
  
  $gap{$col[0]}{$dat{'ID'}} = [$col[3], $col[4]];
}

warn "got ", scalar(keys %gap), " gaps\n";



## Decide which gaps have been spanned

open MAP, '<', $mapping_results_file
  or die "krunck\n";

while( my $row = <MAP> ){
  chomp($row);
  
  my @col = split(/\t/, $row);
  
  my $scaff = $col[1];
  my $start = $col[6];
  my $end = $col[7];
  
  die "no\n" if $end < $start;
  
  next if $end - $start > 1000;
  
  for my $gap (keys %{$gap{$scaff}}){
    
    my ($gap_start, $gap_end) = @{$gap{$scaff}{$gap}};
    
    if($start < ($gap_start-50) &&
       $end > ($gap_end+50)){
      
      print "GAP SPANNED!\n";
      print
	join("\t", 
	     $scaff, $gap,
	     $start, $end, ($end - $start),
	     $gap_start, $gap_end, ($gap_end - $gap_start),
	    ), "\n";
    }

  }
}

warn "OK\n";

