package Test::Crawler;
use strict;
use warnings;
use base qw(Test::Class Class::Accessor::Fast);
__PACKAGE__->mk_accessors(qw(
    crawler
    seeds
));

use Test::More;

use Crawler;

sub setup : Test(setup) {
    my $self = shift;
    my @seed = qw(
        http://delicious.com/
        http://b.hatena.ne.jp/
        http://reddit.com/
        http://digg.com/
        http://news.google.co.jp/
    );
    my $crawler = Crawler->new(@seed);

    $self->crawler($crawler);
    $self->seeds([@seed]);
}

sub new_test : Tests {
    my $self    = shift;
    my $crawler = $self->crawler;

    isa_ok $crawler, 'Crawler';
    is_deeply $crawler->seeds, $self->seeds;
    isa_ok $crawler->scraper, 'Web::Scraper';
}

sub queue_test : Tests {
    my $self    = shift;
    my $crawler = $self->crawler;
    my $seeds   = $self->seeds;

    ok $crawler->enqueue('http://d.hatena.ne.jp/shiba_yu36/', 0);
    ok $crawler->enqueue('http://d.hatena.ne.jp/', 1);

    ok $crawler->dequeue;
    is $crawler->queue_size, 6;
    ok $crawler->dequeue;
    is $crawler->queue_size, 5;
    ok $crawler->dequeue;
    is $crawler->queue_size, 4;
    ok $crawler->dequeue;
    is $crawler->queue_size, 3;
    ok $crawler->dequeue;
    is $crawler->queue_size, 2;
    ok $crawler->dequeue;
    is $crawler->current_prio, 0;
    is $crawler->queue_size, 1;
    is $crawler->dequeue, 'http://d.hatena.ne.jp/';
    is $crawler->current_prio, 1;
    is $crawler->queue_size, 0;
    ok !$crawler->dequeue;
}

sub over_access_test : Tests {
    my $self    = shift;
    my $crawler = $self->crawler;
    my $seeds   = $self->seeds;

    my $url = $crawler->dequeue;
    ok !$crawler->is_over_access_limit($url);
    ok $crawler->is_over_access_limit($url);
}

__PACKAGE__->runtests;

1;
