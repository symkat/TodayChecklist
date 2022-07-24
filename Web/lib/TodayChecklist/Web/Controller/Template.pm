package TodayChecklist::Web::Controller::Template;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub create ($c) { 
    # Enable a warning to be displayed that the documents will not save if a free account
    # exceeds the 5 templates allowed.
    if ( ! $c->stash->{person}->is_subscribed ) {
        if ( $c->stash->{person}->search_related('templates', {})->count >= 5 ) {
            $c->stash->{exceed_free_warning} = 1;
        }
    }
}

sub do_create ($c) {
    $c->stash->{template} = 'template/create';

    my $name = $c->stash->{form_name} = $c->param('name');
    my $desc = $c->stash->{form_desc} = $c->param('desc');
    my $html = $c->stash->{form_tmpl} = $c->param('tmpl');
    
    if ( ! $c->stash->{person}->is_subscribed ) {
        if ( $c->stash->{person}->search_related( 'templates', {} )->count >= 5 ) {
            push @{$c->stash->{errors}}, "You must subscribe to save more than 5 templates.";
        }
    }

    push @{$c->stash->{errors}}, "Template name is required"         unless $name;
    push @{$c->stash->{errors}}, "Template description is required"  unless $desc;
    push @{$c->stash->{errors}}, "Template html content is required" unless $html;

    if ( ! $c->stash->{person}->is_subscribed ) {
        if ( $c->stash->{person}->search_related('templates', {})->count >= 5 ) {
            push @{$c->stash->{errors}}, "You have exceeded the template allowance for a free account."
        }
    }

    return if $c->stash->{errors};

    my $template = $c->stash->{person}->create_related('templates', {
        name        => $name,
        description => $desc,
        content     => $html,
    });

    $c->redirect_to( $c->url_for( 'show_template_vars', { id => $template->id } ) );
}

sub vars ($c) { 
    my $id       = $c->stash->{template_id}  = $c->param('id');
    my $template = $c->stash->{template_obj} = $c->db->template($id);

    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {}, { order_by => qw( weight ) } )->all;
}

sub do_vars ($c) {
    $c->stash->{template} = 'template/vars';

    my $id       = $c->stash->{template_id}   = $c->param('id');
    my $template = $c->stash->{template_obj}  = $c->db->template($id);
    
    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {} )->all;

    my $var_name   = $c->stash->{form_var_name}   = $c->param('var_name');
    my $var_weight = $c->stash->{form_var_weight} = $c->param('var_weight');
    my $var_title  = $c->stash->{form_var_name}   = $c->param('var_title');
    my $var_desc   = $c->stash->{form_var_desc}   = $c->param('var_desc');
    my $var_type   = $c->stash->{form_var_type}   = $c->param('var_type');

    push @{$c->stash->{errors}}, "Variable name is required"         unless $var_name;
    push @{$c->stash->{errors}}, "Variable weight is required"       unless $var_weight;
    push @{$c->stash->{errors}}, "Variable title is required"        unless $var_title;
    push @{$c->stash->{errors}}, "Variable description is required"  unless $var_desc;
    push @{$c->stash->{errors}}, "Variable type is required"         unless $var_type;

    return if $c->stash->{errors};

    my $type = $c->db->template_var_types->single( { name => $var_type } );

    push @{$c->stash->{errors}}, "Invalid type" unless $type;

    return if $c->stash->{errors};

    $template->create_related( 'template_vars', {
        name                 => $var_name,
        weight               => $var_weight,
        title                => $var_title,
        description          => $var_desc,
        template_var_type_id => $type->id,
    });

    $c->redirect_to( $c->url_for( 'show_template_vars', { id => $id } ) );
}

sub remove_vars ($c) {
    $c->stash->{template} = 'template/vars';

    my $id       = $c->stash->{template_id}   = $c->param('id');
    my $template = $c->stash->{template_obj}  = $c->db->template($id);
    
    my $var_id   = $c->param('var_id');
    my $var_obj  = $c->db->template_var($var_id);

    # Confirm permissions....
    
    # Var belongs to the template submitted.
    push @{$c->stash->{errors}}, "You do not have permission to do that."
        if $var_obj->template_id ne $template->id;
   
    # Template belongs to the current user.
    push @{$c->stash->{errors}}, "You do not have permission to do that."
        if $template->person_id ne $c->stash->{person}->id;

    return if $c->stash->{errors};

    $var_obj->delete;
    
    $c->redirect_to( $c->url_for( 'show_template_vars', { id => $id } ) );
}

sub editor ($c) {
    my $id       = $c->stash->{template_id}   = $c->param('id');
    my $template = $c->stash->{template_obj}  = $c->db->template($id);

    $c->stash->{form_name} = $template->name;
    $c->stash->{form_desc} = $template->description;
    $c->stash->{html_tmpl} = $template->content;
}

sub do_editor ($c) {
    my $id       = $c->stash->{template_id}   = $c->param('id');
    my $template = $c->stash->{template_obj}  = $c->db->template($id);
    
    my $name = $c->stash->{form_name} = $c->param('name');
    my $desc = $c->stash->{form_desc} = $c->param('desc');
    my $html = $c->stash->{form_tmpl} = $c->param('tmpl');

    push @{$c->stash->{errors}}, "Template name is required"         unless $name;
    push @{$c->stash->{errors}}, "Template description is required"  unless $desc;
    push @{$c->stash->{errors}}, "Template html content is required" unless $html;

    return if $c->stash->{errors};

    $template->name( $name );
    $template->description( $desc );
    $template->content( $html );

    $template->update;

    $c->redirect_to( $c->url_for( 'show_dashboard_templates' ) );

}

sub do_copy ($c) {
    my $id       = $c->stash->{template_id}   = $c->param('id');
    my $template = $c->stash->{template_obj}  = $c->db->template($id);
    
    # Only allow system templates to be copied.
    if ( ! $template->is_system ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }

    $c->db->storage->schema->txn_do( sub {
        my $copy = $c->stash->{person}->create_related( 'templates', {
            name        => $template->name,
            description => $template->description,
            content     => $template->content,
        });

        my $rs = $template->search_related('template_vars');

        while ( my $var = $rs->next ) {
            $copy->create_related('template_vars', {
                name                 => $var->name,
                title                => $var->title,
                description          => $var->description,
                weight               => $var->weight,
                template_var_type_id => $var->template_var_type_id,
            });
        }
    });
    
    $c->redirect_to( $c->url_for( 'show_dashboard_templates' ) );
}
    
sub do_remove ($c) {
    my $id       = $c->stash->{template_id}   = $c->param('id');
    my $template = $c->stash->{template_obj}  = $c->db->template($id);
    
    if ( $c->stash->{person}->id ne $template->person_id ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }

    $c->db->storage->schema->txn_do( sub {
        $template->search_related( 'template_vars' )->delete;
        $template->delete;
    });

    $c->redirect_to( $c->url_for( 'show_dashboard_templates' ) );
}

1;
