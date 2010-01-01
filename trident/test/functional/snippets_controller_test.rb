require File.dirname(__FILE__) + '/../test_helper'
require 'snippets_controller'

# Re-raise errors caught by the controller.
class SnippetsController; def rescue_action(e) raise e end; end

class SnippetsControllerTest < Test::Unit::TestCase
  fixtures :snippets

  def setup
    @controller = SnippetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = snippets(:first).id
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  # def test_index
  #   get :index
  #   
  #   assert_response :success
  #   assert_template 'list'
  # end
  # 
  # def test_list
  #   get :list
  # 
  #   assert_response :success
  #   assert_template 'list'
  # 
  #   assert_not_nil assigns(:snippets)
  # end
  # 
  # def test_new
  #   get :new
  # 
  #   assert_response :success
  #   assert_template 'new'
  # 
  #   assert_not_nil assigns(:snippet)
  # end
  # 
  # def test_create
  #   num_snippets = Snippet.count
  # 
  #   post :create, :snippet => {}
  # 
  #   assert_response :redirect
  #   assert_redirected_to :action => 'list'
  # 
  #   assert_equal num_snippets + 1, Snippet.count
  # end
  # 
  # def test_edit
  #   get :edit, :id => @first_id
  # 
  #   assert_response :success
  #   assert_template 'edit'
  # 
  #   assert_not_nil assigns(:snippet)
  #   assert assigns(:snippet).valid?
  # end
  # 
  # def test_update
  #   post :update, :id => @first_id
  #   assert_response :redirect
  #   assert_redirected_to :action => 'show', :id => @first_id
  # end
  # 
  # def test_destroy
  #   assert_nothing_raised {
  #     Snippet.find(@first_id)
  #   }
  # 
  #   post :destroy, :id => @first_id
  #   assert_response :redirect
  #   assert_redirected_to :action => 'list'
  # 
  #   assert_raise(ActiveRecord::RecordNotFound) {
  #     Snippet.find(@first_id)
  #   }
  # end
end
