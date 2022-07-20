use utf8;
package TodayChecklist::DB::Result::Template;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodayChecklist::DB::Result::Template

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

=head1 TABLE: C<template>

=cut

__PACKAGE__->table("template");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'template_id_seq'

=head2 person_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 content

  data_type: 'text'
  is_nullable: 0

=head2 is_system

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
    sequence          => "template_id_seq",
  },
  "person_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "content",
  { data_type => "text", is_nullable => 0 },
  "is_system",
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

=head1 RELATIONS

=head2 documents

Type: has_many

Related object: L<TodayChecklist::DB::Result::Document>

=cut

__PACKAGE__->has_many(
  "documents",
  "TodayChecklist::DB::Result::Document",
  { "foreign.template_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 template_vars

Type: has_many

Related object: L<TodayChecklist::DB::Result::TemplateVar>

=cut

__PACKAGE__->has_many(
  "template_vars",
  "TodayChecklist::DB::Result::TemplateVar",
  { "foreign.template_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-20 02:39:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pdnBeDdsR5bn7hIuVp33qA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
