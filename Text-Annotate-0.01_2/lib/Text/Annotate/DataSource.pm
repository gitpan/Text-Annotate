package Text::Annotate::DataSource;
use strict;
use Text::Annotate::HTMLWriter;
use Text::Annotate::WordScan;
use Carp;
BEGIN { 
    our $VERSION;
    $VERSION = 0.01_2;
};

=head1 NAME

Text::Annotate::DataSource - parent class for annotation data sources

=head1

An annotation datasource provides two things:
a) a way to look up potential key phrases. Key phrases that match our data
yield URIs or similar identifiers.
b) a way to "explain" those URIs, producing a brief HTML description of the
phrase in question.

=cut

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = bless {}, $class;
    $self;
};


# "obj" is supposed to provide access to annotation objects.
# TODO: refactor into a superclass
# TODO: some classes will want to be instantiated at the beginning, shut down
# later ...
# TODO: "require" objects when needed
# TODO: make objects configurable, at with an easily inherited interface
sub obj { 
    my ($class, $name) = @_;
    my $o = {
	HTMLWriter => "Text::Annotate::HTMLWriter",
	WordScan => "Text::Annotate::WordScan"
	}->{$name};
    ($o) or confess "no '$o' object recognised";
    $o;
};

=head1 METHODS

=head2 index_lookup

Typical call:

$datasource->index_lookup ("get", "your", "widgets", ... "getyourwidgetsfrom", "wigentiacorp")

index_lookup is called with a list of (already canonicalised) key phrases. Where those 
phrases match one we know about, we return a two-element list.

Typical output:

(["wigentiacorp", "http://www.wigentia.com/"],
 ["herring", "http://www.example.com/fishguide/herring/"])

It is passed a list so we don't get overwhelmed by function-switching overhead, whilst
painstakingly trundling through piles of useless words in search of something interesting.

You may well want to override this.

=cut

# TODO: doc interface here
# TODO: wouldn't references be faster?
sub index_lookup { 
    my ($self, @keys) = @_;
    my $idx = $self->{idx};
    my @out;
    foreach my $k (@keys) { 
	push @out, [$k, $idx->{$k}] if $idx->{$k};
    }
    @out;
}

sub search_html { 
    my ($self, $to_search) = @_;
    $to_search =~ s/\<.+?\>//sg;
    $self->search($to_search);
}

sub search {
    my $self = shift;
    my $to_search = shift;
    my @out;
    my %seen;
    my $cbk = sub { 
	my $in = shift;
	my ($results) = [$self->index_lookup(@$in)];
	while (@$results) {
	    my $r = shift @$results;
	    if ($seen{$r->[0]}) { 
		next; # ooh
	    };
	    $seen{$r->[0]} = 1;
	    foreach my $link (@{$r->[1]}) { 
		push @out, {title => $r->[0], link => $link, $self->explain_link($link)};
	    };
	};
	();
    };
    $self->scan_words($to_search, $cbk);

    foreach my $e (@out) {
	%$e = (%$e, $self->explain_link($e->{link}));
    };

    return $self->obj("HTMLWriter")->format_annotations(\@out);
};


sub scan_words {
    my $self = shift;
    $self->obj("WordScan")->scan_words(@_);
};

sub canonicalize_id {
    my ($self, $word) = @_;
    $self->obj("WordScan")->canonicalize_id($word);
};

sub explain_link { () };

1;
