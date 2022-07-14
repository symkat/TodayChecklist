use utf8;
package TodayChecklist::DB::Result::AuthPassword;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodayChecklist::DB::Result::AuthPassword

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

=head1 TABLE: C<auth_password>

=cut

__PACKAGE__->table("auth_password");

=head1 ACCESSORS

=head2 person_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 salt

  data_type: 'text'
  is_nullable: 0

=head2 updated_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "person_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "password",
  { data_type => "text", is_nullable => 0 },
  "salt",
  { data_type => "text", is_nullable => 0 },
  "updated_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<auth_password_person_id_key>

=over 4

=item * L</person_id>

=back

=cut

__PACKAGE__->add_unique_constraint("auth_password_person_id_key", ["person_id"]);

=head1 RELATIONS

=head2 person

Type: belongs_to

Related object: L<TodayChecklist::DB::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "TodayChecklist::DB::Result::Person",
  { id => "person_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-14 16:11:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LbtWCOOc/a49JCxTOE4WNA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
