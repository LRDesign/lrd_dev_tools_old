require 'spec_helper'

describe "/<%= table_name %>/edit" do
  include <%= controller_class_name %>Helper
  
  before(:each) do
    assigns[:<%= file_name %>] = @<%= file_name %> = Factory(:<%= singular_name %>)
  end
  
  it "should succeed" do
    render "/<%= table_name %>/edit"
    response.should be_success
  end

  it "should render edit form" do
    render "/<%= table_name %>/edit"
    
    response.should have_tag("form[action=#{<%= file_name %>_path(@<%= file_name %>)}][method=post]") do
<% for attribute in attributes -%><% unless attribute.name =~ /_id/ || [:datetime, :timestamp, :time, :date].index(attribute.type) -%>
      with_tag('<%= attribute.input_type -%>#<%= file_name %>_<%= attribute.name %>[name=?]', "<%= file_name %>[<%= attribute.name %>]")
<% end -%><% end -%>
    end
  end
end


