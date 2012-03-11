watch( 'lib/(.*)\.rb' ) do |md| 
  if md[0] == "lib/soundwave.rb"
    system("bundle exec rake spec")
  elsif File.exists?(spec_path = "spec/#{md[1]}.rb")
    system "bundle exec rspec #{spec_path}"
  end
end

watch( 'spec/(spec_helper|.*\_spec).rb') do |md|
  system "bundle exec rspec #{md[0]}"
end