#!/usr/bin/perl -w
use strict;
use Test;
BEGIN { plan tests => 3 };
use Text::Annotate::DataSource::Simple;
use strict;
my $ds = "Text::Annotate::DataSource::Simple";

# TODO: "simple" API is a bit nuts

my $inst = ($ds->new
	    ({
		"hemiramphus far" => "a black-billed halfbeak",
		"duck" => "quack" }));

print "# $inst\n";
ok (UNIVERSAL::isa($inst, $ds));

my $testcontent = '
What did I do with my hemiramphus far? Maybe a <a href="http://www.ducks.org/">duck</a> ate it';

my %vars;
$vars{display} = $testcontent;

$vars{annotations} = $inst->search_html($vars{display});
$inst->obj("HTMLWriter")->wrap_wiki_content(\%vars);

ok ($vars{annotations} =~ /quack/i);
ok ($vars{annotations} =~ /halfbeak/i);

# hmm, doesn't work
