package TodayChecklist::Web::Controller::Document;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Text::Xslate;

my $xslate = Text::Xslate->new( 
    cache  => 0,
    syntax => 'Metakolon',
);

sub index ($c) {
    push @{$c->stash->{document_templates}},
        $c->stash->{person}->search_related( 'templates' )->all;

    # Enable a warning to be displayed that the documents will not save if a free account
    # exceeds the 7 documents allowed.
    if ( ! $c->stash->{person}->is_subscribed ) {
        if ( $c->stash->{person}->search_related('documents', {})->count >= 7 ) {
            $c->stash->{exceed_free_warning} = 1;
        }
    }
}

sub create ($c) { 
    my $template_id = $c->param('template_id');
    my $template    = $c->stash->{template_obj} = $c->db->template($template_id);
    
    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {}, { order_by => qw( weight ) } )->all;
}

sub do_create ($c) { 
    $c->stash->{template} = 'document/create';

    my $template_id = $c->param('template_id');
    my $template    = $c->stash->{template_obj} = $c->db->template($template_id);

    my $name        = $c->stash->{form_document_name} = $c->param( 'document_name' );
    my $desc        = $c->stash->{form_document_desc} = $c->param( 'document_desc' );
    
    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {} )->all;

    my $payload = {};

    if ( ! $c->stash->{person}->is_subscribed ) {
        if ( $c->stash->{person}->search_related( 'documents', {} )->count >= 7 ) {
            push @{$c->stash->{errors}}, "You have exceeded the document allowance for a free account.";
        }
    }

    foreach my $var (  @{$c->stash->{template_vars}} ) {
        if ( ! $c->param( $var->name ) ) {
            push @{$c->stash->{errors}}, "The form field for " . $var->name . " is required.";
        }

        if ( $var->template_var_type->name eq 'array' ) {
            push @{$payload->{$var->name}}, split( /\n/, $c->param($var->name) );
        } else {
            $payload->{$var->name} = $c->param($var->name);
        }

       $c->stash->{'form_' . $var->name} = $c->param($var->name);
    }


    push @{$c->stash->{errors}}, "Document name is required."        unless $name;
    push @{$c->stash->{errors}}, "Document description is required." unless $desc;

    return if $c->stash->{errors};

    $c->stash->{person}->create_related( 'documents', {
        name        => $name,
        description => $desc,
        template_id => $template_id,
        payload     => $payload,
    });

    $c->redirect_to( $c->url_for( 'show_dashboard' ) );
}

sub do_render ($c) {
    my $document_id = $c->param('document_id');
    my $document    = $c->stash->{document} = $c->db->document($document_id);

    if ( $c->stash->{person}->id ne $document->person_id ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }

    my $content = $xslate->render_string( $document->template->content, $document->payload );

    $c->render(
        data   => $content,
        format => 'html',
        status => 200,
    );
}

sub do_remove ($c) {
    my $document_id = $c->param('id');
    my $document    = $c->stash->{document} = $c->db->document($document_id);
    
    if ( $c->stash->{person}->id ne $document->person_id ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }

    $document->delete;

    $c->redirect_to( $c->url_for( 'show_dashboard_document' ) );

}

1;
