module AuthlogicTestHelper
  def current_user(stubs = {})
    return nil if current_user_session.nil?
    current_user_session.user 
  end

  alias :current_person :current_user

  def current_user_session(stubs = {}, user_stubs = {}) 
    @current_user_session = UserSession.find
    # else  
    #   @current_user_session ||= mock_model(UserSession, {:person => current_user(user_stubs)}.merge(stubs))
    # end  
  end    

  def login_as(user)
    user = Factory.create(user) if Symbol === user
    @current_session = UserSession.create(user)
    user
  end

  def logout
    @current_user_session = nil
    UserSession.find.destroy if UserSession.find
  end               
  
  def authenticate(user)
    activate_authlogic
    login_as(user)
  end
end

class Spec::Rails::Example::ControllerExampleGroup
  include AuthlogicTestHelper
end

class Spec::Rails::Example::ViewExampleGroup
  include AuthlogicTestHelper
end

class Spec::Rails::Example::HelperExampleGroup
  include AuthlogicTestHelper
end
