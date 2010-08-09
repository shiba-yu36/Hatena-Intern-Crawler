package Test::Crawler::Factory;
use strict;
use warnings;
use base qw(Test::Class);

use FindBin;
use lib glob "$FindBin::Bin/../../modules/*/lib";

use Test::More;

use Crawler::Factory;


sub create : Tests {
    my @seed = qw(
        http://delicious.com/
        http://b.hatena.ne.jp/
        http://reddit.com/
        http://digg.com/
        http://news.google.co.jp/
    );
    my $crawler_simple = Crawler::Factory->create('Simple', @seed);

    isa_ok($crawler_simple, 'Crawler::Simple');
    is_deeply $crawler_simple->seeds, [@seed];
}

__PACKAGE__->runtests;

1;
