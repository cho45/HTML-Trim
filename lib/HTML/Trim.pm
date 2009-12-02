package HTML::Trim;
use strict;
use warnings;
our $VERSION = '0.01';

use Exporter::Lite;
use HTML::Parser;

our @EXPORT_OK = qw(htrim);

sub trim ($$$) {
	my ($str, $max, $delim) = @_;
	my $ret   = "";
	my $count = 0;
	my $opened = [];

	my $p; $p = HTML::Parser->new(
		api_version => 3,
		handlers => {
			start     => [ sub {
				my ($text, $tagname) = @_;
				push @$opened, $tagname unless $tagname =~ /^(input|img|br)$/;; 
				$ret .= $text;
			}, "text, tagname"],
			end       => [ sub {
				my ($text, $tagname) = @_;
				until (!@$opened || pop @$opened eq $tagname) { }
				$ret .= $text;
			}, "text, tagname"],
			text      => [ sub {
				my ($text) = @_;
				$count += length $text;
				if ($count > $max) {
					$ret .= substr($text, 0, $max - $count - 1);
					$p->eof; # end parse immediately
				} else {
					$ret .= $text;
				}
			}, 'dtext'],
		}
	);
	$p->parse($str);
	$p->eof;

	while (my $tagname = pop @$opened) {
		$ret .= sprintf('</%s>', $tagname);
	}

	if ($count > $max) {
		$ret .= $delim;
	}
	
	$ret;
}
*htrim = \&trim;

1;
__END__

=head1 NAME

HTML::Trim -

=head1 SYNOPSIS

  use HTML::Trim;

=head1 DESCRIPTION

HTML::Trim is

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
