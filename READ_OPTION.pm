#!/usr/bin/perl -w

package READ_OPTION;

use lib "$ENV{'HOME'}/perllib";

sub new {

    my $class = shift;
    my $self = bless {
      option => undef,
      read_silent => 0,
	  },$class;

}

sub read_options {

  my $this = shift;

  use App::Options (

    values => \%optn,

    option => {
    name => {
      type => 'string',
  	  required => 1,
    },
    dir => {
  	  type => 'string',
  	  required => 1,
    },
    nstruct => {
  	  type => 'integer',
      default => 5,
    },
    njobs => {
  	   type => 'integer',
       default => 10,
    },
    jobtype => {
  	   type => 'string',
  	   default => 'small',
    },
    queue => {
  	   type => 'string',
  	   default => 'PF',
    },
    pdb => {
	     type => 'string',
	     required => 0,
    },
    silent => {
	     type => 'string',
	     required => 0,
    },
    threqdseq => {
	     type => 'string',
	     required => 0,
    },
    cst_start_coord => {
       type => 'string',
	     required => 0,
    },
    cstfile => {
	     type => 'string',
	     required => 0,
    },
    limit_aroma_chi2 => {
	     type => 'bool',
	     default => 0,
    },
    weight => {
	     type => 'string',
	     default => "score12_full.wts",
    },
    pre_tala => {
	     type => 'string',
	     default => 0,
    },



  },
  );

  if( $optn{silent} && !$optn{pdb} ) {
      $this->{read_silent} = 1;
  } elsif ( $optn{silent} && $optn{pdb} ) {
      die( "Both silent and pdb flags cannot be used simultaneously. ")
  }
  $this->{option} = \%optn;

}

1;
