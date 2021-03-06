require 'will_paginate'

class AbitantsController < ApplicationController
  before_filter :login_required, :except=>[:show, :activate, :new, :index, :invitation, :forgot]
  before_filter :find_abitant, :only=>[:update, :show, :edit]
  before_filter :current_abitant_and_id_must_match, :only=>[:new, :update]

  #before_filter :login_from_basic_auth, :only=>[:test]

  # render new.rhtml
  def new
  end
  def edit
    @abitant=Abitant.find(params[:id])
  end
  def index
    
    @abitants=Abitant.paginate(:all,
                               :order=>'created_at DESC',
                               :page => params[:page], 
                               :per_page => 2 )
    respond_to do |format|
      format.html
      format.xml  { render :xml => @abitants.to_xml(:only=>Abitant.public_params) }
    end

  end
 
  # GET /abitants/1
  # GET /abitants/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @abitant.to_xml }
    end
  end
  def test_auth
    @abitant=current_abitant
    #login_from_basic_auth
    respond_to do |format|
      format.html { render :action=>'show' }
      format.xml  { render :xml => @abitant.to_xml(:only=>Abitant.public_params<<:crypted_password) }
    end

  end
  # PUT /abitants/1
  # PUT /abitants/1.xml
  def update
    p=prepare_params(params)
    #p.delete(:login) if @abitant.login
    respond_to do |format|
      if p.include?(:email) and @abitant.active?
        @abitant.errors.add("email", "can't be changed after activation (for now)")
        format.xml  { render :xml => @abitant.errors, :status => :unprocessable_entity }
      elsif @abitant.login && p[:login] && p[:login] != @abitant.login
        @abitant.errors.add("login", "can't be changed (#{@abitant.login})")
        format.xml  { render :xml => @abitant.errors, :status => :unprocessable_entity }
      elsif @abitant.update_attributes(p)
        flash[:notice] = 'Abitant was successfully updated.'
        format.html { redirect_to(@abitant) }
        format.xml  { render :xml => @abitant.to_xml }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @abitant.errors, :status => :unprocessable_entity }
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
    @transfer=Transfer.new(:sender_id=>current_abitant.id,
                             :receiver_id=>nil,
                             :amount=>(p.delete(:amount) || 1).to_i,
                             :ip=>request.remote_ip,
                             :description=>p.delete(:description),
                             :link=>p.delete(:link))
    @abitant=Abitant.new(p)
    @transfer.valid?
    transfer_valid = @transfer.errors.count == 1 ? true : false
    respond_to do |format|
      if @abitant.valid? && transfer_valid
        #transaction?
        @abitant.save
        @transfer.receiver_id=@abitant.id
        @transfer.valid?
        @transfer.save
        
        flash[:notice] = "#{@abitant.email} has been invited!"
        format.html { redirect_to(current_abitant) }
        format.xml  { render :xml => @abitant.to_xml(:only=>Abitant.public_params<<:crypted_password), :status => :created, :location => @abitant }
      else
        unless transfer_valid
          @transfer.errors.each do |param, msg|
            @abitant.errors.add(param, msg) unless param=="receiver_id"
          end
        end
        @aa=@abitant.errors
        format.html { render :action => "new" }
        format.xml  { render :xml => @abitant.errors, :status => :unprocessable_entity }
      end
    end
  end

  def activate
    self.current_abitant = params[:login_by_email_token].blank? ? false : Abitant.find_by_login_by_email_token(params[:login_by_email_token])
    if logged_in?
      if !current_abitant.active?
        current_abitant.activate
        flash[:notice] = "Email activated!"
      else
        #forgot
        current_abitant.login_by_email_token = nil
        current_abitant.save
      end
      redirect_to edit_abitant_path(current_abitant)
    else
      redirect_back_or_default('/')
    end
  end
  def forgot
    if request.post?
      if @abitant=Abitant.find_by_email(params[:email])
        @abitant.make_login_by_email_token 
        @abitant.save
        AbitantMailer.deliver_forgot(@abitant)
        flash[:notice] = "An email has been sent to change your password"
      else
        flash[:notice] = "Email not found"
      end
    end
    render :action=>"forgot", :layout=>"sessions"
  end

  protected

  def prepare_params(params)
    p=params[:abitant] || {}
    [:login,:email,:id,:url,:password,:password_confirmation,:amount,:description].each do |arg|
      if p[arg] && p[arg]==""
        p.delete(arg)
      elsif params[arg]
        p[arg]=params.delete(arg)
      end
    end
    p
  end

  def find_abitant
    @abitant = Abitant.find(params[:id])
    unless @abitant
      respond_to do |format|
        format.html { render :file => 'public/404.html', :status=>404 }
        format.xml  { head 404 }
      end
    end
   end
  def current_abitant_and_id_must_match
    access_denied if @abitant != @current_abitant
  end
end
