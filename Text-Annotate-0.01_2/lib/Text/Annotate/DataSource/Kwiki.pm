package Text::Annotate::DataSource::Kwiki;
use strict;
use base qw(Text::Annotate::DataSource);
use File::Basename qw(basename);
use Carp;
our $VERSION;
$VERSION = 0.01_2;

sub new {
    my $class = shift;
    my %args = @_;
    my $main = $args{kwiki};
    ($main) && (UNIVERSAL::isa($main, "CGI::Kwiki")) or croak "need kwiki => CGI::Kwiki instance";
    my $self = $class->SUPER::new (%args);
    $self->{main} = $main;
    $self->kwiki_db; # test.
    $self->{idx} = $self->generate_index;
    $self;
};

sub kwiki_db { 
    my $self = shift;
    # NOTE: puzzlingly long chain of indirection.
    # main->database exists, but is empty... I think this is kwiki being
    # weird.
    my $o = eval { $self->{main}->{driver}->database };
    (!$@) or confess "hmm, didn't find a database in ", $self->{main};
    $o;
}

sub kwiki_formatter { 
    my $self = shift;
    my $o = eval { $self->{main}->{driver}->formatter };
    (!$@) or confess "hmm, didn't find a formatter in ", $self->{main};
    $o;
}

sub generate_index { 
    my $self = shift;
    my %idx;
    foreach my $e ($self->kwiki_db->pages) { 
	(defined $e) or die "silly bugger";
	my $key = $self->canonicalize_id($e);

	# some words could be stoplisted, too short, too silly or whatever
	next unless defined $key;
	push @{$idx{$key}}, $self->pagename_to_local_url($e);
    };
    \%idx;
};

sub pagename_to_local_url { 
    my ($self, $pagename) = @_;
    # TODO: consider replacing $0 somehow.
    my $index_cgi = basename($0);
    return $index_cgi."?".$pagename;
}

sub explain_link { 
    my ($self, $url) = @_;
    if ($url !~ /^.{1,10}:/) { # if a local URL
	($url =~ s/.+\?//) or die "bad local url '$url'";
	# Pathinfo-related changes would need doing here
	my $content;
	$content = $self->kwiki_db->load($url);
	$content = $self->kwiki_formatter->process($content);
	return ( html_content => $content, title => $url );
    }
    else { 
	return $self->SUPER::explain_link($url);
    }
};

1;
