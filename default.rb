# Rails with rpsec 3, capybara, guard, dotenv, bootstrap, puma, foreman

######### Initial Skeleton

run "bundle install"

git :init
git add: "."
git commit: %Q{ -m "Initial skeleton" }

######### Database Config

# Remove production from database config
run "sed -i '' '/^production:/,$d' config/database.yml"

rake "db:create:all"
rake "db:migrate"

git add: "."
git commit: %Q{ -m "Database configuration" }

######### Set ruby version

create_file ".ruby-version" do
  "#{RUBY_VERSION}\n"
end
inject_into_file "Gemfile", after: /^source.*\n/ do
 %(ruby File.read(File.expand_path("../.ruby-version", __FILE__)).chomp)
end

git add: "."
git commit: %Q{ -m "Set ruby version to #{RUBY_VERSION}" }

######### Utilities

# simple form
gem 'simple_form'
# unicorn
gem 'unicorn'

# pundit - optional
if yes? 'Do you wish to add pundit gem? (y/n)'
  gem 'pundit'
end

# rolify - optional
if yes? 'Do you wish to add rolify gem? (y/n)'
  gem 'rolify'
  generate "rolify Role User"
end

# devise - optional
if yes? 'Do you wish to add devise gem? (y/n)'
  gem 'devise'
  generate "devise:install"
  name = ask('What should be the model for Devise?')
  generate "devise model #{name}"
end


######### Testing

gem_group :development, :test do
  gem "spring-commands-rspec"
  gem "rspec-rails"
end

run "bundle install"
generate "rspec:install"
run "spring binstub --all"

# filter out =begin and =end in rspec helper to get the defaults
gsub_file "spec/spec_helper.rb", /^=(begin|end)$/, ""

git add: "."
git commit: %Q{ -m "Add rspec" }

######### Bootstrap

gem "bootstrap-sass"
gem "autoprefixer-rails"

run "bundle install"

FileUtils.mv "app/assets/stylesheets/application.css", "app/assets/stylesheets/application.css.scss"
inject_into_file "app/assets/stylesheets/application.css.scss", after: " */\n" do <<-CSS
@import "bootstrap-sprockets";
@import "bootstrap";
CSS
end
insert_into_file "app/assets/javascripts/application.js", after: /.*require jquery\n/ do
  "//= require bootstrap-sprockets\n"
end
# Use cp rather than copy_file here otherwise we get asked if we really want to
run "cp -r #{File.expand_path('../bootstrap_templates/*', __FILE__)} ."

git add: "."
git commit: %Q{ -m "Add bootstrap" }
