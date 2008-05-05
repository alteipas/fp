# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include AuthenticatedSystemMod

  # render new.rhtml
  def new
  end
  def root
    current_fuser
  end
 
  def create
    self.current_fuser = Fuser.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_fuser.remember_me unless current_fuser.remember_token?
        cookies[:auth_token] = { :value => self.current_fuser.remember_token , :expires => self.current_fuser.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
    self.current_fuser.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
