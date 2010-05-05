require 'spec_helper'

describe "/<%= table_name %>/new" do
  include <%= controller_class_name %>Helper
  
  before(:each) do
    assigns[:<%= file_name %>] = Factory.build(:<%= singular_name %>)
  end
  
  it "should succeed" do
    render "/<%= table_name %>/new"
    response.should be_success
  end
  

  it "should render new form" do
    render "/<%= table_name %>/new"
    
    response.should have_tag("form[action=?][method=post]", <%= table_name %>_path) do
<% for attribute in attributes -%><% unless attribute.name =~ /_id/ || [:datetime, :timestamp, :time, :date].index(attribute.type) -%>
      with_tag("<%= attribute.input_type -%>#<%= file_name %>_<%= attribute.name %>[name=?]", "<%= file_name %>[<%= attribute.name %>]")
<% end -%><% end -%>
    end
  end
end


