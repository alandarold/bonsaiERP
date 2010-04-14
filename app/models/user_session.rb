# Used to access the authenticated user in the models
class UserSession
  attr_accessor :session
  # Stores using de application_controller the current_user for devise
  def self.current_user=(session)
    @session = session
  end

  def self.current_user
    @session
  end
end
