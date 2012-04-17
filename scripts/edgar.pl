use Edgar;
use YAML;

$cfg = YAML::LoadFile('../conf/edgar.yaml');

$edgar = Edgar->new();
$edgar->config($cfg);
$edgar->run();
$edgar->condvar->recv;