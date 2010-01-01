class SnippetsController < ApplicationController
  before_filter :login_required, :except => [:comment]
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @key = cookies[:kogbox]
    @snippets = current_user.latest_snippets
    @recent = Snippet.find :all, :conditions => {:release => "production", :published => "public"}, :limit => 6, :order => 'id DESC'
    @recentComments = Comment.find :all, :limit => 5, :order => 'id DESC'
    @licenses = get_licenses #in application controller
  end

  def new
    @snippet = Snippet.new
    @licenses = License.find :all
    @new = true
  end
  
  def create
    if params[:format] == "xml"
      @snippet = Snippet.new()
      @snippet.code = params[:code]
      @snippet.language = params[:language]
      @snippet.published = params[:published]
      @snippet.description = params[:description]
      @snippet.license_id = params[:license_id]
      @snippet.release = params[:release]
      @snippet.method_name = params[:method_name]
      @snippet.user_id = current_user.id
      if @snippet.save
        render :xml => @snippet
      end
    else
      @snippet = Snippet.new(params[:snippet])
      @snippet.user_id = current_user.id
      @licenses = License.find :all
      if @snippet.save
        flash[:notice] = 'Snippet was successfully created.'
          redirect_to :controller => 'snippets', :action => 'editor', :id => @snippet.id
      else
        render :action => 'new'
      end      
    end
  end

  def duplicate
    snippet = Snippet.find(params[:id])
    @snippet = Snippet.new({  :user_id => current_user.id,
                              :method_name => snippet.method_name+"_dup",
                              :code => snippet.code,
                              :language => snippet.language,
                              :version => snippet.version+1,
                              :description => "(Based on <a href='/view/user/"+snippet.user_id.to_s+"'>"+snippet.user.login+"'s</a> '<a href='/view/snippet/"+snippet.id.to_s+"'>"+snippet.method_name+"</a>'): "+snippet.description,
                              :release => "development",
                              :ancestor_id => snippet.id })
    @licenses = License.find :all
    if @snippet.save
      flash[:notice] = "Snippet was duplicated from <a href='/view/user/"+snippet.user_id.to_s+"'>"+snippet.user.login+"'s</a> '<a href='/view/snippet/"+snippet.id.to_s+"'>"+snippet.method_name+"</a>'."
      redirect_to :controller => 'snippets', :action => 'editor', :id => @snippet.id
    else
      render :action => 'new'
    end
  end

  def edit
    @new = false
    @key = cookies[:kogbox]
    @snippet = Snippet.find(params[:id])
    @linecount = @snippet.code.scan(/\n/).size + 20
    @linecount = 36 if @linecount < 30
    unless @snippet.latest 
      flash.now[:warning] = 'Note: you are editing an older version of this snippet. <a href="/snippets/editor/'+@snippet.latest_id.to_s+'">Edit the latest version</a>.'
    end
    @licenses = License.find :all
    if current_user.id != @snippet.user_id
      flash[:notice] = "You don't have permission to edit that method."
      redirect_to :action => "list"
    end
  end
  
  def editor
    edit
    render :action => "edit", :layout => "fullscreen"
  end
  
  def update
    @save_over = "true" if params[:over] == "on"
    if current_user.id != Snippet.find(params[:id]).user_id
      flash[:error] = "You don't have permission to edit that method."
      redirect_to :action => "list"
    else
      @licenses = License.find :all
      if params[:over] == "on"
          @snippet = Snippet.find(params[:id])
          params[:snippet][:version] = @snippet.latest_version+1
          if @snippet.update_attributes(params[:snippet])
            @snippet.save
            flash[:notice] = 'Snippet saved over previous version.'
            if params[:save_and_continue] == "Save and continue editing"
              redirect_to :controller => 'snippets', :action => params[:editor], :id => @snippet
            else
              redirect_to :controller => 'view', :action => 'snippet', :id => @snippet
            end
          else
            #fail
            flash.now[:error] = "There was an error. Your snippet could not be saved! Please try again."
            render :controller => 'snippets', :action => 'edit'
          end
      else
        oldSnippet = Snippet.find(params[:id])
        params[:snippet][:release] = "development" unless params[:snippet][:release]
        params[:snippet][:version] = oldSnippet.latest_version+1
        params[:snippet][:user_id] = current_user.id
        params[:snippet][:language] = oldSnippet.language unless params[:snippet][:language]
        @snippet = Snippet.new(params[:snippet])
        if @snippet.save
          flash[:notice] = 'Snippet saved as version '+(@snippet.version).to_s+"."
          if params[:save_and_continue] == "Save and continue editing"
            redirect_to :controller => 'snippets', :action => params[:editor], :id => @snippet
          else
            redirect_to :controller => 'view', :action => 'snippet', :id => @snippet
          end
        else
          #fail
          flash.now[:error] = "There was an error. Your snippet could not be saved! Please try again."
          @oldSnippet = oldSnippet
          render :controller => 'snippets', :action => 'edit'
        end
      end
      flash.now[:warning] = 'Warning: you just saved an older version of this snippet as version'+(@snippet.latest_id+1).to_s+'.' unless @snippet.latest
    end
  end

  def destroy
    child = Snippet.find params[:id]
    parent = Snippet.find :first, :conditions  => {:user_id => child.user_id,:method_name => child.method_name}, :order => "id DESC"
    if current_user.id == child.user_id
      Snippet.find(params[:id]).destroy
      flash[:notice] = "Snippet deleted."
      if parent == child
        redirect_to :controller => "view", :action => 'user', :id => parent.user_id
      else
        redirect_to :controller => "view", :action => 'snippet', :id => parent.id
      end
    else
      flash[:error] = "You don't have permission to delete that snippet."
      redirect_to :controller => "view", :action => 'snippet', :id => parent.id
    end
  end
  
  def comment
    comment = params[:comment]
    comment[:user_id] = current_user.id
    comment[:snippet_id] = params[:id]
    @comment = Comment.new(comment)
    if (verify_recaptcha || logged_in?) && @comment.save
      flash[:notice] = 'Comment posted.'
    else
      flash[:error] = 'There was an error.'
    end
    redirect_to :controller => 'view', :action => 'snippet', :id => params[:id]
  end
  
end
