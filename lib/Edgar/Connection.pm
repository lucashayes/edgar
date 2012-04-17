package Edgar::Connection;
use AnyEvent::IRC::Client;
use Edgar::Message;
use Carp;

sub new {
    my $class = shift;
    my $self = {};
    
    $self->{CONFIG} = undef;
    $self->{IRC} = undef;
    $self->{HOOKS} = undef;
    $self->{PLUGINS} = undef;
    $self->{NICKNAME} = undef;
    $self->{USERNAME} = undef;
    $self->{SERVER} = undef;
    $self->{PORT} = undef;
    $self->{PASSWORD} = undef;

    bless ($self, $class);
    return $self;
}

sub config {
    my $self = shift;
    my ($network, $conn, $name) = @_;

    $self->server($network->{server});
    $self->port($network->{port});
    $self->password($network->{password});
    $self->nickname($network->{nickname});
    $self->username($network->{username});

    return 1;
}

sub irc {
    my $self = shift;
    if (@_) { $self->{IRC} = shift }
    return $self->{IRC};
}

sub nickname {
    my $self = shift;
    if (@_) { $self->{NICKNAME} = shift }
    return $self->{NICKNAME};
}

sub username {
    my $self = shift;
    if (@_) { $self->{USERNAME} = shift }
    return $self->{USERNAME};
}

sub server {
    my $self = shift;
    if (@_) { $self->{SERVER} = shift }
    return $self->{SERVER};
}

sub port {
    my $self = shift;
    if (@_) { $self->{PORT} = shift }
    return $self->{PORT};
}

sub password {
    my $self = shift;
    if (@_) { $self->{PASSWORD} = shift }
    return $self->{PASSWORD};
}

sub run {
    my $self = shift;

    my $irc = AnyEvent::IRC::Client->new();
    $self->irc($irc);
    $irc->connect( $self->server, $self->port, {
        nick => $self->nickname,
        user => $self->username,
        password => $self->password,
        timeout => 1,
    } );
    $irc->reg_cb(
        connect => sub { carp "connected" },
        registered => sub { carp "registered" },
        disconnect => sub { carp "disconnected" }
        # connect     => sub { $self->call_hook( 'server.connected', @_ ) },
        # disconnect  => sub { $self->call_hook( 'server.disconnect', @_ ) },
        # irc_privmsg => sub { 
        #     my ($nick, $raw) = @_;
        #     my $message = Morris::Message->new(
        #         channel => $raw->{params}->[0],
        #         message => $raw->{params}->[1],
        #         from    => $raw->{prefix},
        #     );
        #     $self->call_hook( 'chat.privmsg', $message )
        # },

        # # XXX - we want the /full/ details of this user, not his nick
        # #       so we override the original irc_join callback
        # irc_join => sub { 
        #     my $object = shift;
        #     $object->AnyEvent::IRC::Client::join_cb(@_);
        #     # and /THEN/ call our callback
        #     # fix the param thing to be just a simple 'channel' parameter
        #     my $channel = $_[0]->{params}->[0];
        #     my $addr    = Edgar::Message::Address->new( $_[0]->{prefix} );
        #     $self->call_hook( 'channel.joined', $channel, $addr );
        # },
        # registered  => sub { $self->call_hook( 'server.registered', @_ ) },
    );
}

1;