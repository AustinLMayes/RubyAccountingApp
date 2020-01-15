# Eager load all monkey patches (everything in lib/ext)
$LOAD_PATH << File.join(Rails.root, 'lib/ext')

Dir[Rails.root + 'lib/ext/**/*.rb'].each do |file|
    require file
end
