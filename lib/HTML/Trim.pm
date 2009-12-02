package HTML::Trim;
use strict;
use warnings;
use utf8;
our $VERSION = '0.01';

use Exporter::Lite;
use HTML::Parser;
use UNIVERSAL::require;
use Unicode::EastAsianWidth;

our @EXPORT_OK = qw(htrim hvtrim);

sub trim {
	my ($str, $max, $delim) = @_;
	if (ref $str eq __PACKAGE__) {
		return _trim(@_);
	}
	__PACKAGE__->new(
		length => sub {
			length $_[0];
		},
		substr => sub {
			substr $_[0], $_[1], $_[2];
		}
	)->trim($str, $max, $delim);
}
*htrim = \&trim;

sub vtrim {
	my ($str, $max, $delim) = @_;
	__PACKAGE__->new(
		length => sub {
			my ($str) = @_;
			my $ret = 0;

			local $_ = $str;
			while (/(?:(\p{InFullwidth}+)|(\p{InHalfwidth}+))/g) {
				$ret += $1 ? length($1) * 2 : length($2);
			}
			$ret;
		},
		substr => sub {
			my ($str, $offset, $limit) = @_; # ignoring offset
			my $ret   = "";
			my $count = 0;

			local $_ = $str;
			while (/(?:(\p{InFullwidth})|(\p{InHalfwidth}))/g) {
				$count += $1 ? length($1) * 2 : length($2);
				last if $count > $limit;
				$ret .= $1 || $2;
			}
			$ret;
		}
	)->trim($str, $max, $delim);
}
*hvtrim = \&vtrim;

sub new {
	my ($class, %opts) = @_;
	bless {
		length => $opts{length},
		substr => $opts{substr}
	}, $class;
}

sub _trim {
	my ($self, $str, $max, $delim) = @_;

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
				my $length += $self->{length}->($text);
				if ($count + $length > $max) {
					$ret .= $self->{substr}->($text, 0, $max - $count - 1);
					$p->eof; # end parse immediately
				} else {
					$ret .= $text;
				}
				$count += $length
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
