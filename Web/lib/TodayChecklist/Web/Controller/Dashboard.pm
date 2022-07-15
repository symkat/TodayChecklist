package TodayChecklist::Web::Controller::Dashboard;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($c) { 
    push @{$c->stash->{checklists}},
        $c->stash->{person}->search_related('checklists')->all;
    
}

sub checklist ($c) { 
    push @{$c->stash->{checklists}},
        $c->stash->{person}->search_related('checklists')->all;
    
}

1;
