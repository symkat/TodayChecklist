package TodayChecklist::Web::Command::import_template;
use Mojo::Base 'Mojolicious::Command';
use DBIx::Class::Schema::Config;
use JSON::MaybeXS;

use Mojo::Util qw( getopt );

has description => "Export a template from an export file";
has usage       => "$0 import_template <file/path>\n";

sub run {
    my ( $self, $file ) = @_;

    open my $lf, "<", $file
        or die "Failed to read file $file: $!";

    my $content = do { local $/; <$lf> };

    my $obj = decode_json( $content );

    my $system_user = $self->app->db->person( { email => 'system@todaychecklist.com' } );

    $self->app->db->storage->schema->txn_do( sub {
        my $template = $system_user->create_related('templates', {
            name        => $obj->{name},
            description => $obj->{description},
            content     => $obj->{content},
            is_system   => 1,
        });

        foreach my $var ( @{$obj->{vars}} ) {
            $template->create_related('template_vars', {
                name                   => $var->{name},
                title                  => $var->{title},
                description            => $var->{description},
                weight                 => $var->{weight},
                template_var_type_id   => $var->{template_var_type_id},
            });
        }
    });
}

1;
