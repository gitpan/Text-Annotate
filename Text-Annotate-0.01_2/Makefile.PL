use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Text::Annotate',
    VERSION_FROM => 'lib/Text/Annotate.pm', # finds $VERSION
    AUTHOR       => 'Tim Sweetman (tim_sweetman@bigfoot.com)',
    ABSTRACT     => '',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
