class AdminController < ApplicationController
  before_filter :login_required
  
  # only allow Jeff!
  def authorized?
    current_user.id == 1
  end
  
  def index
    @users = User.find :all
    @invitations = Invitation.find :all
    @snippets = Snippet.find :all
    @comments = Comment.find :all
    
    @latestSnippets = []
    
    for snippet in @snippets
      @latestSnippets << snippet if snippet.latest
    end
    
  end
  
  def users
    @users = User.find :all
  end
  
  def invitations
    @users = User.find :all
  end
  
end
