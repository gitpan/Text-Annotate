package Text::Annotate::DataSource::Simple;
use strict;
use base qw(Text::Annotate::DataSource);
use File::Basename qw(basename);
use Carp;
our $VERSION;
$VERSION = 0.01_2;

sub new {
    my $class = shift;
    my $idx = shift;
    my $self = $class->SUPER::new ();
    foreach my $key (keys %$idx) { 
	my $can = $self->canonicalize_id($key);
	if ($can ne $key) { 
	    $idx->{$can} = $idx->{$key};
	    delete $idx->{$key};
	}

	# needed? working?
	$idx->{$can} = [$idx->{$can}] unless ((ref $idx->{$can}) eq "ARRAY");
    }
    $self->{idx} = $idx;
    $self;
};

sub generate_index { } ;

sub explain_link { 
    my ($self, $url) = @_;
    return ( html_content=>$url, title => "not yet" );
};
1;
