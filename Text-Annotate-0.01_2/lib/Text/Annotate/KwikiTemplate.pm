package Text::Annotate::KwikiTemplate;
use strict;
use base qw(CGI::Kwiki::Template);
use CGI::Kwiki::Template 0.18;
use Text::Annotate::DataSource::Kwiki;
our $VERSION;
$VERSION = 0.01_2;

sub annotate_ds { "Text::Annotate::DataSource::Kwiki" };

sub process {
    my ($self, $t_file, %vars) = @_;
    if ($vars{display}) { 
	my $ds = $self->annotate_ds->new (kwiki => $self);
	$vars{annotations} = 
	   $ds -> search_html($vars{display}, $self);
	$ds->obj("HTMLWriter")->wrap_wiki_content(\%vars);
    };
    $self->SUPER::process($t_file, %vars);
};

1;
