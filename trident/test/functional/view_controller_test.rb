require File.dirname(__FILE__) + '/../test_helper'
require 'view_controller'

# Re-raise errors caught by the controller.
class ViewController; def rescue_action(e) raise e end; end

class ViewControllerTest < Test::Unit::TestCase
  self.pre_loaded_fixtures = true
  fixtures :licenses

  def setup
    @controller = ViewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_home
    get :home

    assert_response :success
    assert_template 'home'
    assert_select "div.snippets" do
      assert_select "div.icon", :count => Snippet.find(:all).size
    end
    assert_select "div.icon.comment", :count => Comment.find(:all).size
    
  end

  def test_license
    assert_equal 2,License.find(:all).size
    for license in License.find(:all)
      get :license, :id => license.id
      assert_response :success
      assert_template 'license'
      #assert_select 'title', "Kogbox: License"
      #assert_select "pre.license", license.text
    end
  end

  def test_snippet
    Snippet.find(:all) do |snippet|
      get :snippet, :id => snippet.id
      assert_response :success
      assert_template 'snippet'
    end
  end

  def test_user
    User.find(:all) do |user|
      get :user, :id => user.id
      assert_response :success
      assert_template 'user'
    end
  end
  
  
end
