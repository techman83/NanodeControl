package NanodeControl::DBAbstract;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;
use base 'Exporter';

our $db = config->{plugins}{Mongo}{db_name};
our @EXPORT = qw(upsert get_collection);

sub upsert {
  my ($collection, $data, $id) = @_;
  my $oid;

  if ($id) {
    $oid = MongoDB::OID->new($id);
  } else {
    $oid = MongoDB::OID->new();
  }
  
  debug($oid);
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

sub get_collection {
  my ($collection) = @_;
  my $cursor = mongo->get_database($db)->get_collection( "$collection" )->find();
  my $data;
  @{$data} = $cursor->all;
  debug(@{$data});
  return $data;
}

true;
