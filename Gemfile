source 'https://rubygems.org'

group :development do
  gem "bundler",       "~> 1.8"
  gem "rake",          "~> 10.0"
  gem "debugger"
end

group :test do
  gem "database_cleaner",       "~> 1.3.0"
  gem "actionpack"                # used by combustion,
  gem "rspec-rails",   "~> 3.2"
  gem "combustion",    "~> 0.5.3"
  gem "serial-spec",              github: "blakechambers/serial-spec"
  gem "machinist-mongoid",        github: "Nakort/machinist-mongoid"
end

gemspec
