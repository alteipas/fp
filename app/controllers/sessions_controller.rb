# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # render new.rhtml
  def new
    respond_to do |format|
      format.html
      format.mobile{ render :action=>'new.html.erb', :layout=>"application"}
    end
  end
  def root
    format = request.request_uri=="/mobile" ? 'mobile' : 'html'
    params[:format]=format
    keep_format
    @abitant=current_abitant
    if @abitant && format!="mobile"
      redirect_to "/#{@abitant.to_param}"
    else
      respond_to do |format|
        format.html {render :action=>'root', :layout=>false}
        format.mobile{ render :action=>'root', :layout=>"application"}
      end
    end
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
      flash[:notice] = "Login/password incorrect"
      render :action => 'new'
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
