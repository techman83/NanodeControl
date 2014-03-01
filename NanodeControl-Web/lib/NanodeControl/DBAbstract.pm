package NanodeControl::DBAbstract;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;
use base 'Exporter';

our $db = config->{plugins}{Mongo}{db_name};
our @EXPORT = qw(upsert get_collection find_one find_key);

sub upsert {
  my ($collection, $data, $id) = @_;
  my $oid;

  if ($id) {
    $oid = MongoDB::OID->new($id);
  } else {
    $oid = MongoDB::OID->new();
    $data->{apikey} = generate_api_key($collection,$data->{type});
  }
  
  # Get collection
  $collection = mongo->get_database($db)->get_collection( "$collection" );
  
  # Insert data
  my $upsert = $collection->update({ _id => $oid }, { '$set' => $data }, { "upsert" => 1 });
  
  debug($upsert);
  # Get result
  $data = $collection->find_one({ _id => $oid });
  debug($data);
  return $data;
}

sub find_key {
  my ($collection, $key) = @_;

  # Get collection
  $collection = mongo->get_database($db)->get_collection( "$collection" );
  
  # Get result
  my $data = $collection->find_one({ apikey => $key });
  debug($data);
  return $data;
}

sub find_one {
  my ($collection, $id) = @_;

  my $oid = MongoDB::OID->new($id);

  # Get collection
  $collection = mongo->get_database($db)->get_collection( "$collection" );
  
  # Get result
  my $data = $collection->find_one({ _id => $oid });
  debug($data);
  return $data;
}

sub get_collection {
  my ($collection) = @_;
  my $cursor = mongo->get_database($db)->get_collection( "$collection" )->find({"deleted" => {'$ne' => "true"}});
  my $data;
  @{$data} = $cursor->all;
  debug(@{$data});
  return $data;
}

sub generate_api_key {
  my ($collection,$type) = @_;
  my $cursor = mongo->get_database($db)->get_collection( "$collection" )->find();
  my @count;
  @count = $cursor->all;
  my $count = $#count;
  $count++;
  my $key = "$type-$count";
  debug($key);
  return $key;
}

true;
