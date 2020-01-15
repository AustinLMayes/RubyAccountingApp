require 'droplet_kit'
raise "DigitalOcean API token undefined" if $stratus['do-token'].blank?
$DO_CLIENT = DropletKit::Client.new(access_token: $stratus['do-token'])
