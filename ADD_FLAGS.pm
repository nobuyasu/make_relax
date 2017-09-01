#!/usr/bin/perl -w

package ADD_FLAGS;


sub new {
    my $class = shift;
    my $self = bless {
	    flags => " -ex1 -ex2aro -mute all ",
    },$class;
    return $self;
}

##############################################################################################
sub add_flags {

  my $this = shift;
  my ( $weight, $lac2, $cstfile, $cststart, $threadseq, $nstruct, $pre_tala ) = @_;

  if( $pre_tala || $weight =~ m/score12/ ) {
    $this->{flags} = $this->{flags}." -pre_talaris2013_geometries ";
  }
  # weight
  $weight = `readlink -f $weight`; chomp $weight;
  if( !-e $weight ) {
      die ( "die no $weight file\n" );
  }
  $this->{flags} = $this->{flags}." -score:weights ${weight}";

  # limit_aroma_chiw
  if ( $lac2 ) {
      $this->{flags} = $this->{flags}." -limit_aroma_chi2 ";
  }

  # cstfile
  if ( $cstfile ne "" ) {
    $cstfile = `readlink -f $cstfile`; chomp $cstfile;
    if( !-e $cstfile ) {
	     die ( "die no $cstfile file\n" );
    }
    $this->{flags} = $this->{flags}." -constraints::cst_fa_file $cstfile";
  }

  # constraint to start coordinates
  if ( $cststart ) {
      $this->{flags} = $this->{flags}." -constrain_relax_to_start_coords";
  }

  # thread sequence
  if ( $threadseq ne "" ) {
    $threadseq = `readlink -f $threadseq`; chomp $threadseq;
    if( !-e $threadseq ) {
	     die ( "die no $threadseq file\n" );
    }
    $this->{flags} = $this->{flags}." -relax:thread_seq $threadseq";
  }

  # add nstcut
  if ( $nstruct ) {
      $this->{flags} = $this->{flags}." -nstruct $nstruct";
  }


}

#############################################################################################
sub add_pdb {

    my $this = shift;
    my ( $pdb ) = @_;

    $pdb = `readlink -f $pdb`; chomp $pdb;
    if( !-e $pdb ) {
	    die ( "ADD_FLAGS: die no pdb, $pdb.\n" );
    }
    $this->{flags} = $this->{flags}." -s $pdb ";

}


#############################################################################################
sub add_silent_files {

  my $this = shift;
  my ( $silentdir, $njobs ) = @_;

  my $silentdir = `readlink -f $silentdir`; chomp $silentdir;
  my %silents;
  opendir( DIR, $silentdir ) || die ( "cannot open $silentdir \n");
  my @allfiles = readdir( DIR );
  foreach my $f ( @allfiles ) {
    if( $f =~ m/silent/ ) {
	    chomp $f;
      my $id = $f; $id =~ s/\.silent//;
      $f = $silentdir."/".$f;
	    $f = `readlink -f $f`; chomp $f;
      $silents{$id} = $f;
	  }
  }
  close( DIR );

  my @silents;
  foreach my $n ( sort { $a <=> $b } keys %silents ) {
      #print "$n $silents{$n} \n";
      push( @silents, $silents{$n} );
  };

  my $num_silent = $#silents + 1;
  my $num_silent_perjob = int( $num_silent/$njobs );
  if ( $num_silent % $njobs != 0 ) {
    $num_silent_perjob ++;
  }

  my $final_job = $njobs;
  my $finish = 0;
  my $num = 0;
  for( my $ii=1; $ii<=$njobs; $ii++ ) {
    if( $finish ) {
      last;
    }
    for( $jj=1; $jj<=$num_silent_perjob; $jj++ ) {
      if ( $num_silent == $num ) {
        $finish = 1;
        $final_job = $ii;
        last;
      }
      push( @{$input_silents[ $ii ]}, $silents[ $num ] );
      $num ++;
    }
  }

  my @input_silent_string;
  for ( my $ii=1; $ii<=$final_job; $ii++ ) {
    my $flag = $this->{flags}." -in:file:silent @{$input_silents[$ii]}";
    push( @input_silent_string, $flag );
  }

  return \@input_silent_string;

}

1;
