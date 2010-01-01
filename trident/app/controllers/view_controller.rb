class ViewController < ApplicationController
  # require "htmlentities"
  
  def snippet
    if params[:user_id]
      @snippet = Snippet.find_by_method_name(params[:id],:conditions => {:user_id => params[:user_id]},:order => "id DESC")
    else
      params[:id] = Snippet.find_by_method_name(params[:id]).latest_id unless params[:id].i?
      @snippet = Snippet.find(params[:id])
    end
    session[:return_to] = "/view/snippet/"+params[:id].to_s
    @key = cookies[:kogbox]
    @licenses = get_licenses #in application controller
    
    @snippet[:latest] = @snippet.latest
    @snippet[:latest_id] = @snippet.latest_id
    @snippet[:includes] = @snippet.includes
    @snippet[:includers] = @snippet.includers
    @snippet[:author] = @snippet.user.login
    
    if @snippet.published == "private" && @snippet.user_id != current_user.id
      flash[:notice] = "The requested snippet is not public."
      redirect_to "/"
    else
      if params[:comments] == "all"
        @comments = @snippet.all_comments
      else
        @comments = @snippet.comments
      end
    end
    render :xml => @snippet if params[:format] == "xml"
  end
  
  def lineage
    @snippet = Snippet.find(params[:id])
    @includes = @snippet.includes
    @includers = @snippet.includers
  end
  
  def latest
    if params[:id].i?
      snippet = Snippet.find_by_method_name params[:format], :conditions => {:user_id => params[:id]}, :order => 'id DESC'
      redirect_to :action => "snippet", :id => snippet.latest_id
    else
      user = User.find_by_login params[:id]
      snippet = Snippet.find_by_method_name params[:format], :conditions => {:user_id => user.id}, :order => 'id DESC'
      redirect_to :action => "snippet", :id => snippet.latest_id
    end
  end
  
  def user
    params[:id] = User.find_by_login(params[:id]).id unless params[:id].i?
    @user = User.find params[:id]
    @key = cookies[:kogbox]
    snippets = Snippet.find :all, :conditions => {:user_id => @user, :published => 'public'}
    @snippets = []
    for snippet in snippets
      @snippets << snippet if snippet.latest
    end
    @snippets.reverse!
    @licenses = get_licenses #in application controller
    render :xml => @snippets if params[:format] == "xml"
  end
  
  def home
  end
  
  def license
    @license = License.find params[:id]
  end
  
  def all
    @recent = Snippet.find :all, :conditions => {:release => "production", :published => "public"}, :limit => 8, :order => 'id DESC'
    @used = Snippet.find :all, :conditions => {:release => "production", :published => "public"}, :limit => 8, :order => 'total_use DESC'
    @newusers = User.find :all, :limit => 8, :order => "id DESC"

    # @included = Includes.find :all, :limit => 50, :order => 'total_use DESC'
    
    recent = Snippet.find :all, :conditions => ["created_on > ?", Time.now-1.year], :limit => 100, :order => 'id DESC'
    users = []
    for snippet in recent
      users << snippet.user_id
    end
    users.uniq!
    
    @users = User.find_all_by_id users, :limit => 8
    @users.sort! {|x,y| y.snippets.size <=> x.snippets.size}
  end
  
end
