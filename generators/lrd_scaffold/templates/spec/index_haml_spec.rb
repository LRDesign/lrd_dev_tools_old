require 'spec_helper'

describe "/<%= table_name %>/index" do
  include <%= controller_class_name %>Helper
  
  before(:each) do
    assigns[:<%= table_name %>] = [ Factory(:<%= singular_name %>), Factory(:<%= singular_name %>) ]
  end

  it "should succeed" do
    render "/<%= table_name %>/index"
    response.should be_success
  end
end

