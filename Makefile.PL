use inc::Module::Install;
name 'HTML-Template-Associate-FormField';
author 'Masatoshi Mizuno E<lt>mizunoE<64>bomcity.comE<gt>';
all_from 'lib/HTML/Template/Associate/FormField.pm';
version_from 'lib/HTML/Template/Associate/FormField.pm';

build_requires 'Test::More';
build_requires 'Test::Pod';

use_test_base;
auto_include;
WriteAll;
