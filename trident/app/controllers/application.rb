# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_trident_session_id'
  
  # ActiveScaffold.set_defaults do |config| 
  #   config.ignore_columns.add [ :crypted_password,
  #                               :remember_token, 
  #                               :remember_token_expires_at,
  #                               :salt,
  #                               :comments,
  #                               :snippets,
  #                               :invitations]
  # end
  
  def get_licenses
      licenses = License.find :all, :order => "id DESC"
      hashedlicenses = {}
      licenses.each do |license|
        hashedlicenses[license.id] = license.name
      end
      hashedlicenses
  end
    
end

class String
  def i?(allowScientific = false)
      if allowScientific
        return (self =~ /^-?\d+(e-?\d+)?$/) != nil
      end
      (self =~ /^-?\d+$/) != nil
    end
end
