use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'HTML::Template::Associate::FormField',
    'VERSION_FROM' => 'lib/HTML/Template/Associate/FormField.pm', # finds $VERSION
    'PREREQ_PM' => {
     'CGI' => '2.45',
     'HTML::Template'=> '2.0',
     },
);
