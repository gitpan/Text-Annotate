#!/usr/bin/perl -w
use strict;
use Test;
BEGIN { plan tests => 3 };
use Text::Annotate::DataSource::Simple;
use File::Slurp;
use strict;
my $ds = "Text::Annotate::DataSource::Simple";

# TODO: "simple" API is a bit nuts

my $inst = ($ds->new
	    ({
		"hemiramphus far" => "a black-billed halfbeak",
		"duck" => "quack" }));

print "# $inst\n";
ok (UNIVERSAL::isa($inst, $ds));

foreach my $f (@ARGV) { 
    my $testcontent = read_file($f);
    my %vars;
    $vars{display} = $testcontent;
    print "# $f\n";
    
    $vars{annotations} = $inst->search_html($vars{display});
    $inst->obj("HTMLWriter")->wrap_wiki_content(\%vars);
};

# using test file: /usr/share/doc/ntp/notes.htm
# initially: 
