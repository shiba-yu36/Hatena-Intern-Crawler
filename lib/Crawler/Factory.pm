package Crawler::Factory;
use strict;
use warnings;
use UNIVERSAL::require;

my $available_class = [qw{
    Simple
    Concurrent
}];

sub create {
    my ($class, $require_class, @seeds) = @_;

    my $crawler_class = 'Crawler::' . $require_class;
    $crawler_class->require;

    return $crawler_class->new(@seeds);
}

1;
