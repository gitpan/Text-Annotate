package Text::Annotate::WordScan;
use strict;
use Carp;
our $VERSION;
$VERSION = 0.01_2;

sub scan_words { 
    my ($class, $content, $cbk) = @_;
    ($cbk) or croak "need callback";
    my $it = $class->new_it($content);

    # moving around for speed
    # my @pipe = (\&_findsen, \&_findwords, _gfindphrases(), \&_canon, $cbk);
    my @pipe = (\&_findsen, \&_findwords, \&_precanon, _gfindphrases(), $cbk);
    my $c = $class->pipe_to_code(\@pipe);
    $c->([$content]);
};


sub scan_wordsx { 
    my ($class, $content, $cbk) = @_;
    ($cbk) or croak "need callback";
    my $it = $class->new_it($content);

    # a nest of while(s): semipredicate problem.
    # bah, define "untrue" weird value.

    my @pipe = (\&_findsen, \&_findwords, \&_canon, $cbk);
    my $c = $class->pipe_to_code(\@pipe);
    $c->([$content]);
};

sub new_it { 
    my $class = shift;
    my $content = shift;
    my $self = bless { c => $content }, $class;
};

sub ping {
    my $self = shift;
    return ($self->{c} =~ /\s*([^\!\?\.]+)\s*/sg) ? $1 : ();
};

sub pipe_to_code { 
    my ($self, $pipe) = @_;
    
    my $buf = 'sub {';
    my $n = 0;

    my $vvprev = '$_[0]'; # change for OO

    foreach my $e (@$pipe) { $e = ref $e ? Text::Annotate::WordScan::SubWrap->new($e) : $e->new };

    foreach my $e (@$pipe) {
	my $vvar = '$v'.$n;
	my $debug = my $debug2 = "";
	# my $debug = "warn 'pipesegment $n in:', Dumper($vvprev);";
	# my $debug2 = "warn 'pipesegment $n out:', Dumper($vvar);";
	$buf .= "$debug \$pipe->[$n]->add($vvprev); while (my $vvar = \$pipe->[$n]->iterate) { $debug2; ";
	$vvprev = $vvar;
	$n++;
    }

    $buf .= '}' x (@$pipe+1);
    (my $subref = eval $buf) or die "Didn't like that: $@";
}
    
sub _findsen { 
    my $in = shift; 
    my @out;
    foreach my $e (@$in) { 
	my $tidy = $e;
	$tidy =~ s/\s+/ /sg;
	push @out, split /[\.\?\!]+/, $tidy 
	};
    @out ? \@out : ();
};

sub _findwords {
    my $in = shift;
    my @out;
    foreach my $sen (@$in) { 
	my @words = grep {length $_} (split /[\s\!\?\.]+/, $sen);
	push @out, \@words if @words;
    }
    @out ? \@out : ();
}

# and now, the tricky bit.

# we are simultaneously...
# - splitting into words
# - regrouping those words into potential phrases (tricky bit, as an iterator)
# - confusing outselves totally

# - MAKE SURE WE DON'T LOSE STUFF
# - OO may actually be tidier.

# - This is now not spinning, but not quite working either.

sub _gfindphrases { 
    my @sentences;
    my $phl = 0;
    my $max_phl = 4;
    my $outmax = 10000; # TODO: MAKE CONFIGURABLE
    my $delimiter = "";
    my ($pos, $phraselength) = (0, 0);

    my $s = 
	sub { 
	    my $in = shift;
	    push @sentences, @$in if ($in && @$in);
	    my @out;
	    while (@out < $outmax) { 
		last if (!@sentences); # needed?
		my $foo = @sentences;
		my $max = $pos + $phraselength;
		if ($max >= @{$sentences[0]}) {
		    $pos = 0;
		    $phraselength++;
		    $max = $pos + $phraselength;
		};
		if (($phraselength > $max_phl) || ($phraselength >= @{$sentences[0]})) { 
		    $phraselength = 0;
		    $max = $pos + $phraselength;
		    shift @sentences;
		}
		last if (!@sentences);
		push @out, (join $delimiter, @{$sentences[0]}[$pos++..$max]);
		
	    };
	    return @out ? \@out : ();
	};
    $s;
}


sub _findphrasesold {  # TURN THIS INTO ITERATOR!
    my $data = shift;
    my @out;
    foreach my $sentance (@$data) { 
	my @words = grep {length $_} (split /[\s\!\?\.]+/, $sentance);
	my $i = 0;
	while (1) { 
	    foreach my $phraselength (qw(0 1 2 3 4)) {
		my $max = $i + $phraselength;
		last if ($max >= @words);
		my $foo = join " ", @words[$i..$max];
		push @out, $foo;
	    };
	    $i++;
	    last if ($i > @words); # hmm
	}
    };
    \@out;
};


sub _precanon { 
    my $data = shift;
    my @out;
    foreach my $sentence (@$data) { 
	foreach my $word (@$sentence) { 
	    $word = lc $word;
	    $word =~ s/[^a-z0-9]//sg;
	}
    }
    $data;
};

sub _canon { 
    my $data = shift;
    my @out;
    foreach my $e (@$data) { 
	$e = lc $e;
	$e =~ s/[^a-z0-9]//sg;
	push @out, $e;
    }
    \@out;
};


sub canonicalize_id { 
    my ($self, $word) = @_;
    return _canon([$word])->[0];
};

package Text::Annotate::WordScan::SubWrap;

sub new { 
    my ($class, $sub) = @_;
    $class = ref $class || $class;
    (ref $sub eq "CODE") or die "'$sub' ain't a sub";
    my $self = [$sub];
    bless $self, $class;
};

sub add { 
    my ($self, $data) = @_;
    $self->[1] = $data;
};

# todo: debugging is a problem.

sub iterate { 
    my $self = shift;
    my $fn = $self->[0];
    my $out = [];
    $out = $fn->($self->[1]);
    $self->[1] = undef;
    ($out && @$out) ? $out : ();
};
    
package CGI::Kwiki::WordScan::Buffer;

sub new {
    return bless [];
};

sub add { 
    my ($self, $data) = @_;
    (ref $data eq "ARRAY") or die "nay";
    push @$self, @$data;
};

sub iterate { 
    my $self = shift;
    @$self ? [shift @$self] : ();
};

1;
