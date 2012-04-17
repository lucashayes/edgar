package Edgar;
use AnyEvent;
use Edgar::Connection;
use Carp;
use YAML;

sub new {
    my $class = shift;
    my $self = {};
    
    $self->{CONFIG} = undef;
    $self->{CONDVAR} = AnyEvent->condvar;
    $self->{CONNECTIONS} = undef;

    bless ($self, $class);
    return $self;
}

sub config {
    my $self = shift;
    if (@_) { $self->{CONFIG} = shift }
    return $self->{CONFIG};
}

sub condvar {
    my $self = shift;
    if (@_) { $self->{CONDVAR} = shift }
    return $self->{CONDVAR};
}

sub connections {
    my $self = shift;
    return $self->{CONNECTIONS};
}

sub push_connection {
    my $self = shift;
    if (@_) { $self->{CONNECTIONS} = shift }
    return 1;
}

sub run {
    my $self = shift;
    my $cv = $self->condvar;
    $cv->begin();

    my $config = $self->config;

    while ( my ($name, $conn) = each %{$config->{connection}}) {
        print $name . ":" . $conn. "\n";
        confess "No network specified for connection '$name'" unless $conn->{network};

        my $network = $config->{network}->{ $conn->{network} };
        $network->{server} ||= $conn->{network};

        my $connection = Edgar::Connection->new;
        
        $connection->config( {
            %$network,
            %$conn,
            name   => $name,
        });

        $self->push_connection( $connection );
    }

    print YAML::Dump($self->connections) . "\n";

    foreach my $conn ($self->connections) {
        $conn->run();
    }

}

1;

__END__
