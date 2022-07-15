package TodayChecklist::Web::Controller::Checklist;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($c) {
    push @{$c->stash->{checklist_templates}},
        $c->stash->{person}->search_related( 'templates' )->all;
}

sub create ($c) { 
    my $template_id = $c->param('template_id');
    my $template    = $c->stash->{template_obj} = $c->db->template($template_id);
    
    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {} )->all;
}

sub do_create ($c) { 
    $c->stash->{template} = 'checklist/create';

    my $template_id = $c->param('template_id');
    my $template    = $c->stash->{template_obj} = $c->db->template($template_id);

    my $name        = $c->stash->{form_checklist_name} = $c->param( 'checklist_name' );
    my $desc        = $c->stash->{form_checklist_desc} = $c->param( 'checklist_desc' );
    
    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {} )->all;

    my $payload = {};

    foreach my $var (  @{$c->stash->{template_vars}} ) {
        if ( ! $c->param( $var->name ) ) {
            push @{$c->stash->{errors}}, "The form field for " . $var->name . " is required.";
        }

        if ( $var->template_var_type->name eq 'checklist_array' ) {
            push @{$payload->{$var->name}}, split( /\n/, $c->param($var->name) );
        } else {
            $payload->{$var->name} = $c->param($var->name);
        }

       $c->stash->{'form_' . $var->name} = $c->param($var->name);
    }


    push @{$c->stash->{errors}}, "Checklist name is required."        unless $name;
    push @{$c->stash->{errors}}, "Checklist description is required." unless $desc;

    return if $c->stash->{errors};

    $c->stash->{person}->create_related( 'checklists', {
        name        => $name,
        description => $desc,
        template_id => $template_id,
        payload     => $payload,
    });

    $c->redirect_to( $c->url_for( 'show_dashboard' ) );
}

1;
