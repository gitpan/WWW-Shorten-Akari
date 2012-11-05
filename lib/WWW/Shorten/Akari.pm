use v5.8;
use strict;
use warnings;
use utf8;

package WWW::Shorten::Akari;
{
  $WWW::Shorten::Akari::VERSION = 'v0.1';
}
# ABSTRACT: Reduces the presence of URLs using http://waa.ai


use base qw{WWW::Shorten::generic Exporter};
our @EXPORT = qw{makeashorterlink makealongerlink};

use constant API_URL => q{http://waa.ai/api.php};

use Carp;
use Encode qw{};

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;

    $self->_init(@_);
    return $self;
}

sub _init {
    my ($self) = @_;

    $self->{ua} = __PACKAGE__->ua;
    $self->{utf8} = Encode::find_encoding("UTF-8");
}

sub reduce {
    my ($self, $url) = @_;
    unless ($url) {
        carp "No URL given";
        return;
    }

    #$url = $self->{utf8}->encode($url) if Encode::is_utf8($url);

    my $uri = URI->new(API_URL);
    $uri->query_form(url => $url);

    my $res = $self->{ua}->get($uri->as_string);

    unless ($res->is_success) {
        carp "HTTP error ". $res->status_line ." when shortening $url";
        return;
    }

    return $res->decoded_content;
}

sub shorten {
    my ($self, @args) = @_;
    return $self->reduce(@args);
}

sub short_link {
    my ($self, @args) = @_;
    return $self->reduce(@args);
}

sub increase {
    my ($self, $url) = @_;
    unless ($url) {
        carp "No URL given";
        return;
    }

    unless ($self->_check_url($url)) {
        carp "URL $url wasn't shortened by Akari";
        return;
    }

    my $res = $self->{ua}->head($url);
    return $res->header("Location");
}

sub _check_url {
    my ($self, $url) = @_;
    return scalar $url =~ m{^http://waa\.ai/[^.]+$};
}

sub lenghten {
    my ($self, @args) = @_;
    return $self->increase(@args);
}

sub long_link {
    my ($self, @args) = @_;
    return $self->increase(@args);
}

sub extract {
    my ($self, @args) = @_;
    return $self->increase(@args);
}

my $presence = WWW::Shorten::Akari->new;

sub makeashorterlink($) {
    return $presence->reduce(@_);
}

sub makealongerlink($) {
    return $presence->increase(@_);
}

1;

__END__

=pod

=head1 NAME

WWW::Shorten::Akari - Reduces the presence of URLs using http://waa.ai

=head1 VERSION

version v0.1

=head1 SYNOPSIS

    use WWW::Shorten::Akari;

    my $presence = WWW::Shorter::Akari->new;
    my $short = $presence->reduce("http://google.com");
    my $long  = $presence->increase($short);

    $short = makeashortlink("http://google.com");
    $long  = makealonglink($short);

=head1 DESCRIPTION

Reduces the presence of URLs through the L<http://waa.ai> service.
This module has both an object interface and a function interface
as defined by L<WWW::Shorten>. This module is compatible with
L<WWW::Shorten::Simple> and, since L<http://waa.ai> always returns
the same short URL for a given long URL, may be memoized.

=head1 METHODS

=head2 new

Creates a new instance of Akari.

=head2 reduce($url)

Reduces the presence of the C<$url>. Returns the shortened URL.

On failure, or if C<$url> is false, C<carp>s and returns false.

Aliases: C<shorten>, C<short_link>

=head2 increase($url)

Increases the presence of the C<$url>. Returns the original URL.

On failure, or if C<$url> is false, or if the C<$url> isn't
a shortened link from L<http://waa.ai>, C<carp>s and returns
false.

Aliases: C<lenghten>, C<long_link>, C<extract>

=for Pod::Coverage shorten short_link

=for Pod::Coverage lenghten long_link extract

=head1 FUNCTIONS

=head2 makeashorterlink($url)

L<Makes a shorter link|http://tvtropes.org/pmwiki/pmwiki.php/Main/ExactlyWhatItSaysOnTheTin>

=head2 makealongerlink($url)

L<The opposite of|http://tvtropes.org/pmwiki/pmwiki.php/Main/CaptainObvious>
L</makeashorterlink($url)>

=head1 SOURCE CODE

https://github.com/Kovensky/WWW-Shorten-Akari

=head1 AUTHOR

Kovensky <diogomfranco@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Diogo Franco.

This is free software, licensed under:

  The (two-clause) FreeBSD License

=cut
