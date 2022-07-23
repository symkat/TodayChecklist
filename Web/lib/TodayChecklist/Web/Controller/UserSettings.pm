package TodayChecklist::Web::Controller::UserSettings;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub profile ( $c ) {
    $c->stash->{form_name}     = $c->stash->{person}->name;
    $c->stash->{form_email}    = $c->stash->{person}->email;
}

sub do_profile ( $c ) {
    $c->stash->{template} = 'user_settings/profile';

    my $name     = $c->stash->{form_name}     = $c->param('name');
    my $email    = $c->stash->{form_email}    = $c->param('email');
    my $password = $c->stash->{form_password} = $c->param('password');
    
    # Populate errors if we don't have values.
    push @{$c->{stash}->{errors}}, "You must enter your name"      unless $name; 
    push @{$c->{stash}->{errors}}, "You must enter your email"    unless $email;
    push @{$c->{stash}->{errors}}, "You must enter your password" unless $password;

    # Bail out if we have errors now.
    return 0 if $c->stash->{errors};

    $c->stash->{person}->auth_password->check_password( $password )
        or push @{$c->stash->{errors}}, "You must enter your current login password correctly.";
    
    # Bail out if we have errors now.
    return 0 if $c->stash->{errors};

    $c->stash->{person}->name( $name );
    $c->stash->{person}->email( $email );

    $c->stash->{person}->update;

    # Let the user know the action was successful.
    $c->stash->{success} = 1;
    $c->stash->{success_message} = "Your records were updated.";
}

sub change_password ( $c ) { }

sub do_change_password ( $c ) {
    $c->stash->{template} = 'user_settings/change_password';

    # Get the values the user gave for the password change.
    my $password = $c->stash->{form_password}         = $c->param('password');
    my $new_pass = $c->stash->{form_new_password}     = $c->param('new_password');
    my $confirm  = $c->stash->{form_password_confirm} = $c->param('password_confirm');

    # Populate errors if we don't have values.
    push @{$c->{stash}->{errors}}, "You must enter your current password"               unless $password; 
    push @{$c->{stash}->{errors}}, "You must enter your new password"                   unless $new_pass;
    push @{$c->{stash}->{errors}}, "You must enter your new password again to confirm"  unless $confirm;
    
    # Bail out if we have errors now.
    return 0 if $c->stash->{errors};

    $c->stash->{person}->auth_password->check_password( $password )
        or push @{$c->stash->{errors}}, "You must enter your current login password correctly.";
    
    # Bail out if we have errors now.
    return 0 if $c->stash->{errors};
    
    push @{$c->stash->{errors}}, "Password and confirm password must match"
        unless $new_pass eq $confirm;

    push @{$c->stash->{errors}}, "Password must be at least 8 characters"
        unless length($new_pass) >= 8;
    
    # Bail out if we have errors now.
    return if $c->stash->{errors};

    # We can update the password now.
    $c->stash->{person}->auth_password->update_password($new_pass);

    # Let the user know the action was successful.
    $c->stash->{success} = 1;
    $c->stash->{success_message} = "Your password was updated.";

    # Clear the form values on success.
    $c->stash->{form_password}         = "";
    $c->stash->{form_new_password}     = "";
    $c->stash->{form_password_confirm} = "";
}

sub subscription ($c) {
    my $status = $c->param('status');

    # No status=, the user themself requested this page.
    if ( ! $status ) {
        return;
    }

    # Status isn't successful, tell the user they could try agan.
    if ( $status ne 'success' ) {
        return;
    }

    my $session_id = $c->param('session_id');

    my $customer_id = $c->ua->get( $c->config->{stripe_backend} . '/stripe/session-to-customer?session_id=' . $session_id )->result->json->{customer_id};

    # Store the customer id along side the user in the DB.
    if ( $customer_id ) {
        $c->db->storage->schema->txn_do( sub {
            $c->stash->{person}->stripe_customer_id( $customer_id );
            $c->stash->{person}->is_subscribed( 1 );
            $c->stash->{person}->update;
        });
    }
}

# Send to stripe to signup for the subscription
sub do_subscription ($c) {
    my $lookup_key = $c->param('lookup_key');
    my $url = $c->ua->get( $c->config->{stripe_backend} . '/stripe/get-checkout-link?lookup_key=' . $lookup_key )->result->json->{url};

    $c->redirect_to( $url );
}

# Send to stripe to manage the subscription
sub do_subscription_manage ($c) {
    my $url = $c->ua->get( $c->config->{stripe_backend} . '/stripe/get-portal-link?customer_id=' . $c->stash->{person}->stripe_customer_id )->result->json->{url};

    $c->redirect_to( $url );
}

1;
