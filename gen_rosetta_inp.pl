#!/usr/bin/perl

use lib "/home/users/xl2/perllib";
use lib "/home/users/xl2/scripts/relax";

use READ_OPTION;
use ADD_FLAGS;

my $rosetta_exe     = "/home/users/xl2/rosetta/Rosetta/main/source/bin/relax.linuxgccrelease -database ~/rosetta/Rosetta/main/database";
my $weightdir_orig  = "/home/users/xl2/rosetta/Rosetta/main/database/scoring/weights/";

my $PWD = `pwd`; chomp $PWD;

# read options
my $optn = READ_OPTION->new;
$optn->read_options();
my $OUTDIR = $optn->{option}->{dir};
my $NJOBS  = $optn->{option}->{njobs};
my $NAME   = $optn->{option}->{name};
my $weight = ${weightdir_orig}.$optn->{option}->{weight};

my $flags = ADD_FLAGS->new;
$flags->add_flags( $weight, $optn->{option}->{limit_aroma_chi2}, $optn->{option}->{cstfile}, $optn->{option}->{cst_start_coord}, $optn->{option}->{threadseq}, $optn->{option}->{nstruct}, $optn->{option}->{pre_tala} );

# obtain silent files
my @all_silent_inputs;
my @input_silents;
if ( $optn->{read_silent} ) {
  @all_silent_inputs = @{$flags->add_silent_files( $optn->{option}->{silent}, $NJOBS )};
} else {
  $flags->add_pdb( $optn->{option}->{pdb} );
}

# make output file
if ( !-e $OUTDIR ) {
  mkdir ( $OUTDIR );
}
open( OUT, ">$OUTDIR/joblist.$optn->{option}->{name}" ) || die ( "cannot open $OUTDIR/joblist.$optn->{option}->{name} \n" );
for ( my $ii=1; $ii<=$NJOBS; $ii++ ) {

  my $name = $NAME."_".$ii;

  if( ( $#all_silent_inputs < $ii-1 ) && $optn->{read_silent} ) {
    last;
  }

  if ( $optn->{read_silent} ) {
    print OUT "$rosetta_exe $all_silent_inputs[$ii-1] -out:file:silent ${PWD}/$optn->{option}->{dir}/${name}.silent -out:file:scorefile ${PWD}/$optn->{option}->{dir}/${name}.sc \n";
  } else {
    print OUT "$rosetta_exe $flags->{flags} -out:file:silent ${PWD}/$optn->{option}->{dir}/${name}.silent -out:file:scorefile ${PWD}/$optn->{option}->{dir}/${name}.sc  \n";
  }

}
close( OUT );
