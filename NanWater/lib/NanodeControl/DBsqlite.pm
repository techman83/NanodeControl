package NanodeControl::DBsqlite;
use strict;
use Dancer ':syntax';
use DBD::SQLite;
use base 'Exporter';
my $appdir = config->{appdir};

our @EXPORT    = qw(add_schedule get_schedule get_schedule_state get_schedules get_scheduled_stations enable_schedule disable_schedule get_station get_stations get_categories get_category get_types add_station remove_stations add_category remove_categories);

# DB connection
sub connect_db {
  my $dbh = DBI->connect(
      "dbi:SQLite:dbname=$appdir/db/nanode_control.sqlite",undef,undef,
      { RaiseError => 1, AutoCommit => 1 }
  ); # Probably better to set the dbname in the settings. Will figure out how to pull that in.
  return $dbh;
}

### Categories ###
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

# Returns a single category
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

# Add a category
sub add_category {
  my ($name,$url,$type,$category) = @_;
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      INSERT INTO categories
      (name)
      VALUES (?)
  });
  
  $sth->execute($name);
  return;
};

# Remove categories 
sub remove_categories {
  my (@categories) = @_;
  my $dbh = connect_db();
  foreach my $category (@categories) {
    if (get_stations($category)) { return $category; }
  }
  foreach my $category (@categories) {
    my $sth = $dbh->prepare(q{
        UPDATE categories 
        SET deleted = 1
        WHERE id = ?
    });
    $sth->execute($category);
  }
  return "success";
};

### Types ###
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

### Stations ###
# Returns stations in an array - Category ID expected for the where.
sub get_stations {
  my ($category) = @_;
  my $dbh = connect_db();
  my $sth = ""; 
  unless ($category eq 'All') {
    $sth = $dbh->prepare(q{
        SELECT s.id, s.name, s.category, s.type, c.name, s.url, s.reversed
        FROM stations s 
        LEFT OUTER JOIN categories c 
        ON s.category = c.id
        WHERE s.category = ? AND s.deleted = 0
        ORDER BY s.id ASC, s.type ASC
    });
    $sth->execute($category);
  } else {
    $sth = $dbh->prepare(q{
        SELECT s.id, s.name, s.category, s.type, c.name, s.url, s.reversed
        FROM stations s 
        LEFT OUTER JOIN categories c 
        ON s.category = c.id
        WHERE s.deleted = 0
        ORDER BY s.category ASC, s.id ASC, s.type ASC
    });
    $sth->execute();
  }
  my @stations;
  while (my ($id,$name,$categoryid,$type,$category,$url,$reversed) = $sth->fetchrow_array) {
    debug("Station Details: $id, $name, $type, $category, $url, $reversed");
    push @stations, {
        id => $id,
        name => $name,
        category => $category,
        categoryid => $categoryid,
        type => $type,
        url => $url,
        reversed => $reversed,
    };
  }
  return @stations;
};

# Add a station
sub add_station {
  my ($name,$url,$type,$category,$reversed) = @_;
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      INSERT INTO stations
      (name,category,type,url,reversed)
      VALUES (?, ?, ?, ?, ?)
  });
  
  my $add = $sth->execute($name,$category,$type,$url,$reversed);
  return $add;
};

# Remove stations
sub remove_stations {
  my (@stations) = @_;
  my $dbh = connect_db();
  foreach my $station (@stations) {
    my $sth = $dbh->prepare(q{
        UPDATE stations
        SET deleted = 1
        WHERE id = ?
    });
    $sth->execute($station);
  }
  return;
};

# Returns a stations details 
sub get_station {
  my ($stationid) = @_;
  debug("Getting station details for station  $stationid");  
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT url, reversed
      FROM stations
      WHERE id = ? AND deleted = 0
  });
  $sth->execute($stationid);
  my $station;
  ($station->{url},$station->{reversed}) = $sth->fetchrow_array; 
  debug("Station details: ", $station);  
  return $station;
};

## Schedules
# Add a schedule
sub add_schedule {
  my ($schedule) = @_;
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      INSERT INTO schedules
      (name,starttime,dow)
      VALUES (?, ?, ?)
  });
  my $days = join(",", @{$schedule->{days}}); 
  my $add = $sth->execute($schedule->{name},$schedule->{starttime},$days);
  $sth = $dbh->prepare(q{
      SELECT id
      FROM schedules
      WHERE rowid = last_insert_rowid()
  });
  $sth->execute;
  my ($scheduleid) = $sth->fetchrow_array;

  foreach my $station (@{$schedule->{stations}}) {
    $sth = $dbh->prepare(q{
        INSERT INTO scheduled_stations
        (scheduleid,stationid,duration)
        VALUES (?, ?, ?)
    });
    $sth->execute($scheduleid,$station,$schedule->{duration});
  };
   
  debug("Result: $add - Schedule ID: $scheduleid");
  return $scheduleid;
}

sub get_schedules {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name, enabled
      FROM schedules
      WHERE deleted = 0
      ORDER BY id ASC
  });
  
  $sth->execute();
  my @schedules;
  while (my ($id,$name,$enabled) = $sth->fetchrow_array) {
      push @schedules, {
          id => $id,
          name => $name,
          enabled => $enabled
      };
  }
  debug("Schedules: ", @schedules);
  return @schedules;
}

# Returns a stations details 
sub get_schedule {
  my ($scheduleid) = @_;
  debug("Getting schedule details for schedule $scheduleid");  
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name, dow, starttime
      FROM schedules
      WHERE deleted = 0 AND id = ?
      ORDER BY id ASC
  });
  $sth->execute($scheduleid);
  my $schedule;
  ($schedule->{id},$schedule->{name},$schedule->{days},$schedule->{starttime}) = $sth->fetchrow_array; 
  ($schedule->{hours}, $schedule->{minutes}) = split(/:/, $schedule->{starttime});
  debug("Schedule details: ", $schedule);
  return $schedule;
};

sub get_schedule_state {
  my ($scheduleid) = @_;
  debug("Getting state for schedule $scheduleid");  
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT enabled
      FROM schedules
      WHERE deleted = 0 AND id = ?
      ORDER BY id ASC
  });
  $sth->execute($scheduleid);
  my ($state) = $sth->fetchrow_array;
  debug("Schedule State: ", $state);
  return $state;
}

sub disable_schedule {
  my ($scheduleid) = @_;
  debug("Disable schedule $scheduleid");  
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      UPDATE schedules
      SET enabled = 0
      WHERE id = ?
  });
  $sth->execute($scheduleid);
  return;
}

sub enable_schedule {
  my ($scheduleid) = @_;
  debug("Enable schedule $scheduleid");  
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      UPDATE schedules
      SET enabled = 1
      WHERE id = ?
  });
  $sth->execute($scheduleid);
  return;
}

sub get_scheduled_stations {
  my ($scheduleid) = @_;
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT stationid, duration, runorder
      FROM scheduled_stations
      WHERE deleted = 0 and scheduleid = ?
      ORDER BY runorder DESC
  });
  
  $sth->execute($scheduleid);
  my @stations;
  while (my ($id,$duration,$runorder) = $sth->fetchrow_array) {
      push @stations, {
          id => $id,
          duration => $duration,
          runorder => $runorder
      };
  }
  debug("Schedule Stations: ", @stations);
  return @stations;
}

1
