use utf8;
package TodayChecklist::DB::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodayChecklist::DB::Result::Person

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Serializer");

=head1 TABLE: C<person>

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'person_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'citext'
  is_nullable: 0

=head2 is_enabled

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 is_admin

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "person_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "citext", is_nullable => 0 },
  "is_enabled",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "is_admin",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<person_email_key>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("person_email_key", ["email"]);

=head1 RELATIONS

=head2 auth_password

Type: might_have

Related object: L<TodayChecklist::DB::Result::AuthPassword>

=cut

__PACKAGE__->might_have(
  "auth_password",
  "TodayChecklist::DB::Result::AuthPassword",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 auth_tokens

Type: has_many

Related object: L<TodayChecklist::DB::Result::AuthToken>

=cut

__PACKAGE__->has_many(
  "auth_tokens",
  "TodayChecklist::DB::Result::AuthToken",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_settings

Type: has_many

Related object: L<TodayChecklist::DB::Result::PersonSetting>

=cut

__PACKAGE__->has_many(
  "person_settings",
  "TodayChecklist::DB::Result::PersonSetting",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-14 16:11:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zmj6zl0oOEsPloF4hrJwng


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use Data::GUID;

sub setting {
    my ( $self, $setting, $value ) = @_;

    if ( defined $value ) {
        my $rs = $self->find_or_new_related( 'person_settings', { name => $setting } );
        $rs->value( ref $value ? $value : { value => $value } );

        $rs->update if     $rs->in_storage;
        $rs->insert unless $rs->in_storage;

        return $value;
    } else {
        my $result = $self->find_related('person_settings', { name => $setting });
        return undef unless $result;
        return $self->_get_setting_value($result);
    }
}

sub _get_setting_value {
    my ( $self, $setting ) = @_;

    if ( ref $setting->value eq 'HASH' and keys %{$setting->value} == 1 and exists $setting->value->{value} ) {
        return $setting->value->{value};
    }

    return $setting->value;
}

sub get_settings {
    my ( $self ) = @_;

    my $return = {};

    foreach my $setting ( $self->search_related( 'person_settings', {} )->all ) {
        $return->{${\($setting->name)}} = $self->_get_setting_value($setting);
    }

    return $return;
}

sub create_auth_token {
    my ( $self ) = @_;

    my $token = Data::GUID->guid_string;

    $self->create_related( 'auth_tokens', {
        token => $token,
    });

    return $token;
}

1;
