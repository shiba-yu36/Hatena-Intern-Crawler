package Crawler::Simple;
use strict;
use warnings;

use base qw/Crawler/;

use Socket;
use URI;

sub run {
    my ($self, $npages) = @_;

    print "start\n";
    for my $count (1..$npages) {
        my $url = $self->dequeue;
        return if !$url;

        #アクセス制限チェック
        if ($self->is_over_access_limit($url)) {
            $self->enqueue($url, $self->current_prio + 1);
            print "$url : access limit !\n";
            redo;
        }

        #URLフェッチ
        my $fetch_urls = $self->fetch($url);
        $self->enqueue($_, $self->current_prio + 10) for @$fetch_urls;

        print sprintf("%d/%d(%d) : %s\n", $count, $self->queue_size, $self->current_prio, $url);
    }
    print "end\n";

}

1;
