class TransfersController < ApplicationController
  include AuthenticatedSystem
  include AuthenticatedSystemMod
  before_filter :login_required, :only=>[:new]
  def new
    unless p=params[:transfer]
      p={}; [:amount, :description, :receiver].each{|k| p[k]=params[k] if params[k]}
    end

    if !p[:receiver] || !@receiver=Fuser.find(p[:receiver])
      flash[:notice]="Missing or invalid receiver"
      redirect_back_or_default('/transfers')
    end
    p[:receiver_id]=p.delete(:receiver) if p[:receiver] # for the html view
    @transfer=Transfer.new(p)
  end
  #before_filter :authorize, :except=>[:show, :index]
  # GET /transfers
  # GET /transfers.xml
  def index
    conditions=[]
    sender=Fuser.find(params[:sender]) if params[:sender]
    receiver=Fuser.find(params[:receiver]) if params[:receiever]
    user=Fuser.find(params[:user]) if params[:user]
    if user
      conditions=["sender_id=? or receiver_id=?",user.id,user.id]
    elsif sender and receiver
      conditions=["sender_id=? and receiver_id=?",sender.id,receiver.id]
    elsif sender
      conditions=["sender_id=?",sender.id]
    elsif receiver
      conditions=["receiver_id=?",receiver.id]
    end


    @transfers=Transfer.find(:all, :order=>'created_at DESC', :conditions=>conditions)
    #@transfers = Transfer.find(:all)
    current_fuser
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transfers }
    end
  end

  # GET /transfers/1
  # GET /transfers/1.xml
  def show
    @transfer = Transfer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transfer }
    end
  end

  # POST /transfers
  # POST /transfers.xml
  def create
#    @sender=nil
#    authenticate_or_request_with_http_basic do |username, password|
#      #username == "hector" && password == "pass"
#      @sender=Fuser.authenticate(username,password)
#    end
    
    p=params[:transfer]
    @transfer = Transfer.new(p.merge(
      :sender=>current_fuser,
      :receiver=>Fuser.find(p[:receiver_id] || p[:receiver])
    ))

    respond_to do |format|
      if @transfer.save
        flash[:notice] = 'Transfer was successfully created.'
        format.html { redirect_to(@transfer) }
        format.xml  { render :xml => @transfer, :status => :created, :location => @transfer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @transfer.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected
  def authorize
    authenticate_or_request_with_http_basic do |username, password|
      #username == "hector" && password == "pass"
      @fuser=Fuser.authenticate(username,password)
      @fuser.id == params[:transfer][:sender_id] if @fuser
    end
  end

end
