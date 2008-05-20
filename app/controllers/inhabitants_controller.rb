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
    # We try to create a transfer which won't be created (receiver is nil) to check if there are other errors:
    @transfer=Transfer.create(:sender_id=>current_inhabitant.id,
                             :receiver_id=>nil,
                             :amount=>(p.delete(:amount) || 1).to_i,
                             :ip=>request.remote_ip,
                             :description=>p.delete(:description))
    @inhabitant=Inhabitant.new(p)
    transfer_valid = @transfer.errors.count == 1 ? true : false
    respond_to do |format|
      if @inhabitant.valid? && transfer_valid
        #transaction?
        @inhabitant.save
        @transfer.receiver=@inhabitant
        @transfer.save
        
        flash[:notice] = "#{@inhabitant.email} has been invited!"
        format.html { redirect_to(current_inhabitant) }
        format.xml  { render :xml => @inhabitant.to_xml, :status => :created, :location => @inhabitant }
      else
        errors=@inhabitant.valid? ? @transfer.errors : @inhabitant.errors
        format.html { render :action => "new" }
        format.xml  { render :xml => errors, :status => :unprocessable_entity }
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
    [:login,:email,:id,:url,:password,:password_confirmation,:amount,:description].each do |arg|
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
    access_denied if @inhabitant != @current_inhabitant
  end
end
