use Module::Build;

my $builder = Module::Build->new(
  module_name => 'HTML::Template::Associate::FormField',
  license => 'perl',
  dist_author => 'Masatoshi Mizuno E<lt>mizunoE<64>bomcity.comE<gt>',
  dist_version_from=> 'lib/HTML/Template/Associate/FormField.pm',
  requires => {
    'Test::More' => 0,
    'Test::Pod'  => 0,
    },
  );

$builder->create_build_script();
