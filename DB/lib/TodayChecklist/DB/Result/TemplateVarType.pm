use utf8;
package TodayChecklist::DB::Result::TemplateVarType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodayChecklist::DB::Result::TemplateVarType

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

=head1 TABLE: C<template_var_type>

=cut

__PACKAGE__->table("template_var_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'template_var_type_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "template_var_type_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 template_vars

Type: has_many

Related object: L<TodayChecklist::DB::Result::TemplateVar>

=cut

__PACKAGE__->has_many(
  "template_vars",
  "TodayChecklist::DB::Result::TemplateVar",
  { "foreign.template_var_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-14 21:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pQHZrg1wtqRqPNlouVIfTA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
