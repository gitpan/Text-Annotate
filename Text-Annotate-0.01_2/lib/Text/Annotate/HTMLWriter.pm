package Text::Annotate::HTMLWriter;
use strict;
our $VERSION;
$VERSION = 0.01_2;

sub format_annotations { 
    my ($class, $h) = @_;
    $h = [$h] if (ref $h eq "HASH");
    my $out = '';
    my $linkstyle = $class->css_link;
    my $parastyle = $class->css_para_class;
    foreach my $e (@$h) {
	$class->process_link ($e);
	my $link = $e->{link};
	my $summary = $e->{summary};
	my $title = $e->{title};
	next unless (defined $link && defined $summary && defined $title);
	# TODO: escaping?
	$out .= qq(
		   <p $parastyle/><a $linkstyle href="$link">$title</a><br/>
		   $summary</p>);
    };
    return $class->wrap_output($out);
}

# Application of CSS properly would remove the need for this.
sub wrap_output { 
    my ($self, $content) = @_;
    return $content unless $content;
    return '<font size="-5">'.$content.'</font>';
}

sub css_para_class { 'class="annotation"' };
sub css_link { 'class="autogenerated"' };

sub process_link { 
    my ($self, $h) = @_;
    unless (defined $h->{summary}) { 
	# ordering fudge here.
	%$h = ($self->html_to_brief_text ($h->{html_content}), %$h);
    };
}

# ad-hoc fudge to summarise content. Should be done better - and should
# be possible to add "plugins" which summarise known kinds of URL.
sub html_to_brief_text { 
    my ($self, $content) = @_;
    return undef unless defined $content;
    my $title;
    # might bork hopelessly with XHTML
    $title = $1 if ($content =~ s/<title>(.+)\<\/title\/?>//si);
    $content =~ s/\r//;
    $content =~ s/\s+\n\s+/\n/sg;
    my @paras = split /\<p\>/i, $content;
    foreach my $para (@paras) { 
	$para =~ s/\<.+?\>//sg; # remove HTML tags
	$para =~ s/\s+\n\s+/\n/sg;
    };

    my $out = "";

    my $lim = 100;
    while (1) { 
	last if (!@paras);
	last if (length $out > $lim);
	$out .= ($out ? "<br>" : "").(shift @paras);
    };
    $out =~ s/^(.{$lim}).+$/$1\.\.\./s;
    $out = "<br><b><em>$title</em></b><br>".$out if $title;
    (summary => $out, title => $title);
};

sub wrap_wiki_content { 
    my $class = shift;
    my $vars = shift;
    $vars->{original_display} = $vars->{display};
    if ($vars->{display} && $vars->{annotations}) { 
	my $display = $vars->{display};
	my $annotations = $vars->{annotations};
	$vars->{display} = 
	    qq(
	       <table>
	       <tr><td valign="top">
	       $display
	       </td>
	       <td valign="top">
	       $annotations
	       </td>
	       </table>);
    }
};

1;
