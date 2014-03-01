package NanodeControl::Websocket;
use Dancer ':syntax';
use Dancer::Plugin::WebSocket;
use base 'Exporter';

our @EXPORT = qw(socket_insert socket_update socket_remove socket_notify);

sub socket_insert {
  my ($data) = @_;
  # Send data to clients
  my $result->{type} = 'insert';
  $result->{content} = $data;
  $result = to_json($result,{allow_blessed=>1,convert_blessed=>1});
  debug($result);
  ws_send $result;
  debug("Message Sent");
  return;
}

sub socket_update {
  my ($data) = @_;
  # Send data to clients
  my $result->{type} = 'update';
  $result->{content} = $data;
  $result = to_json($result,{allow_blessed=>1,convert_blessed=>1});
  debug($result);
  ws_send $result;
  debug("Message Sent");
  return;
}

sub socket_remove {
  my ($data) = @_;
  # Send data to clients
  my $result->{type} = 'remove';
  $result->{content} = $data;
  $result = to_json($result,{allow_blessed=>1,convert_blessed=>1});
  debug($result);
  ws_send $result;
  debug("Message Sent");
  return;
}

sub socket_notify {
  my ($data) = @_;
  # Send data to clients
  my $result->{type} = 'notify';
  $result->{content} = $data;
  $result = to_json($result,{allow_blessed=>1,convert_blessed=>1});
  debug($result);
  ws_send $result;
  debug("Message Sent");
  return;
}

true;
