use Test::Dependencies
	exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic HTML::Trim/],
	style   => 'light';
ok_dependencies();
