package NanodeControl::DBsqlite;
use strict;
use DBD::SQLite;
use Data::Dumper;
#use Moose;

use base 'Exporter';
#has 'database' => (is => 'rw', isa => 'Str');

our @EXPORT    = qw(get_stations get_categories get_category get_types add_station remove_station add_category remove_category);

sub BUILD {
  my $self = shift;   
  return;
}

# DB connection
sub connect_db {
  my $dbh = DBI->connect(
      "dbi:SQLite:dbname=db/nanode_control.sqlite",undef,undef,
      { RaiseError => 1, AutoCommit => 1 }
  ); # Probably better to set the dbname in the settings. Will figure out how to pull that in.
  return $dbh;
}

# Returns categories in an array
sub get_categories {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name
      FROM categories
      WHERE deleted = 0
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

sub get_category {
  my ($categoryid) = @_;
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT name
      FROM categories
      WHERE id = ? AND deleted = 0
  });
  
  $sth->execute($categoryid);
  my $name = $sth->fetchrow_array; 
  return $name;
};

# Returns types in an array
sub get_types {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name
      FROM type
      WHERE deleted = 0
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

# Returns stations in an array - Category ID expected for the where.
sub get_stations {
  my ($category) = @_;
  my $dbh = connect_db();
  my $sth = ""; 
  unless ($category eq 'All') {
    $sth = $dbh->prepare(q{
        SELECT s.id, s.name, s.category, s.type, c.name
        FROM stations s 
        LEFT OUTER JOIN categories c 
        ON s.category = c.id
        WHERE s.category = ? AND s.deleted = 0
        ORDER BY s.id ASC, s.type ASC
    });
    $sth->execute($category);
  } else {
    $sth = $dbh->prepare(q{
        SELECT s.id, s.name, s.category, s.type, c.name
        FROM stations s 
        LEFT OUTER JOIN categories c 
        ON s.category = c.id
        WHERE s.deleted = 0
        ORDER BY s.id ASC, s.type ASC
    });
    $sth->execute();
  }
  my @stations;
  while (my ($id,$name,$categoryid,$type,$category) = $sth->fetchrow_array) {
      push @stations, {
          id => $id,
          name => $name,
          category => $category,
          categoryid => $categoryid,
          type => $type
      };
  }
  return @stations;
};

sub add_station {
  my ($name,$url,$type,$category) = @_;
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      INSERT INTO stations
      (name,category,type,url)
      VALUES (?, ?, ?, ?)
  });
  
  my $add = $sth->execute($name,$category,$type,$url);
  return $add;
};

1
