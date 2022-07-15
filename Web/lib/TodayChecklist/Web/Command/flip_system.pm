package TodayChecklist::Web::Command::flip_system;
use Mojo::Base 'Mojolicious::Command';
use DBIx::Class::Schema::Config;

use Mojo::Util qw( getopt );

has description => "Flip a template's is_system bit.";
has usage       => "$0 flip_system <template_id>\n";

sub run {
    my ( $self, $id ) = @_;

    die "Error: you must provide a template id.\n"
        unless $id;

    my $template = $self->app->db->template( $id );

    die "Error: couldn't find any template with the id $id?\n"
        unless $template;

    if ( $template->is_system ) {
        $template->is_system(0);
        print "That template was previously a system template.  Now it is not.\n";
    } else {
        $template->is_system(1);
        print "$id (" . $template->name . ") is now a system template.\n";
    }

    $template->update;
}

1;
