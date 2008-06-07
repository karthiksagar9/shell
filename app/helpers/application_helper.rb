# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def admin?
    return true if current_user.role.eql? 'administrator'
  end
end
