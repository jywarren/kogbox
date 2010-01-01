require File.dirname(__FILE__) + '/../test_helper'
#require 'snippets_controller'

class SnippetsControllerTest < ActionController::IntegrationTest
  # self.use_transactional_fixtures = true
  # self.use_instantiated_fixtures = false
  #self.pre_loaded_fixtures = true
  
  fixtures :snippets, :users, :includes

  def setup
    @controller = SnippetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    #@first_id = snippets(:first).id
  end

  def test_list
    logs_in_as('jeff')
    get "/snippets/index"    
    assert_response :success
    assert_template 'snippets/list'
  end
  
  def test_all_user_lists
    for user in User.find(:all)
          logs_in_as(user.login)
          get "/snippets/index"
          assert_response :success
          assert_template 'snippets/list'
          if user.id == 2
            assert_equal 3, user.snippets.size
          end
    end
  end
  
  def test_new
    logs_in_as('jeff')
    get "/snippets/new"
    assert_response :success
    assert_template 'snippets/new'
  end
  
  def test_edit
    logs_in_as('jeff')
    Snippet.find(:all) do |snippet|
      get "/snippets/edit", :id => snippet.id
      assert_response :success
      assert_template 'snippets/edit'
      assert_select "title", "Kogbox: Edit"
    end
  end
  
  def test_edit_single
    logs_in_as('jeff')
    get "/snippets/edit", :id => 1
    assert_response :success
    assert_template 'snippets/edit'
    assert_select "title", "Kogbox: Edit"
  end
  
  def test_edit_save
    logs_in_as('jeff')
    
    assert_equal 5, Snippet.count
    assert_equal 5, Snippet.find(:all).size
    
    for snippet in Snippet.find(:all)
      get "/snippets/edit", :id => snippet.id
      if snippet.user_id == User.find(:first).id
        assert_response :success
        assert_template 'snippets/edit'
        assert_select "title", "Kogbox: Edit"
      
        snippet.code = "Hello, World, I just deleted this snippet's code... <?php include_snippet(1,'hello_world'); ?>"
        snippet.description = "The description should change too."
        snippet.release = "production"
        oldversion = (snippet.version)
      
        post "/snippets/update", :id => snippet.id, :snippet => { :method_name => snippet.method_name,
                                                                  :language => snippet.language,
                                                                  :published => snippet.published,
                                                                  :description => snippet.description,
                                                                  :code => snippet.code,
                                                                  :release => snippet.release },
                                                    :editor => "edit"
      
        assert_response :success
        assert_template 'snippets/edit'
        
        get "/view/snippet", :id => snippet.latest_id
        
        assert_select "div#versions > p.version.current > a", "v."+oldversion.to_s
        assert_select "h1 > a", snippet.method_name
        assert_select "div#includes b.includedbythis a", "hello_world"
        
        assert_equal "The description should change too.", Snippet.find(:first, :conditions => {:method_name => snippet.method_name}, :order => "id DESC").description
        assert_not_nil Include.find(:first, :conditions => {:snippet_id => Snippet.find_by_method_name("hello_world", :conditions => {:user_id => 1}, :order => "id DESC").id,:user_id => snippet.user_id, :parent_id => snippet.latest_id})
        
      else
        assert_response 302
        assert_redirected_to :controller => "snippets", :action => "list"
      end
    end
    
  end
  
  def test_edit_save_over
    logs_in_as('gabe')
    
    get "/snippets/index", :id => 2
    assert_response :success
    assert_template 'snippets/list'
    
    
    for snippet in Snippet.find(:all)
      get "/snippets/edit", :id => snippet.id
      if snippet.user_id == 2
        assert_response :success
        assert_template 'snippets/edit'
        assert_select "title", "Kogbox: Edit"
      
        snippet.code = "Hello, World, I just deleted this snippet's code... <?php include_snippet(1,'hello_world'); ?>"
        snippet.description = "The description should change too."
        snippet.release = "production"
        newversion = (Snippet.find(snippet.latest_id).version+1).to_s
      
        post "/snippets/update", :id => snippet.id, :snippet => { :method_name => snippet.method_name,
                                                                  :language => snippet.language,
                                                                  :published => snippet.published,
                                                                  :description => snippet.description,
                                                                  :code => snippet.code,
                                                                  :release => snippet.release },
                                                    :over => "on",
                                                    :editor => "edit"
      
        assert_response 302
        assert_redirected_to 'view/snippet'
        assert_equal "Snippet saved over previous version.", flash[:notice]
        
        # assert_equal snippet.latest_id, snippet.id
        
        get "/view/snippet", :id => snippet.id
        
        assert_select "div#versions > p.version.current > a", "v."+newversion
        assert_select "h1 > a", snippet.method_name
        assert_select "div#includes b.includedbythis a", "hello_world"
        
        assert_equal "The description should change too.", Snippet.find(snippet.id).description
        assert_not_nil Include.find(:first, :conditions => {:snippet_id => Snippet.find_by_method_name("hello_world", :conditions => {:user_id => 1}, :order => "id DESC").id,:user_id => 1, :parent_id => snippet.id})
        
      else
        assert_response 302
        assert_redirected_to :controller => "snippets", :action => "list"
      end
    end
    
  end
  
  def test_edit_save_single
    logs_in_as('jeff')
    snippet = Snippet.find :first #snippets(:first)
    
    get "/snippets/edit", :id => snippet.id
    assert_response :success
    assert_template 'snippets/edit'
    assert_select "title", "Kogbox: Edit"
    
    snippet.code = "Hello, World, I just deleted this snippet's code..."
    
    post "/snippets/update", :id => snippet.id, :snippet => { :method_name => snippet.method_name,
                                                              :language => snippet.language,
                                                              :published => snippet.published,
                                                              :description => snippet.description,
                                                              :code => snippet.code,
                                                              :release => snippet.release },
                                                :editor => "edit"

    assert_response :success
    assert_template 'snippets/edit'
    # follow_redirect
    # assert_template 'view/snippet'
    # assert_select "title", "Kogbox: Edit"
  end
  
  def test_edit_save_single_and_continue_editing
    logs_in_as('jeff')
    snippet = Snippet.find :first
    
    get "/snippets/edit", :id => snippet.id
    assert_response :success
    assert_template 'snippets/edit'
    assert_select "title", "Kogbox: Edit"
    
    snippet.code = "Hello, World, I just deleted this snippet's code..."
    
    post "/snippets/update", :id => snippet.id, :snippet => { :method_name => snippet.method_name,
                                                              :language => snippet.language,
                                                              :published => snippet.published,
                                                              :description => snippet.description,
                                                              :code => snippet.code,
                                                              :release => snippet.release },
                                                :save_and_continue => "Save and continue editing",
                                                :editor => "edit"
    
    assert_response :success
    assert_template 'snippets/edit'
    
    assert_select "title", "Kogbox: Update"
  end
    
  private
    
    # attr_reader :user

    def logs_in_as(user)
      @user = User.find_by_login user
      post "/account/login", :login => @user.login, :password => "secret"+@user.login
      #assert_response :success
      #assert_template '/snippets/index'
      assert_redirected_to "snippets/index"
    end

end
