#!/usr/bin/perl -w

use strict;

use Bio::Assembly::IO;

my $ace_file = shift
  or die "please pass an ACE file\n";



## Get an 'Assembly IO' object
my $assemIO = Bio::Assembly::IO->
  new( -file => $ace_file,
       -format => 'ACE'
     );



## Get the Scaffolds objects from the Assembly IO object... I think
## that Scaffold and Assembly are used interchangeably below!

while(my $scaff = $assemIO->next_assembly){
  ## $scaff is a Bio::Assembly::Scaffold object
  
  #print "$scaff\n";
  warn "There are ", $scaff->get_nof_contigs,
    " contigs in this scaffold\n";
  
  foreach my $contig ($scaff->all_contigs){
    ## $contig is a Bio::Assembly::Contig
    
    #print "\t$contig\n";
    warn "\t", "There are ", $contig->num_sequences,
      " sequences in this contig\n";
    
    foreach my $seq ($contig->each_seq){
      ## $seq is a Bio::LocatableSeq object
      
      #print "\t\t$seq\n";
      
      ## Get the "gapped consensus" location for aligned sequence
      my $feature =
	$contig->get_seq_coord( $seq );
      ## $feature is a Bio::SeqFeature::Generic
      
      ## I'd really like to print the aligned region, not the whole
      ## sequence region!
      
      print
	join("\t",
	     $scaff->id,
	     $contig->id,
	     $seq->id,
	     $seq->strand,
	     $seq->start,
	     $seq->end,
	     $feature->start,
	     $feature->end,
	    ), "\n";
    }
  }
}

warn "OK\n";
