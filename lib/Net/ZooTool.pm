package Net::ZooTool;

use Moose;
with 'Net::ZooTool::Utils';

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

=head2
    This is the global method to add a new item to a user's Zoo.
    You can feed it with some additional parameters to set the information
    about the item, like tags, description and stuff. If the item
    already exists in the user's Zoo, it won't be added again . The option
    to overwrite existing items with new values will follow later.
=cut
sub add {
    my ( $self, $args ) = @_;

    $args->{apikey} = $self->auth->apikey;

    my $data = _fetch('/add/' . _hash_to_query_string($args), $self->auth);
    return $data;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
