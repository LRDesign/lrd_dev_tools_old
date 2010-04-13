puts
puts "A few setup configuration questions:"
user = ask "What should we call the user model? [default: User]"
user = "User" if user.blank?
user_session = ask "What should we call the user session model? [default: UserSession]"
user_session = "UserSession" if user.blank?
puts
puts "Thanks.  No more interaction required until we're done."
puts; puts

git :init
gem 'factory_girl'
gem 'haml'
gem 'authlogic'
gem 'newrelic_rpm', :env => "development"
gem 'hoptoad_notifier'
gem 'will_paginate'
rake 'gems:install', :sudo => true 

#Until this goes to live in a developer's gem
rakefile "full_recycle.rake", <<EOR
namespace :db do
  #Change this to raise once full_recycle shouldn't work
  task :only_if_undeployed

  desc "Rebuild the database from scratch, useful when editing migrations"
  task :full_recycle => [
    :only_if_undeployed,
    "install",
    "test:prepare"
  ]

  desc "Build and seed the database for a new install"
  task :install => [
    :environment,
    "migrate:reset",
    "seed" 
    ]
end
EOR

file ".gitignore", <<EOGI
log/*
screenlog.*
*.log
tmp/**/*
tmp/*
.dotest/
.dotest/*.
tmp/profile*
.DS_Store
doc/plugins
doc/api
doc/app
doc/*.doc
doc/*.zip
db/schema.sql
db/schema.rb
db/*.sqlite3*
database.yml
uuid.state
nbproject*
index/*
identifier
secret
last_run
.project
.conductor/*
.conductor/**/*
.*.sw?
.#*
\#*
*~
vendor/**/doc/*
vendor/plugins/footnotes/*
rsa_key*
EOGI

initializer "whitelist_assignment.rb", "ActiveRecord::Base.attr_accessible(nil)" #So mass assignment is explicit

plugin "logical_authz", :git => "git@github.com:LRDesign/LogicalAuthz.git", :submodule => :yes
plugin "lrd_view_tools", :git => "git://github.com/LRDesign/lrd_view_tools.git" #not a submodule
#plugin :git => "git://github.com/LRDesign/logical_tabs.git", :submodule => 
#:yes
plugin "factory_haml_rspec_scaffold", :git => "git://github.com/morhekil/factory_haml_rspec_scaffold.git", :submodule => :yes
plugin "rails_xss", :git => "git://github.com/dhh/rails_xss.git", :submodule => :yes

generate :logical_authz_models, "-u", user
generate :session, user_session

lib "authenticated_system.rb", <<EOAS #This may be misplaced
module AuthenticatedSystem
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def logged_in?
    !(current_user.nil?)
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = #{user_session}.find
  end
end
EOAS

plugin "query_reviewer", :git => "git://github.com/dsboulder/query_reviewer.git", :submodule => :yes
plugin "human-attribute-with-labels", :git => "git://github.com/hgtesta/human-attribute-with-labels.git", :submodule => :yes

git :add => "."
git :commit => "-m 'Initial commit'"
git :branch => "edge"
