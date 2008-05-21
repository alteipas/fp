class TransfersController < ApplicationController
  before_filter :login_required, :only=>[:new]
  def new
    p=prepare_params(params)
    if !p[:receiver] || !@receiver=Abitant.find(p[:receiver])
      flash[:notice]="Missing or invalid receiver"
      redirect_back_or_default('/transfers')
    else
      p[:receiver]=@receiver
      @transfer=Transfer.new(p)
    end
  end
  #before_filter :authorize, :except=>[:show, :index]
  # GET /transfers
  # GET /transfers.xml
  def index
    conditions=[]
    sender=Abitant.find(params[:sender]) if params[:sender]
    receiver=Abitant.find(params[:receiver]) if params[:receiever]
    user=Abitant.find(params[:id]) if params[:id]
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
    current_abitant
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transfers.to_xml(:except=>[:ip]) }
    end
  end

  # GET /transfers/1
  # GET /transfers/1.xml
  def show
    @transfer = Transfer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transfer.to_xml(:except=>[:ip]) }
    end
  end


  # POST /transfers
  # POST /transfers.xml
  def create
    p=prepare_params(params)
    r=Abitant.find(p[:receiver_id] || p[:receiver])
    @transfer = Transfer.new(p.merge(
      :sender=>current_abitant,
      :receiver=>r,
      :ip=>request.remote_ip)
    )

    respond_to do |format|
      if @transfer.save
        flash[:notice] = 'Transfer was successfully created.'
        format.html { redirect_to(@transfer) }
        format.xml  { render :xml => @transfer, :status => :created, :location => @transfer }
      else
        format.html { render :action=>"new" }
        format.xml  { render :xml => @transfer.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  def prepare_params(params)
    p=params[:transfer] || {}
    [:receiver_id, :receiver, :sender, :sender_id, :amount, :description, :link].each do |arg|
      if p[arg] && p[arg]==""
        p.delete(arg)
      elsif params[arg]
        p[arg]=params.delete(arg)
      end
    end
    p
  end

  def authorize
    authenticate_or_request_with_http_basic do |username, password|
      @abitant=Abitant.authenticate(username,password)
      @abitant.id == params[:transfer][:sender_id] if @abitant
    end
  end

end
