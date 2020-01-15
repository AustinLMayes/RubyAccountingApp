yaml = YAML.load(File.open(Rails.root.join('config/stratus.yml')))

unless yaml['default']
  raise('No default path in stratus.yml')
end

$stratus = yaml['default']
$stratus = $stratus.deep_merge(yaml[Rails.env]) if yaml[Rails.env]
