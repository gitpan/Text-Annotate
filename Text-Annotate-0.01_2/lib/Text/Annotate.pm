
package Text::Annotate;
use strict;

BEGIN {
	use Exporter ();
	use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION     = 0.01_2;
	@ISA         = qw (Exporter);
	#Give a hoot don't pollute, do not export more than needed by default
	@EXPORT      = qw ();
	@EXPORT_OK   = qw ();
	%EXPORT_TAGS = ();
}


########################################### main pod documentation begin ##
# Below is the stub of documentation for your module. You better edit it!


=head1 NAME

Text::Annotate - add footnotes to content based on keyphrases used

=head1 SYNOPSIS

   synopsis not ready.


=head1 DESCRIPTION

This system looks for key phrases within a document, for phrases which
it knows about. If a document contains "hemiramphus far", it will 
provide a brief summary of whan a heriramphus is, and a link to find
more out about it. Text::Annotate::DataSource handles the list of
key phrases and the source of summary information.

The Text::Annotate::KwikiTemplate module is intended to provide a
"drop-in" extension which adds annotation to CGI::Kwiki software.

This is alpha code. Please use appropriate caution.

=head1 AUTHOR

	Tim Sweetman
	tim_sweetman@bigfoot.com
    	http://www.lemonia.org/ti

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

CGI::Kwiki.

=cut

1;
__END__

