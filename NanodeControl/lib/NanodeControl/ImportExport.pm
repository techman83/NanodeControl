package NanodeControl::ImportExport;
use strict;
use Dancer qw(:syntax);
use feature qw(switch);
use NanodeControl::DBsqlite;
use Text::CSV::Slurp;
use IO::File;
use File::Path qw(remove_tree);
use File::Copy qw(move);
use File::MimeInfo::Magic;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use base 'Exporter';

our @EXPORT = qw(nanode_export nanode_import import_check);
our @types = qw(stations schedules scheduled_stations settings categories);
our $valid_types = qw{^(stations|schedules|scheduled_stations|settings|categories)$};
our %exportsubs = (stations => \&export_stations, 
                schedules => \&export_schedules,
                scheduled_stations => \&export_scheduledstations,
                settings => \&export_settings,
                categories => \&export_categories );
our %importsubs = (stations => \&import_stations, 
                schedules => \&import_schedules,
                scheduled_stations => \&import_scheduledstations,
                settings => \&import_settings,
                categories => \&import_categories );

sub nanode_export {
  my ($export,$dbpath) = @_;
  debug("Begin export: $export");
  if ($export =~ /^all$/i) {
    my $zip = Archive::Zip->new();
    foreach my $type (@types) {
      info("Exporting $type");
      my @data;
      unless($dbpath) {
        @data = $exportsubs{"$type"}->();
      } else {
        @data = $exportsubs{"$type"}->($dbpath);
      }
      my $csv = Text::CSV::Slurp->create( input => \@data);
      my $string_member = $zip->addString( "$csv", "$type.csv" );
      $string_member->desiredCompressionMethod( COMPRESSION_DEFLATED );
    }
    debug($zip->members());
    my $file = '/tmp/NanodeExport.zip';
    my $fh = IO::File->new( "$file", 'w' );
    my $retval = $zip->writeToFileHandle( $fh );
    if ( $retval == AZ_OK ) {
      my $result->{result} = 'zip';
      $result->{data} = $file;
      return $result;
    } else {
      my $result->{result} = 'failure';
      $result->{data} = $retval;
    }
  } elsif ( $export =~ /$valid_types/i ) {
    info("Exporting $export");
    my @data = $exportsubs{"$export"}->();
    debug(@data);
    my $csv = Text::CSV::Slurp->create( input => \@data);
    my $result->{result} = 'csv';
    $result->{data} = $csv;
    debug($result);
    return $result;    
  } else {
    my $result->{result} = 'failure';
    $result->{data} = $export;
    return $result;
  }
}

sub nanode_import {
  my ($import,$dbpath) = @_;
  my $dest = '/tmp/nanodezip';
  my @files;

  debug("Begin export: $import->{type}, $import->{temp}, $import->{filename}");
  
  # Ensure Temp location exists, empty it if it does.
  unless (-e $dest) {
      mkdir $dest;
  } else {
    remove_tree( $dest, {keep_root => 1} );
  }
    
  if ($import->{type} eq 'application/zip') {
       
    # Extract contents of the zip
    my $zip = Archive::Zip->new($import->{temp});
    foreach my $member ($zip->members)
    {
        next if $member->isDirectory;
        (my $extractName = $member->fileName) =~ s{.*/}{};
        $member->extractToFileNamed("$dest/$extractName");
    }
    @files = glob "$dest/*";
  } elsif ($import->{type} eq 'text/csv') {
      move("$import->{temp}","$dest/$import->{filename}");
      push (@files, "$dest/$import->{filename}");
  } else {
    my $result->{result} = 'invalid_type';
    $result->{filename} = $import->{filename};
    return $result;
  }
  debug(@files);

  foreach my $file (@files) {
    my $mime = mimetype("$file");
    debug($mime);
    unless ($mime eq 'text/csv') {
      my $result->{result} = 'invalid_type';
      $result->{filename} = $file;
      return $result;
    }
    my $data = Text::CSV::Slurp->load(file => $file);
    my $result;
    given ($file) {
      when (/scheduled_stations/) { $result = $importsubs{"scheduled_stations"}->($data,$dbpath); }
      when (/stations/)           { $result = $importsubs{"stations"}->($data,$dbpath); }
      when (/schedules/)          { $result = $importsubs{"schedules"}->($data,$dbpath); }
      when (/settings/)           { $result = $importsubs{"settings"}->($data,$dbpath); }
      when (/categories/)         { $result = $importsubs{"categories"}->($data,$dbpath); }
      default {
        $result->{result} = 'invalid_filename';
        $result->{filename} = $file;
        return $result;
      }
    }
    unless ($result->{result} eq 'success') {
      return $result;
    }
  }
  my $result->{result} = 'success';
  return $result;
}

1
