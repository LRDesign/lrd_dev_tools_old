require 'spec_helper'

describe "/<%= table_name %>/show" do
  include <%= controller_class_name %>Helper
  
  before(:each) do
    assigns[:<%= file_name %>] = @<%= file_name %> = Factory(:<%= singular_name %>)
  end

  it "should succeed" do
    render "/<%= table_name %>/show"
    response.should be_success
  end
end

