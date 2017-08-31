#!/usr/bin/perl

use lib "$ENV{'HOME'}/perllib";

use App::Options(

    values => \%optn,
    option => {

    dir => {
      type => 'string',
      required => 1,
    },

	  list => {
	    type => 'string',
	    required => 1,
	  },
    npara => {
	    type => 'integer',
	    default => 1,
	  },
    queue => {
      type => 'string',
      default => 'PF',
    },
    jobtype => {
      type => 'string',
      default => 'small',
    },

    },
);

my $script = "~/scripts/relax/make_relax_inputs.pl ";

open( LIST, "$optn{list}" ) || die ( "cannot open $optn{list}");
while ( my $line = <LIST> ) {

  chomp;
  $line =~ s/[ \t\n]+//g;
  next if( $line =~ m/^#/ );
  next if( $line =~ m/^\s*$/ );

  if ( $line =~ m/^>OPTIONS/ || $line =~ m/^>PDB/ || $line =~ m/^>SILENT/ || $line =~ m/THREADSEQ/ || $line =~ m/WEIGHT/ ) {
    $line =~ s/>//;
    $readtype = $line;
    next;
  }

  my( $name, $file ) = split( '=', $line );
  if( defined( $name ) && defined( $file ) ) {
    $inputs->{$name}->{$readtype} = $file;
    push( @namelist, $name );
  } else {
    push( @{$inputs->{$readtype}}, $line );
  }

}
close ( LIST );


my $option;
foreach my $opt ( @{$inputs->{OPTIONS}} ) {

  if( $opt =~ m/cst_start_coord/ ) {
    $option = $option." -cst_start_coord";
  }
  if( $opt =~ m/limit_aroma_chi2/ ) {
    $option = $option." -limit_aroma_chi2";
  }
  if( $opt =~ m/weight/ ) {
    $opt =~ s/weight//;
    $option = $option." -weight=$opt";
  }
  if( $opt =~ m/nstruct/ ) {
    $opt =~ s/nstruct//;
    $option = $option." -nstruct=$opt";
  }
  if( $opt =~ m/njobs/ ) {
    $opt =~ s/njobs//;
    $option = $option." -njobs=$opt";
  }

}

if ( ! -e $optn{dir} ) {
  system( "mkdir $optn{dir} ");
}


foreach $name ( @namelist ) {

  $ii ++;

  my $pdb    = $inputs->{$name}->{PDB};
  my $silent = $inputs->{$name}->{SILENT};
  my $thread = $inputs->{$name}->{THREADSEQ};

  if ( $pdb ne "" ) {
    print ( "$script -dir=$optn{dir}/$name -name=$name -pdb=$pdb $option \n");
    system ( "$script -dir=$optn{dir}/$name -name=$name -pdb=$pdb $option \n");
  }

  if( $silent ne "" ) {
    if( $thread eq "" ) {
      die( "require threadseq option for $silent \n");
    }
    system ( "$script -dir=$optn{dir}/$name -name=$name -silent=$silent -threadseq=$thread $option \n");
  }

}

system( "cat $optn{dir}/*/joblist\.* > $optn{dir}/joblist_all" );
system( "cd $optn{dir}; ~/scripts/make_jsub.pl --list=joblist_all --npara=$optn{npara} --queue=$optn{queue} --jobtype=$optn{jobtype} " );
