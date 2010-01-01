require File.dirname(__FILE__) + '/../test_helper'
#require 'snippets_controller'

class SnippetsControllerTest < ActionController::IntegrationTest
  # self.use_transactional_fixtures = true
  # self.use_instantiated_fixtures = false
  #self.pre_loaded_fixtures = true
  
  fixtures :users

  def setup
    @controller = SnippetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_invitation
    logs_in_as('jeff')
    get "/account/invite"
    assert_response :success
    assert_template 'account/invite'
    assert_select "title", "Kogbox: Invite"
    assert_select "input#recipient"
    assert_select "h2","Invite people to Kogbox"  	
  end
  
  private
    
    # attr_reader :user
    # 
    #    def logs_in_as(user)
    #      @user = users(user)
    #      post "/account/login", :login => @user.login, :password => "secret"+@user.login
    #      #assert_response :success
    #      #assert_template '/snippets/list'
    #      assert_redirected_to "snippets/list"
    #    end
end