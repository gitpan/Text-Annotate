#!/usr/bin/perl -w
use strict;
use Test;
BEGIN { plan tests => 2 };
use Text::Annotate::WordScan;
my $a = 'Text::Annotate::WordScan';
my $output = "";
my $check = "
# (0) i
# (1) do
# (2) not
# (3) believe
# (4) it
# (5) honestly
# (6) honestlydont
# (7) honestlydontuse
# (8) honestlydontusemetaphors
# (9) dont
# (10) dontuse
# (11) dontusemetaphors
# (12) use
# (13) usemetaphors
# (14) metaphors";

sub spit { 
    my $n = 0;
    foreach my $e (@{$_[0]}) { 
	my $line =  "# ($n) $e\n";
	print $line;
	$output .= $line;
	$n++;
    };
    ();
};

sub squashwhitespace {
    $_[0] =~ s/\s+/ /sg;
    $_[0] =~ s/^\s+//sg;
    $_[0] =~ s/\s+$//sg;

    # and...
    $_[0] =~ s/\#\s+\(\d+\)\s+//sg;
    $_[0] = join " ", (sort (split /\s+/i, $_[0]));
}

print "# Test output is:$check\n";

print "# Running small check\n";	       
my $out = $a->scan_words("I. Do. Not. Believe. It. Honestly, don't use metaphors", \&spit);
print "# ... still here\n";
ok(1);
print "# check our results\n";
squashwhitespace($output);
squashwhitespace($check);
ok ($output, $check);


# cacheing needed for:
# - remote summarise
# - index build.

# - (keyword scan)
#   As with before: get tech working before trying to
#   integrate it.

