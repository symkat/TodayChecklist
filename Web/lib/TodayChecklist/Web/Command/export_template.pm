package TodayChecklist::Web::Command::export_template;
use Mojo::Base 'Mojolicious::Command';
use DBIx::Class::Schema::Config;
use JSON::MaybeXS;

use Mojo::Util qw( getopt );

has description => "Export a template by id.";
has usage       => "$0 export_template <template_id>\n";

sub run {
    my ( $self, $id ) = @_;

    die "Error: you must provide a template id for exporting.\n"
        unless $id;

    my $template = $self->app->db->template( $id );

    die "Error: couldn't find a template with the id $id?\n"
        unless $template;


    my $obj = {
        name        => $template->name,
        description => $template->description,
        content     => $template->content,
        vars        => [  ],
    };

    my $rs = $template->search_related('template_vars');

    while ( my $var = $rs->next ) {
        push @{$obj->{vars}}, {
            name                   => $var->name,
            title                  => $var->title,
            description            => $var->description,
            weight                 => $var->weight,
            template_var_type_id   => $var->template_var_type->id,
            template_var_type_name => $var->template_var_type->name,
        };
    }

    print encode_json( $obj );
}

1;
