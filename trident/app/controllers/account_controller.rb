class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  require 'digest/md5'
  
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :login_required, :only => [:invite]

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      cookies[:kogbox] = {  :value => Digest::MD5.hexdigest(current_user.email) , 
                            :expires => 2.weeks.from_now.utc,
                            :domain => ".kogbox.com" }
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default("/snippets")
      flash[:notice] = "Logged in successfully"
    end
  end
  
  # def update
  #   @user = current_user
  #   newParams = params[:user]
  #   newParams[:password] = params[:new_password]
  #   if @user.update_attributes(params[:user])
  #     flash[:notice] = 'Profile changes saved.'
  #     redirect_to :action => 'show', :id => @user
  #   else
  #     render :action => 'edit'
  #   end
  #   rescue ActiveRecord::RecordInvalid
  #     render :action => 'edit'
  # end

  def signup
    if Invitation.find_by_key params[:id]
      @user = User.new(params[:user])
      return unless request.post?
      Invitation.find_by_key(params[:id]).destroy if @user.save!
      self.current_user = @user
      flash[:notice] = "Thanks for signing up!"
      redirect_to :controller => 'snippets', :action => 'list'
    else
      flash[:error] = "This service is by invitation only. Contact <a href='mailto:support@kogbox.com'>support@kogbox.com</a> to be added to the invite list, or ask an existing member.</a>"
      redirect_to :controller => 'view', :action => 'home'
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    cookies.delete :kogbox
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to :controller => 'view', :action => 'home'
  end
  
  def invite
    return unless request.post?
      recipients = params[:recipient].split(',')
      for recipient in recipients
        recipient.strip!
        key = Digest::MD5.hexdigest(recipient)
        Mail.deliver_invite(current_user,recipient,key)
        invitation = Invitation.new({:user_id => current_user.id, :recipient => recipient, :key => key})
        invitation.save
      end
      flash[:notice] = 'Invite sent to the following: '+params[:recipient]
      redirect_to :controller => 'snippets', :action => 'list'
    rescue ActiveRecord::RecordInvalid
      render :action => 'invite'
  end

end
