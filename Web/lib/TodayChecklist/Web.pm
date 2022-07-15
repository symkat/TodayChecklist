package TodayChecklist::Web;
use Mojo::Base 'Mojolicious', -signatures;
use TodayChecklist::DB;

sub startup ($self) {
    my $config = $self->plugin('NotYAMLConfig', { file => -e 'todaychecklist.yml' 
        ? 'todaychecklist.yml' 
        : '/etc/todaychecklist.yml'
    });

    # Configure the application
    $self->secrets($config->{secrets});

    # Set the cookie expires to 30 days.
    $self->sessions->default_expiration(2592000);

    # Load our custom commands.
    push @{$self->commands->namespaces}, 'TodayChecklist::Web::Command';

    $self->helper( db => sub {
        return state $db = TodayChecklist::DB->connect($config->{database}->{todaychecklist});
    });

    # Standard router.
    my $r = $self->routes->under( '/' => sub ($c)  {

        # If the user has a uid session cookie, then load their user account.
        if ( $c->session('uid') ) {
            my $person = $c->db->resultset('Person')->find( $c->session('uid') );
            if ( $person && $person->is_enabled ) {
                $c->stash->{person} = $person;
            }
        }

        return 1;
    });

    # Create a router chain that ensures the request is from an authenticated user.
    my $auth = $r->under( '/' => sub ($c) {

        # Logged in user exists.
        if ( $c->stash->{person} ) {
            return 1;
        }

        # No user account for this seession.
        $c->redirect_to( $c->url_for( 'show_login' ) );
        return undef;
    });

    # Create a router chain that ensures the request is from an admin user.
    my $admin = $auth->under( '/' => sub ($c) {

        # Logged in user exists.
        if ( $c->stash->{person}->is_admin ) {
            return 1;
        }

        # No user account for this seession.
        $c->redirect_to( $c->url_for( 'show_dashboard' ) );
        return undef;
    });

    # User registration, login, and logout.
    $r->get   ( '/register' )->to( 'Auth#register'    )->name('show_register' );
    $r->post  ( '/register' )->to( 'Auth#do_register' )->name('do_register'   );
    $r->get   ( '/login'    )->to( 'Auth#login'       )->name('show_login'    );
    $r->post  ( '/login'    )->to( 'Auth#do_login'    )->name('do_login'      );
    $auth->get( '/logout'   )->to( 'Auth#do_logout'   )->name('do_logout'     );

    # User Forgot Password Workflow.
    $r->get ( '/forgot'       )->to('Auth#forgot'    )->name('show_forgot' );
    $r->post( '/forgot'       )->to('Auth#do_forgot' )->name('do_forgot'   );
    $r->get ( '/reset/:token' )->to('Auth#reset'     )->name('show_reset'  );
    $r->post( '/reset/:token' )->to('Auth#do_reset'  )->name('do_reset'    );

    # User setting changes when logged in
    $auth->get ( '/profile'  )->to('UserSettings#profile'            )->name('show_profile'         );
    $auth->post( '/profile'  )->to('UserSettings#do_profile'         )->name('do_profile'           );
    $auth->get ( '/password' )->to('UserSettings#change_password'    )->name('show_change_password' );
    $auth->post( '/password' )->to('UserSettings#do_change_password' )->name('do_change_password'   );

    # Send requests for / to the dashboard.
    $r->get('/')->to(cb => sub ($c) {
        $c->redirect_to( $c->url_for('dashboard') );
    });

    # User dashboard
    $auth->get( '/dashboard'                 )->to('Dashboard#index'         )->name('show_dashboard'    );

    # Manage Templates
    $auth->get ( '/template'                 )->to('Template#create'         )->name('show_template_create'     );
    $auth->post( '/template'                 )->to('Template#do_create'      )->name('do_template_create'       );
    $auth->get ( '/template/:id/vars'        )->to('Template#vars'           )->name('show_template_vars'       );
    $auth->post( '/template/:id/vars'        )->to('Template#do_vars'        )->name('do_template_vars'         );

    # Manage Checklists
    $auth->get( '/checklist'                )->to('Checklist#create'        )->name('show_checklist_create'    );

    

}

1;
