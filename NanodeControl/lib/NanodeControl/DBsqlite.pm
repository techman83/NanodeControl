package NanodeControl::DBsqlite;
use strict;
use Dancer ':syntax';
use DBD::SQLite;
use base 'Exporter';
my $appdir = config->{appdir};

unless ( defined $appdir ) {
   use FindBin qw($Bin);
   $appdir = "$Bin/..";
}

our @EXPORT    = qw(create_db
                    add_schedule
                    get_schedule
                    get_schedule_state
                    get_schedules
                    get_scheduled_stations
                    enable_schedule
                    disable_schedule
                    remove_schedule
                    get_station
                    get_stations
                    get_categories
                    get_category
                    get_types
                    add_station
                    remove_stations
                    add_category
                    remove_categories
                    export_categories
                    export_settings
                    export_schedules
                    export_scheduledstations
                    export_stations
                    import_categories
                    import_settings
                    import_schedules
                    import_scheduledstations
                    import_stations);

our %importsubs = (stations => \&import_stations, 
                schedules => \&import_schedules,
                scheduled_stations => \&import_scheduledstations,
                settings => \&import_settings,
                categories => \&import_categories );

# DB connection
sub connect_db {
  my $dbh = DBI->connect(
      "dbi:SQLite:dbname=$appdir/db/nanode_control.sqlite",undef,undef,
      { RaiseError => 1, AutoCommit => 1 }
  );
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
  my ($data) = @_;
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      INSERT INTO stations
      (name,category,type,url,reversed)
      VALUES (?, ?, ?, ?, ?)
  });
  
  my $add = $sth->execute(
        $data->{stationname},
        $data->{stationcategory},
        $data->{stationtype},
        $data->{stationurl},
        $data->{stationreverse});

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
      (name,starttime,dow,master)
      VALUES (?, ?, ?, ?)
  });
  my $days = join(",", @{$schedule->{days}}); 
  my $add = $sth->execute($schedule->{name},$schedule->{starttime},$days,$schedule->{master});
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
      SELECT id, name, dow, starttime, master
      FROM schedules
      WHERE deleted = 0 AND id = ?
      ORDER BY id ASC
  });
  $sth->execute($scheduleid);
  my $schedule;
  ($schedule->{id},$schedule->{name},$schedule->{days},$schedule->{starttime},$schedule->{master}) = $sth->fetchrow_array; 
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

sub remove_schedule {
  my ($scheduleid) = @_;
  debug("Removing schedule $scheduleid");  
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      UPDATE schedules
      SET deleted = 1 
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

### Export ###
# Returns categories in an array
sub export_categories {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name, deleted
      FROM categories
      ORDER BY id ASC
  });
  
  $sth->execute();
  my @categories;
  while (my ($id,$name,$deleted) = $sth->fetchrow_array) {
      push @categories, {
          id => $id,
          name => $name,
          deleted => $deleted
      };
  }
  return @categories;
};

# Returns settings in an array
sub export_settings {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name, value 
      FROM settings
      ORDER BY id ASC
  });
  
  $sth->execute();
  my @settings;
  while (my ($id,$name,$value) = $sth->fetchrow_array) {
      push @settings, {
          id => $id,
          name => $name,
          value => $value
      };
  }
  return @settings;
};

# Returns schedules in an array
sub export_schedules {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name, starttime, dow, raincheck, enabled, master, deleted 
      FROM schedules
      ORDER BY id ASC
  });
  
  $sth->execute();
  my @schedules;
  while (my ($id,$name,$starttime,$dow,$raincheck,$enabled,$master,$deleted) = $sth->fetchrow_array) {
      push @schedules, {
          id => $id,
          name => $name,
          starttime => $starttime,
          dow => $dow,
          raincheck => $raincheck,
          enabled => $enabled,
          master => $master,
          deleted => $deleted
      };
  }
  return @schedules;
};

# Returns scheduled stations in an array
sub export_scheduledstations {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, scheduleid, stationid, duration, runorder, deleted
      FROM scheduled_stations
      ORDER BY id ASC
  });
  
  $sth->execute();
  my @scheduledstations;
  while (my ($id,$scheduleid,$stationid,$duration,$runorder,$deleted) = $sth->fetchrow_array) {
      push @scheduledstations, {
          id => $id,
          scheduleid => $scheduleid,
          stationid => $stationid,
          duration => $duration,
          runorder => $runorder,
          deleted => $deleted
      };
  }
  return @scheduledstations;
};

# Returns stations in an array
sub export_stations {
  my $dbh = connect_db();
  my $sth = $dbh->prepare(q{
      SELECT id, name, category, type, url, reversed, deleted
      FROM stations 
      ORDER BY id ASC
  });
  
  $sth->execute();
  my @stations;
  while (my ($id,$name,$category,$type,$url,$reversed,$deleted) = $sth->fetchrow_array) {
      push @stations, {
          id => $id,
          name => $name,
          category => $category,
          type => $type,
          url => $url,
          reversed => $reversed,
          deleted => $deleted
      };
  }
  return @stations;
};

### Import ###
sub import_categories {
  my ($data) = @_;
  my @required = qw(id name);
  my @import = qw(name);
  my @optional = qw(deleted);
  
  debug($data);
  my $result = import_check($data,\@required);

  if ($result->{result} eq 'success') {
    debug("Check passed, importing categories");
    debug($data);
    debug("Creating Table: categories");
    # Create DB
    my $dbh = connect_db();
    create_categories($dbh);
    # Import Data
    $result = import_table($data,\@import,\@optional,"categories");
  }

  return $result;
}

sub import_settings {
  my ($data) = @_;
  my @required = qw(id name value);
  my @import = qw(name value);
  my @optional;
  
  debug($data);
  my $result = import_check($data,\@required);

  if ($result->{result} eq 'success') {
    debug("Check passed, importing settings");
    debug($data);
    debug("Creating Table: settings");
    # Create DB
    my $dbh = connect_db();
    create_settings($dbh);
    # Import Data
    $result = import_table($data,\@import,\@optional,"settings");
  }

  return $result;
}

sub import_schedules {
  my ($data) = @_;
  my @required = qw(dow id name starttime);
  my @import = qw(dow name starttime);
  my @optional = qw(dow enabled master raincheck);
  
  debug($data);
  my $result = import_check($data,\@required);

  if ($result->{result} eq 'success') {
    debug("Check passed, importing schedules");
    debug($data);
    debug("Creating Table: schedules");
    # Create DB
    my $dbh = connect_db();
    create_schedules($dbh);
    # Import Data
    $result = import_table($data,\@import,\@optional,"schedules");
  }

  return $result;
}

sub import_scheduledstations {
  my ($data) = @_;
  my @required = qw(id scheduleid stationid);
  my @import = qw(scheduleid stationid);
  my @optional = qw(deleted duration runorder);
  
  debug($data);
  my $result = import_check($data,\@required);

  if ($result->{result} eq 'success') {
    debug("Check passed, importing scheduled_stations");
    debug($data);
    debug("Creating Table: scheduled_stations");
    # Create DB
    my $dbh = connect_db();
    create_scheduledstations($dbh);
    # Import Data
    $result = import_table($data,\@import,\@optional,"scheduled_stations");
  }

  return $result;
}

sub import_stations {
  my ($data) = @_;
  my @required = qw(category id name type url);
  my @import = qw(category name type url);
  my @optional = qw(deleted reversed);
  
  debug($data);
  my $result = import_check($data,\@required);

  if ($result->{result} eq 'success') {
    debug("Check passed, importing stations");
    debug($data);
    debug("Creating Table: stations");
    # Create DB
    my $dbh = connect_db();
    create_stations($dbh);
    # Import Data
    $result = import_table($data,\@import,\@optional,"stations");
  }

  return $result;
}

sub import_table {
  my ($data,$required,$optional,$table) = @_;
  my @required = @{$required};
  my @optional = @{$optional};
  debug($data);

  my $dbh = connect_db();
  foreach my $row (@{$data}) {
    debug($row);
    # Insert ID
    my $sql = sprintf "INSERT INTO  %s (id) VALUES (%s)", 
       $dbh->quote_identifier($table), $dbh->quote($row->{id});
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    # Required fields
    foreach my $rfield (@required) {
        my $sql = sprintf "UPDATE %s SET %s = %s WHERE id = %s", 
           $dbh->quote_identifier($table),$dbh->quote_identifier($rfield), $dbh->quote($row->{$rfield}), $dbh->quote($row->{id});
        debug($sql);
        $sth = $dbh->prepare($sql);
        $sth->execute();
    }

    # Optional fields
    unless(defined $optional[0]) {
      foreach my $field (@optional) {
        debug("Checking: $field");
        if (defined $row->{$field}) {
          debug("$field exists in data, updating record $row->{id}");
          my $sql = sprintf "UPDATE %s SET %s = %s WHERE id = %s", 
              $dbh->quote_identifier($table),$dbh->quote_identifier($field), $dbh->quote($row->{$field}), $dbh->quote($row->{id});
          debug($sql);
          $sth = $dbh->prepare($sql);
          $sth->execute();
        }
      }
    } 
  }

  debug("Imported: $table");    
  my $result->{result} = 'success';
  return $result;
}

sub import_check {
  my ($data,$fields) = @_;
  debug("Checking Fields: "); 
  debug($data);
  my $count = 0;
  my $result;
  my @fields = @{$fields};

  foreach (@{$data}) {
    foreach my $field (@fields) {
      debug("Checking required: $field");
      unless(defined $data->[$count]{"$field"}) {
        my $result->{result} = 'missing_field';
        $result->{field} = $field;
        return $result;
      }
    }
    $count++;
  }
  
  unless(defined $result->{result}) { # If I get this far, it should never be defined. But shouldn't clobber it if it is for some reason
    debug("Great success!");
    $result->{result} = 'success'; 
  }

  return $result;
}

### Create DB ###
sub create_db {
  my $dbh = connect_db();
  my $sth;
  create_categories($dbh);
  $sth = $dbh->prepare(q{
      INSERT INTO "categories" VALUES(10001,'Example Category',0);
  });
  $sth->execute();

  create_scheduledstations($dbh);
  $sth = $dbh->prepare(q{
      INSERT INTO "scheduled_stations" VALUES(10001,10001,10001,500,1,0);
  });
  $sth->execute();

  create_schedules($dbh);
  $sth = $dbh->prepare(q{
      INSERT INTO "schedules" VALUES(10001,'Example Schedule','20:00:00','1,3,5',0,1,0,0);
  });
  $sth->execute();

  create_stations($dbh);
  $sth = $dbh->prepare(q{
      INSERT INTO "stations" VALUES(10001,'Example Station',10001,10001,'http://stationip_or_url/1',0,0);
  });
  $sth->execute();

  create_settings($dbh);
  $sth = $dbh->prepare(q{
      INSERT INTO "settings" VALUES(10001,'Example','Setting',0);
  });
  $sth->execute();

  create_type($dbh);
  $sth = $dbh->prepare(q{
      INSERT INTO "type" VALUES(?,?,?);
  });

  $sth->execute(10001,'On/Off',0);
  $sth->execute(10002,'Slider',0);

  return;
}


sub create_categories {
  my ($dbh) = @_;
  # Create Categories
  my $sth = $dbh->prepare(q{
      DROP TABLE IF EXISTS "categories"
  });
  $sth->execute();
  $sth = $dbh->prepare(q{
      CREATE TABLE "categories" (
      "id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE ,
      "name" VARCHAR,
      "deleted" INTEGER DEFAULT (0) )
  });
  $sth->execute();
  return;
}
  
sub create_scheduledstations {
  my ($dbh) = @_;
  # Create Scheduled Stations
  my $sth = $dbh->prepare(q{
      DROP TABLE IF EXISTS "scheduled_stations";
  });
  $sth->execute();
  $sth = $dbh->prepare(q{
      CREATE TABLE "scheduled_stations" (
      "id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE ,
      "scheduleid" INTEGER,
      "stationid" INTEGER,
      "duration" INTEGER,
      "runorder" INTEGER INTEGER DEFAULT (0),
      "deleted" INTEGER DEFAULT (0) );
  });
  $sth->execute();
  return;
}
 
sub create_schedules {
  my ($dbh) = @_;
  # Create Schedules
  my $sth = $dbh->prepare(q{
      DROP TABLE IF EXISTS "schedules";
  });
  $sth->execute();
  $sth = $dbh->prepare(q{
      CREATE TABLE "schedules" (
      "id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE,
      "name" VARCHAR,
      "starttime" DATETIME,
      "dow" VARCHAR,
      "raincheck" INTEGER DEFAULT (0) ,
      "enabled" INTEGER DEFAULT (1) ,
      "master" INTEGER DEFAULT (0) , 
      "deleted" INTEGER DEFAULT 0);
  });
  $sth->execute();
  return;
}
  
sub create_settings {
  my ($dbh) = @_;
  # Create settings
  my $sth = $dbh->prepare(q{
      DROP TABLE IF EXISTS "settings";
  });
  $sth->execute();
  $sth = $dbh->prepare(q{
      CREATE TABLE "settings" (
      "id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 
      "name" VARCHAR, 
      "value" VARCHAR,
      "deleted" INTEGER DEFAULT (0) )
  });
  $sth->execute();
  return;
}
  
sub create_stations {
  my ($dbh) = @_;
  # Create stations
  my $sth = $dbh->prepare(q{
      DROP TABLE IF EXISTS "stations";
  });
  $sth->execute();
  $sth = $dbh->prepare(q{
      CREATE TABLE "stations" (
      "id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE ,
      "name" VARCHAR,
      "category" INTEGER,
      "type" INTEGER,
      "url" VARCHAR,
      "reversed" INTEGER DEFAULT (0) , 
      "deleted" INTEGER DEFAULT 0);
  });
  $sth->execute();
  return;
}
  
sub create_type {
  my ($dbh) = @_;
  # Create type
  my $sth = $dbh->prepare(q{
      DROP TABLE IF EXISTS "type";
  });
  $sth->execute();
  $sth = $dbh->prepare(q{
      CREATE TABLE "type" (
      "id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE ,
      "name" VARCHAR,
      "deleted" INTEGER DEFAULT (0) );
  });
  $sth->execute();
  return;
}

1
