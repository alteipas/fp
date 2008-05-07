class FusersController < ApplicationController
  before_filter :login_required, :except=>[:show, :activate, :new, :index, :invitation]
  before_filter :find_fuser, :only=>[:update, :test_auth, :show]
  before_filter :current_fuser_and_id_must_match, :only=>[:new, :update, :test_auth]

  #before_filter :login_from_basic_auth, :only=>[:test]

  # render new.rhtml
  def new
  end
  def edit
    @fuser=Fuser.find(params[:id])
  end
#  def index LOOK AT the list of users: not show emails, passwords,... (it's not required the method though)
#    @fusers=Fuser.find(:all, :order=>"created_at DESC")
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @fusers.to_xml }
#    end
#
#  end
 
  # GET /fusers/1
  # GET /fusers/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fuser.to_xml }
    end
  end
  def test_auth
    #login_from_basic_auth
    respond_to do |format|
      format.html { render :action=>'show' }
      format.xml  { head :ok }
    end

  end
  # PUT /fusers/1
  # PUT /fusers/1.xml
  def update
    p=params[:fuser] || {}
    %w(login email id url password password_confirmation).each do |n|
      arg=n.to_sym
      if p[arg] && p[arg]==""
        p.delete(arg)
      elsif params[arg]
        p[arg]=params.delete(arg)
      end
    end
    p.delete(:login) if @fuser.login        ## TODO: return 403 instead of deleting it and 200
    respond_to do |format|  ## Next code should do it, but it seems there are a fixtures problem (or something else). Test: test_not_update_username
      if p.include?(:email) and @fuser.active? #or (p.include?(login) and p[:login]!=@fuser.login and !@fuser.login)
        format.xml{ head 403 }
      elsif @fuser.update_attributes(p)
        flash[:notice] = 'Fuser was successfully updated.'
        format.html { redirect_to(@fuser) }
        format.xml  { render :xml => @fuser.to_xml }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fuser.errors, :status => :unprocessable_entity }
      end
    end
  end
  def create
    #cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    p=params[:fuser]
    @fuser = Fuser.new(p)
    respond_to do |format|
      if @fuser.save
        Transfer.create(:receiver=>@fuser, :sender=>current_fuser) #TODO: no favs, no create?
        #self.current_fuser = @fuser
        flash[:notice] = '... has been invited!'
        format.html { redirect_to (current_fuser) }
        format.xml  { render :xml => @fuser.to_xml, :status => :created, :location => @fuser }
}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fuser.errors, :status => :unprocessable_entity }
      end
    end
  end

  def activate
    self.current_fuser = params[:activation_code].blank? ? false : Fuser.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_fuser.active?
      current_fuser.activate
      flash[:notice] = "Email activated!"
      redirect_to edit_fuser_path(current_fuser)
    else
      redirect_back_or_default('/')
    end
  end
  protected

  def find_fuser
    @fuser = Fuser.find(params[:id])
    10.times do
      logger.debug("AAAAAAAAAAAAAA: " + params[:id])
    end
  end
  def current_fuser_and_id_must_match
    #if !@current_fuser or (params[:id]!=@current_fuser.login and params[:id].to_i!=@current_fuser.id)
    access_denied if @fuser != @current_fuser
  end

#  def authorize
#    #authenticate_or_request_with_http_basic do |username, password|
#      #@user=Fuser.authenticate(username,password) \
#      #  and params[:id]==@user.login or params[:id].to_i==@user.id
#    #end
#    if !current_fuser or (params[:id]!=@current_fuser.login and params[:id].to_i!=@current_fuser.id)
#      #access_denied
#      
#      respond_to do |format|
#        format.html { redirect_to '/login' }
#        format.xml  { head 401 }
#      end
#    end
#
#  end
#  
end
