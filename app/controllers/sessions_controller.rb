# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # render new.rhtml
  def new
  end
  def root
    current_abitant
    render :action=>"root", :layout=>false
  end
 
  def create
    self.current_abitant = Abitant.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_abitant.remember_me unless current_abitant.remember_token?
        cookies[:auth_token] = { :value => self.current_abitant.remember_token , :expires => self.current_abitant.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
      flash[:notice] = "Login/password incorrect"

    end
  end

  def destroy
    self.current_abitant.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
