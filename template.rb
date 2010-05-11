puts
puts "A few setup configuration questions:"
user = ask "What should we call the user model? [default: User]"
user = "User" if user.blank?
user_session = ask "What should we call the user session model? [default: UserSession]"
user_session = "UserSession" if user.blank?
puts
puts "Thanks.  No more interaction required until we're done."
puts; puts

def file_contents(name)
  File::read(File::join(File::dirname(__FILE__), "files", *name))
end

git :init
gem 'factory_girl'
gem 'haml'
gem 'authlogic'
gem 'newrelic_rpm', :env => "development"
gem 'hoptoad_notifier'
gem 'will_paginate'  
gem 'rspec', :env => "test"
gem 'rspec-rails', :env => "test"
rake 'gems:install', :sudo => true 

#Until this goes to live in a developer's gem
rakefile "full_recycle.rake" do
  file_contents("full_recycle.rake")
end

file ".gitignore" do
  file_contents "gitignore"
end

initializer "whitelist_assignment.rb", "ActiveRecord::Base.attr_accessible(nil)" #So mass assignment is explicit

plugin "logical_authz", :git => "git@github.com:LRDesign/LogicalAuthz.git", :submodule => :yes
plugin "lrd_view_tools", :git => "git://github.com/LRDesign/lrd_view_tools.git" #not a submodule
#plugin :git => "git://github.com/LRDesign/logical_tabs.git", :submodule => 
#:yes
plugin "factory_haml_rspec_scaffold", :git => "git://github.com/morhekil/factory_haml_rspec_scaffold.git", :submodule => :yes
plugin "rails_xss", :git => "git://github.com/dhh/rails_xss.git", :submodule => :yes

generate :logical_authz_models, "-u", user
generate :session, user_session  
generate :rspec

lib "authenticated_system.rb" { file_contents "authenticated_system.rb" } 
file "spec/support/authlogic_test_helper.rb" { file_contents "authlogic_test_helper.rb" }

plugin "query_reviewer", :git => "git://github.com/dsboulder/query_reviewer.git", :submodule => :yes
plugin "human-attribute-with-labels", :git => "git://github.com/hgtesta/human-attribute-with-labels.git", :submodule => :yes

git :add => "."
git :commit => "-m 'Initial commit'"
git :branch => "edge"
