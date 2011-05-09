
package WWW::Shorten::Googl;

use 5.006;
use strict;
use warnings;

use base qw( WWW::Shorten::generic Exporter );
our @EXPORT = qw( makeashorterlink makealongerlink );
our $VERSION = '0.99';

use JSON qw/to_json from_json/;
use Net::SSL;

use Carp;

sub makeashorterlink
{
    my $url = shift or croak 'No URL passed to makeashorterlink';
    my $api_key = shift;

    my $ua = __PACKAGE__->ua();
    my $api_url = 'https://www.googleapis.com/urlshortener/v1/url';
    my $req_params = { longUrl => $url };
    
    if (defined $api_key) {
        $api_url .= "?key=$api_key";
    }

    my $resp = $ua->post($api_url,
                            Content_Type => 'application/json',
                            Content => to_json($req_params)
                        );

    return undef unless $resp->is_success;
    my $content = $resp->content;
    
    return undef if $content =~ /Error/;
    $content = from_json($content);
    if ($content->{id} =~ m!(\Qhttp://goo.gl/\E\w+)!x) {
        return $content->{id};
    }
    return;
}

sub makealongerlink ($)
{
    my $url = shift
        or croak 'No goo.gl key / URL passed to makealongerlink';
    my $ua = __PACKAGE__->ua();

    $url = "http://goo.gl/$url"
    unless $url =~ m!^http://!i;

    my $resp = $ua->get($url);

    return undef unless $resp->is_redirect;
    my $location = $resp->header('Location');
    return $location;

}

1;

__END__


=head1 NAME

WWW::Shorten::Googl - Perl interface to goo.gl

=head1 SYNOPSIS

  use WWW::Shorten::Googl;
  use WWW::Shorten 'Googl';

  $short_url = makeashorterlink($long_url);

  $short_url = makeashorterlink($long_url, 'MY_GOOGL_API_KEY');

  $long_url  = makealongerlink($short_url);

=head1 DESCRIPTION

A Perl interface to the web site goo.gl. Googl simply maintains
a database of long URLs, each of which has a unique identifier.

Service is limited for anonymous users. To extend limits you must obtain an API KEY.
Instructions could be found at L<http://code.google.com/intl/ru/apis/urlshortener/v1/authentication.html#key-get>

API Description could be found at L<http://code.google.com/intl/ru/apis/urlshortener/v1/reference.html>

=head1 Functions

=head2 makeashorterlink

The function C<makeashorterlink> will call the Googl web site passing
it your long URL and will return the shorter Googl version.

=head2 makealongerlink

The function C<makealongerlink> does the reverse. C<makealongerlink>
will accept as an argument either the full goo.gl URL or just the
goo.gl identifier.

If anything goes wrong, then either function will return C<undef>.

=head2 EXPORT

makeashorterlink, makealongerlink

=head1 SUPPORT, LICENCE, THANKS and SUCH

See the main L<WWW::Shorten> docs.

=head1 AUTHOR

Magnus Erixzon <magnus@erixzon.com>

=head1 SEE ALSO

L<WWW::Shorten>, L<http://goo.gl/>
L<http://code.google.com/intl/ru/apis/urlshortener/v1/reference.html>

=cut
