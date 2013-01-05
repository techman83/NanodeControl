package NanodeControl::DBsqlite;
use strict;
use DBD::SQLite;
#use Moose;

use base 'Exporter';
#has 'database' => (is => 'rw', isa => 'Str');

our @EXPORT    = qw(get_stations get_categories get_types add_station remove_station add_category remove_category);

sub BUILD {
  my $self = shift;   
  return;
}

sub connect_db {
  my $dbh = DBI->connect(
      "dbi:SQLite:dbname=db/nanode_control.sqlite",undef,undef,
      { RaiseError => 1, AutoCommit => 1 }
  ); # Probably better to set the dbname in the settings. Will figure out how to pull that in.
  return $dbh;
}

sub get_categories {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name
      FROM categories
      ORDER BY id ASC
  });
  
  $sth->execute();
  my @categories;
  while (my ($id,$name) = $sth->fetchrow_array) {
      push @categories, {
          id => $id,
          name => $name
      };
  }
  return @categories;
};

sub get_types {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name
      FROM type
      ORDER BY id ASC
  });
  
  $sth->execute();
  my @types;
  while (my ($id,$name) = $sth->fetchrow_array) {
      push @types, {
          id => $id,
          name => $name
      };
  }
  return @types;
};

1
