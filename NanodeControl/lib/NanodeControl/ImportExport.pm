package NanodeControl::ImportExport;
use strict;
use Dancer qw(:syntax);
use NanodeControl::DBsqlite;
use Text::CSV::Slurp;
use IO::File;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use base 'Exporter';
my $appdir = config->{appdir};

our @EXPORT = qw(nanode_export nanode_import import_check);
our @types = @{config->{exporttypes}};
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
  my ($export) = @_;
  debug("Begin export: $export");
  if ($export =~ /^all$/i) {
    my $zip = Archive::Zip->new();
    foreach my $type (@types) {
      info("Exporting $type");
      my @data = $exportsubs{"$type"}->();
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
  my ($import) = @_;
  debug("Begin export: $import");

}

1
