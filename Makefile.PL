use inc::Module::Install;
name 'HTML-Trim';
all_from 'lib/HTML/Trim.pm';

requires $_ for (qw/ /);

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
