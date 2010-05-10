require 'spec_helper'

describe <%= controller_class_name %>Controller do

  before(:each) do
    @<%= file_name %> = Factory(:<%= singular_name %>)
  end

  ########################################################################################
  #                                      GET INDEX
  ########################################################################################
  describe "GET index" do
    it "should expose all <%= table_name.pluralize %> as @<%= table_name.pluralize %>" do
      get :index
      assigns[:<%= table_name %>].should == [@<%= file_name %>]
    end
  end

  ########################################################################################
  #                                      GET SHOW
  ########################################################################################
  describe "responding to GET show" do
    it "should expose the requested <%= file_name %> as @<%= file_name %>" do
      get :show, :id => @<%= file_name %>.id
      assigns[:<%= file_name %>].should == @<%= file_name %>
    end  
  end

  ########################################################################################
  #                                      GET NEW
  ########################################################################################
  describe "responding to GET new" do  
    it "should expose a new <%= file_name %> as @<%= file_name %>" do
      get :new
      assigns[:<%= file_name %>].should be_a(<%= class_name %>)
      assigns[:<%= file_name %>].should be_new_record
    end
  end

  ########################################################################################
  #                                      GET EDIT
  ########################################################################################
  describe "responding to GET edit" do  
    it "should expose the requested <%= file_name %> as @<%= file_name %>" do
      get :edit, :id => @<%= file_name %>.id
      assigns[:<%= file_name %>].should == @<%= file_name %>
    end
  end

  ########################################################################################
  #                                      POST CREATE
  ########################################################################################
  describe "responding to POST create" do

    describe "with valid params" do
      before do
        @valid_create_params = {
        } # TODO: define valid params for <%= controller_singular_name %>
      end
      
      it "should create a new <%= file_name %> in the database" do
        pending "need definition of valid_create_params"
        lambda do 
          post :create, :<%= file_name %> => @valid_create_params
        end.should change(<%= class_name %>, :count).by(1)
      end

      it "should expose a saved <%= file_name %> as @<%= file_name %>" do
        pending "need definition of valid_create_params"
        post :create, :<%= file_name %> => @valid_create_params
        assigns[:<%= file_name %>].should be_a(<%= class_name %>)
      end
      
      it "should save the newly created <%= file_name %> as @<%= file_name %>" do
        pending "need definition of valid_create_params"
        post :create, :<%= file_name %> => @valid_create_params
        assigns[:<%= file_name %>].should_not be_new_record
      end

      it "should redirect to the created <%= file_name %>" do
        pending "need definition of valid_create_params"
        post :create, :<%= file_name %> => @valid_create_params
        new_<%= file_name %> = assigns[:<%= file_name %>]
        response.should redirect_to(<%= table_name.singularize %>_url(new_<%= file_name %>))
      end      
    end
    
    describe "with invalid params" do
      before do
        @invalid_create_params = {
        } 
      end
      
      it "should not create a new <%= file_name %> in the database" do
        pending "need definition of invalid_create_params"
        lambda do 
          post :create, :<%= file_name %> => @invalid_create_params
        end.should_not change(<%= class_name %>, :count)
      end      
      
      it "should expose a newly created <%= file_name %> as @<%= file_name %>" do
        pending "need definition of invalid_create_params"
        post :create, :<%= file_name %> => @invalid_create_params
        assigns(:<%= file_name %>).should be_a(<%= class_name %>)
      end
      
      it "should expose an unsaved <%= file_name %> as @<%= file_name %>" do
        pending "need definition of invalid_create_params"
        post :create, :<%= file_name %> => @invalid_create_params
        assigns(:<%= file_name %>).should be_new_record
      end
      
      it "should re-render the 'new' template" do
        pending "need definition of invalid_create_params"
        post :create, :<%= file_name %> => @invalid_create_params
        response.should render_template('new')
      end      
    end    
  end

  ########################################################################################
  #                                      PUT UPDATE
  ########################################################################################
  describe "responding to PUT update" do

    describe "with valid params" do
      before do
        @valid_update_params = {
        } # TODO: Define valid params for update
      end
      
      it "should update the requested <%= file_name %> in the database" do          
        pending "need definition of valid_update_params"
        lambda do
          put :update, :id => @<%= file_name %>.id, :<%= file_name %> => @valid_update_params
        end.should change{ @<%= file_name %>.reload }
      end

      it "should expose the requested <%= file_name %> as @<%= file_name %>" do
        pending "need definition of valid_update_params"
        put :update, :id => @<%= file_name %>.id, :<%= file_name %> => @valid_update_params
        assigns(:<%= file_name %>).should == @<%= file_name %>
      end

      it "should redirect to the <%= file_name %>" do
        pending "need definition of valid_update_params"
        put :update, :id => @<%= file_name %>.id, :<%= file_name %> => @valid_update_params
        response.should redirect_to(<%= table_name.singularize %>_url(@<%= file_name %>))
      end
    end
    
    describe "with invalid params" do
      before do
        @invalid_update_params = {
        } 
      end
      
      it "should not change the <%= file_name %> in the database" do
        pending "need definition of invalid_update_params"
        lambda do 
          put :update, :id => @<%= file_name %>.id, :<%= file_name %> => @invalid_update_params
        end.should_not change{ @<%= file_name %>.reload }
      end

      it "should expose the <%= file_name %> as @<%= file_name %>" do
        pending "need definition of invalid_update_params"      
        put :update, :id => @<%= file_name %>.id, :<%= file_name %> => @invalid_update_params
        assigns(:<%= file_name %>).should == @<%= file_name %>
      end

      it "should re-render the 'edit' template" do
        pending "need definition of invalid_update_params"      
        put :update, :id => @<%= file_name %>.id, :<%= file_name %> => @invalid_update_params
        response.should render_template('edit')
      end
    end
  end


  ########################################################################################
  #                                      DELETE DESTROY
  ########################################################################################
  describe "DELETE destroy" do

    it "should reduce <%= file_name %> count by one" do
      lambda do
        delete :destroy, :id => @<%= file_name %>.id
      end.should change(<%= class_name %>, :count).by(-1)
    end
    
    it "should make the <%= table_name %> unfindable in the database" do    
      delete :destroy, :id => @<%= file_name %>.id
      lambda{ <%= class_name %>.find(@<%= singular_name %>.id)}.should raise_error(ActiveRecord::RecordNotFound)      
    end
  
    it "should redirect to the <%= table_name %> list" do
      delete :destroy, :id => @<%= file_name %>.id
      response.should redirect_to(<%= table_name %>_url)
    end
  end

end
