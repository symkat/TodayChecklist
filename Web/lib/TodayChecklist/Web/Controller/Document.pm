package TodayChecklist::Web::Controller::Document;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Text::Xslate;

my $xslate = Text::Xslate->new( 
    cache  => 0,
    syntax => 'Metakolon',
    function => {
        strip_colon => sub {
            my $string = shift;
            $string =~ s/:$//;
            return $string;
        },
    },
);

sub index ($c) {
    # If this person does not have any templates, send them to the template dashboard
    # to be instructed to copy a template.
    if ( $c->stash->{person}->search_related('templates', {})->count == 0 ) {
        $c->redirect_to( $c->url_for( 'show_dashboard_templates_default' ) );
        return;
    }

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

# Given a document id, bring the user to the editor with things filled in.
sub editor ($c) {
    my $id       = $c->param('id');
    my $document = $c->db->document($id);

    if ( $c->stash->{person}->id != $document->person_id ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }

    my $template_id = $document->template_id;
    my $template    = $c->stash->{template_obj} = $c->db->template($template_id);
    
    my $vars = $template->search_related( 'template_vars', {}, { order_by => qw( weight ) } );

    while ( my $var = $vars->next ) {
        push @{$c->stash->{template_vars}}, $var;
        if ( ref $document->payload->{$var->name} eq 'ARRAY' ) {
            $c->stash->{'form_' . $var->name} = join "\n", @{$document->payload->{$var->name}};
        } elsif ( ref $document->payload->{$var->name} eq 'HASH' ) {
            $c->stash->{'form_' . $var->name} = unprocess_nested_checklist( $document->payload->{$var->name} );
        } else {
            $c->stash->{'form_' . $var->name} = $document->payload->{$var->name};
        }
    }
}

# Update a document.
sub do_editor ($c) {
    $c->stash->{template} = 'document/editor';

    my $id       = $c->param('id');
    my $document = $c->db->document($id);

    if ( $c->stash->{person}->id != $document->person_id ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }

    my $template_id = $document->template_id;
    my $template    = $c->stash->{template_obj} = $c->db->template($template_id);
    
    push @{$c->stash->{template_vars}}, 
        $template->search_related( 'template_vars', {}, { order_by => qw( weight ) } )->all;
    
    my $payload = {};

    foreach my $var (  @{$c->stash->{template_vars}} ) {
        if ( ! $c->param( $var->name ) ) {
            push @{$c->stash->{errors}}, "The form field for " . $var->name . " is required.";
        }

        if ( $var->template_var_type->name eq 'array' ) {
            push @{$payload->{$var->name}}, split( /\n/, $c->param($var->name) );
        } elsif ( $var->template_var_type->name eq 'nested_checklist' ) {
            $payload->{$var->name} = process_nested_checklist( $c->param($var->name) );
        } else {
            $payload->{$var->name} = $c->param($var->name);
        }

       $c->stash->{'form_' . $var->name} = $c->param($var->name);
    }
    
    return if $c->stash->{errors};

    $document->payload( $payload );
    $document->update;
    
    $c->redirect_to( $c->url_for( 'show_dashboard' ) );

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
        } elsif ( $var->template_var_type->name eq 'nested_checklist' ) {
            $payload->{$var->name} = process_nested_checklist( $c->param($var->name) );
        } else {
            $payload->{$var->name} = $c->param($var->name);
        }

       $c->stash->{'form_' . $var->name} = $c->param($var->name);
    }

    return if $c->stash->{errors};

    my $document = $c->stash->{person}->create_related( 'documents', {
        template_id => $template_id,
        payload     => $payload,
    });

    $c->redirect_to( $c->url_for( 'show_document_name', { id => $document->id } ) );
}

sub name ($c) {
    my $id       = $c->stash->{id}       = $c->param('id');
    my $document = $c->stash->{document} = $c->db->document($id);

    $c->stash->{form_document_name} = $document->name;

    if ( $c->stash->{person}->id != $document->person_id ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }
}

sub do_name ($c) {
    my $id       = $c->param('id');
    my $document = $c->db->document($id);

    if ( $c->stash->{person}->id != $document->person_id ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }
    
    my $name = $c->stash->{form_document_name} = $c->param( 'document_name' );
    
    push @{$c->stash->{errors}}, "Document name is required."
        unless $name;

    return if $c->stash->{errors};

    $document->name( $name );
    $document->update;

    $c->redirect_to( $c->url_for( 'show_dashboard' ) );
}


sub do_render ($c) {
    my $document_id = $c->param('document_id');
    my $document    = $c->stash->{document} = $c->db->document($document_id);

    if ( $c->stash->{person}->id != $document->person_id ) {
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
    
    if ( $c->stash->{person}->id != $document->person_id ) {
        $c->render(
            text   => "Access denied",
            status => 403,
        );
        return;
    }

    $document->delete;

    $c->redirect_to( $c->url_for( 'show_dashboard_document' ) );

}

sub process_nested_checklist ($content) {

    my $result  = {};
    my $section = "";
    my @section_order;
    foreach my $line ( split( /\r\n/, $content ) ) {
        if ( $line =~ /:$/ ) {
            $section = $line;
            push @section_order, $section;
            next;
        }

        push @{$result->{$section}}, $line;
    }

    return { order => [ @section_order ], data => $result };
}

sub unprocess_nested_checklist ($var) {
    my $content;

    if ( $var->{data}->{""} ) {
        $content = join( "\r\n", @{$var->{data}->{""}} );
    }

    foreach my $section ( @{$var->{order}} ) {
        $content .= "$section\r\n";
        $content .= join( "\r\n", @{$var->{data}->{$section}} );
        $content .= "\r\n";
    }

    return $content;
}

1;
