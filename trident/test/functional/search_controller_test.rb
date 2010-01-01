require File.dirname(__FILE__) + '/../test_helper'
require 'search_controller'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < Test::Unit::TestCase
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'index'
  end
  
  def test_search_query
    get :index, :q => "hello", :s => "snippets"

    assert_response :success
    assert_template 'index'
    
    assert_select "div.result", :count => 2
  end
  
  def test_search_query_users
    get :index, :q => "gabe", :s => "users"

    assert_response :success
    assert_template 'index'
    
    assert_select "div.result", :count => 1
  end
  
end
