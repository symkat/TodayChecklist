package TodayChecklist::Web::Controller::Template;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub create ($c) { 
 
}

sub do_create ($c) {
    $c->stash->{template} = 'template/create';

    my $name = $c->stash->{form_name} = $c->param('name');
    my $desc = $c->stash->{form_desc} = $c->param('desc');
    my $html = $c->stash->{form_tmpl} = $c->param('tmpl');
    my $css  = $c->stash->{form_css}  = $c->param('css');

    push @{$c->stash->{errors}}, "Template name is required"         unless $name;
    push @{$c->stash->{errors}}, "Template description is required"  unless $desc;
    push @{$c->stash->{errors}}, "Template html content is required" unless $html;

    return if $c->stash->{errors};

    my $template = $c->stash->{person}->create_related('templates', {
        name => $name,
        description => $desc,
        template_content => $html,
        ( $css ? ( css_content => $css ) : () ),
    });

    $c->redirect_to( $c->url_for( 'show_template_vars', { id => $template->id } ) );
}

sub vars ($c) { 
    my $id       = $c->stash->{template_id}  = $c->param('id');
    my $template = $c->stash->{template_obj} = $c->db->template($id);

    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {} )->all;
}

sub do_vars ($c) {
    $c->stash->{template} = 'template/vars';

    my $id       = $c->stash->{template_id}   = $c->param('id');
    my $template = $c->stash->{template_obj}  = $c->db->template($id);
    
    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {} )->all;

    my $var_name = $c->stash->{form_var_name} = $c->param('var_name');
    my $var_desc = $c->stash->{form_var_desc} = $c->param('var_desc');
    my $var_type = $c->stash->{form_var_type} = $c->param('var_type');

    push @{$c->stash->{errors}}, "Variable name is required"         unless $var_name;
    push @{$c->stash->{errors}}, "Variable description is required"  unless $var_desc;
    push @{$c->stash->{errors}}, "Variable type is required"         unless $var_type;

    return if $c->stash->{errors};

    my $type = $c->db->template_var_types->single( { name => $var_type } );

    push @{$c->stash->{errors}}, "Invalid type" unless $type;

    return if $c->stash->{errors};

    $template->create_related( 'template_vars', {
        name                 => $var_name,
        description          => $var_desc,
        template_var_type_id => $type->id,
    });

    $c->redirect_to( $c->url_for( 'show_template_vars', { id => $id } ) );
}

1;
