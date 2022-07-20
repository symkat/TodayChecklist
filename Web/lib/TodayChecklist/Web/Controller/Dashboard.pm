package TodayChecklist::Web::Controller::Dashboard;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($c) { 
    push @{$c->stash->{documents}},
        $c->stash->{person}->search_related('documents')->all;
    
}

sub document ($c) { 
    push @{$c->stash->{documents}},
        $c->stash->{person}->search_related('documents')->all;
    
}

sub templates ($c) { 
    push @{$c->stash->{templates}},
        $c->stash->{person}->search_related('templates')->all;
    
}

sub templates_edit ($c) { 
    push @{$c->stash->{templates}},
        $c->stash->{person}->search_related('templates')->all;
    
}

sub templates_default ($c) { 
    push @{$c->stash->{templates}},
        $c->db->templates( { is_system => 1 } )->all;
}

1;
