class InhabitantsController < ApplicationController
  before_filter :login_required, :except=>[:show, :activate, :new, :index, :invitation, :forgot]
  before_filter :find_inhabitant, :only=>[:update, :test_auth, :show, :edit]
  before_filter :current_inhabitant_and_id_must_match, :only=>[:new, :update, :test_auth]

  #before_filter :login_from_basic_auth, :only=>[:test]

  # render new.rhtml
  def new
  end
  def edit
    @inhabitant=Inhabitant.find(params[:id])
  end
  def index
    @inhabitants=Inhabitant.find(:all, :order=>"created_at DESC")
    respond_to do |format|
      format.html
      format.xml  { render :xml => @inhabitants.to_xml(:only=>Inhabitant.public_params) }
    end

  end
 
  # GET /inhabitants/1
  # GET /inhabitants/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inhabitant.to_xml }
    end
  end
  def test_auth
    #login_from_basic_auth
    respond_to do |format|
      format.html { render :action=>'show' }
      format.xml  { head :ok }
    end

  end
  # PUT /inhabitants/1
  # PUT /inhabitants/1.xml
  def update
    p=prepare_params(params)
    p.delete(:login) if @inhabitant.login        ## TODO: return 403 instead of deleting it and 200
    respond_to do |format|  ## Next code should do it, but it seems there is a fixtures problem (or something else). Test: test_not_update_username
      if p.include?(:email) and @inhabitant.active? #or (p.include?(login) and p[:login]!=@inhabitant.login and !@inhabitant.login)
        format.xml{ head 403 }
      elsif @inhabitant.update_attributes(p)
        flash[:notice] = 'Inhabitant was successfully updated.'
        format.html { redirect_to(@inhabitant) }
        format.xml  { render :xml => @inhabitant.to_xml }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inhabitant.errors, :status => :unprocessable_entity }
      end
    end
  end
  def create
    #cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    p=prepare_params(params)
    p[:inviter_id]=current_inhabitant.id
    @inhabitant = Inhabitant.new(p)
    respond_to do |format|
      if @inhabitant.save

        t=Transfer.create(:sender_id=>p[:inviter_id], :receiver_id=>@inhabitant.id, :amount=>@inhabitant.invitation_favs, :ip=>request.remote_ip) unless @inhabitant.superuser?
        
        flash[:notice] = "#{@inhabitant.email} has been invited!"
        format.html { redirect_to (current_inhabitant) }
        format.xml  { render :xml => @inhabitant.to_xml, :status => :created, :location => @inhabitant }
      else

        format.html { render :action => "new" }
        format.xml  { render :xml => @inhabitant.errors, :status => :unprocessable_entity }
      end
    end
  end

  def activate
    self.current_inhabitant = params[:login_by_email_token].blank? ? false : Inhabitant.find_by_login_by_email_token(params[:login_by_email_token])
    if logged_in?
      if !current_inhabitant.active?
        current_inhabitant.activate
        flash[:notice] = "Email activated!"
      else
        #forgot
        current_inhabitant.login_by_email_token = nil
        current_inhabitant.save
      end
      redirect_to edit_inhabitant_path(current_inhabitant)
    else
      redirect_back_or_default('/')
    end
  end
  def forgot
    if request.post?
      @inhabitant=Inhabitant.find_by_email(params[:email])
      if @inhabitant.make_login_by_email_token 
        @inhabitant.save
        InhabitantMailer.deliver_forgot(@inhabitant)
        flash[:notice] = "An email has been sent to change your password"
      else
        flash[:notice] = "Email not found"
      end
    end
  end

  protected

  def prepare_params(params)
    p=params[:inhabitant] || {}
    [:login,:email,:id,:url,:password,:password_confirmation,:invitation_favs].each do |arg|
      if p[arg] && p[arg]==""
        p.delete(arg)
      elsif params[arg]
        p[arg]=params.delete(arg)
      end
    end
    p
  end

  def find_inhabitant
    @inhabitant = Inhabitant.find(params[:id])
    unless @inhabitant
      respond_to do |format|
        format.html { render :file => 'public/404.html', :status=>404 }
        format.xml  { head 404 }
      end
    end
   end
  def current_inhabitant_and_id_must_match
    #if !@current_inhabitant or (params[:id]!=@current_inhabitant.login and params[:id].to_i!=@current_inhabitant.id)
    access_denied if @inhabitant != @current_inhabitant
  end

#  def authorize
#    #authenticate_or_request_with_http_basic do |username, password|
#      #@user=Inhabitant.authenticate(username,password) \
#      #  and params[:id]==@user.login or params[:id].to_i==@user.id
#    #end
#    if !current_inhabitant or (params[:id]!=@current_inhabitant.login and params[:id].to_i!=@current_inhabitant.id)
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
