package Crawler;
use strict;
use warnings;

use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors(qw(
    seeds
    recent_access
    queue
    results
    scraper
    current_prio
));

use Data::PSQueue;
use Web::Scraper;
use URI;
use DateTime;
use Socket;

use Readonly;
Readonly my $MIN_ACCESS_INTERVAL => 1;

sub new {
    my ($class, @seeds) = @_;
    my $self  = $class->SUPER::new;

    $self->seeds([@seeds]);

    my $queue = Data::PSQueue->empty;
    for my $url (@seeds) {
        $queue->insert($url, 0);
    }
    $self->queue($queue);

    my $scraper = scraper {
        process 'a', 'urls[]' => '@href'
    };
    $self->scraper($scraper);

    $self->recent_access({});

    return $self;
}

sub dequeue {
    my $self = shift;
    my $item = $self->queue->delete_min;
    return if !$item;

    $self->current_prio($item->prio);
    return $item->key;
}

sub enqueue {
    my ($self, $data, $prio) = @_;
    $self->queue->insert($data, $prio);
}

sub fetch {
    my ($self, $url) = @_;
    my $scraper = scraper{process 'a', 'urls[]' => '@href'};
    my $res = $scraper->scrape(URI->new($url));
    return $res->{urls};
}

sub queue_size {
    my $self = shift;
    return $self->queue->size;
}

sub is_over_access_limit {
    my ($self, $url) = @_;
    my $ipaddr = $self->_url_to_ipaddr($url);
    my $now = DateTime->now->epoch;
    my $recent_access = $self->recent_access;

    my $access_interval = $now - ($recent_access->{$ipaddr} || 0);

    if ($access_interval < $MIN_ACCESS_INTERVAL) {
        return 1;
    }
    else {
        $recent_access->{$ipaddr} = $now;
        return 0;
    }
}

sub _url_to_ipaddr {
    my ($self, $url) = @_;
    my $uri    = URI->new($url);
    my $ipaddr = inet_ntoa(inet_aton($uri->host));
}

1;
