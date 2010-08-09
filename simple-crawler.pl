use FindBin;
use lib glob "$FindBin::Bin/modules/*/lib";

use Crawler::Factory;

my @seed = qw(
    http://delicious.com/
    http://b.hatena.ne.jp/
    http://reddit.com/
    http://digg.com/
    http://news.google.co.jp/
);

my $crawler = Crawler::Factory->create('Simple', @seed);
$crawler->run(1000);
