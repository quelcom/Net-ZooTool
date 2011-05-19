package Net::ZooTool;

use Moose;
use Carp;

use Net::ZooTool::Auth;
use Net::ZooTool::User;
use Net::ZooTool::Item;

use namespace::autoclean;

our $VERSION = '0.001';

has auth => (
    isa => 'Net::ZooTool::Auth',
    is  => 'ro',
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    # Transform normal params to hashref
    if ( !ref $_[0] ) {
        if ( scalar @_ == 1 ) {
            return $class->$orig( apikey => $_[0] );
        }
        elsif ( scalar @_ == 3 ) {
            return $class->$orig( apikey => $_[0], user => $_[1], password => $_[2] );
        }
        else {
            croak "Unaccepted params";
        }
    }

    # Hashref checkings
    if ( ref $_[0] and !$_[0]->{apikey} ) {
        croak "You have to provide at least the apikey as either parameter or hashref";
    }

    # You need to provide username and password
    if ( defined $_[0]->{user} and !defined $_[0]->{password} ) {
        croak "If you provide user you also need to provide password";
    }

    if ( defined $_[0]->{password} and !defined $_[0]->{user} ) {
        croak "If you provide password you also need to provide username";
    }

    # If you have reached here everything is good

    return $class->$orig(@_);
};

sub BUILD {
    my $self = shift;
    my $args = shift;

    $self->{auth} = Net::ZooTool::Auth->new(
        {
            apikey   => $args->{apikey},
            user     => $args->{user},
            password => $args->{password},
        }
    );
}

sub user {
    my $self = shift;
    return Net::ZooTool::User->new({ auth => $self->auth });
}

sub item {
    my $self = shift;
    return Net::ZooTool::Item->new({ auth => $self->auth });
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
