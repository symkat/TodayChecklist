package TodayChecklist::Web::Controller::Dashboard;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($c) { 
    if ( $c->stash->{person}->search_related('templates', {})->count == 0 ) {
        $c->redirect_to( $c->url_for( 'show_dashboard_templates_default' ) );
        return;
    }

    push @{$c->stash->{documents}},
        $c->stash->{person}->search_related('documents')->all;
}

sub document ($c) { 
    push @{$c->stash->{documents}},
        $c->stash->{person}->search_related('documents')->all;
    
}

sub templates ($c) { 
    if ( $c->stash->{person}->search_related('documents', {})->count == 0 ) {
        $c->stash->{guide_no_documents} = 1;
        if ( $c->stash->{person}->search_related('templates', {})->count == 0 ) {
            $c->redirect_to( $c->url_for( 'show_dashboard_templates_default' ) );
            return;
        }
    };

    push @{$c->stash->{templates}},
        $c->stash->{person}->search_related('templates')->all;
    
}

sub templates_edit ($c) { 
    push @{$c->stash->{templates}},
        $c->stash->{person}->search_related('templates')->all;
}

sub templates_default ($c) { 
    if ( $c->stash->{person}->search_related('templates', {})->count == 0 ) {
        $c->stash->{guide_no_templates} = 1;
    }

    push @{$c->stash->{templates}},
        $c->db->templates( { is_system => 1 } )->all;
}

1;
