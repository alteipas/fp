# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include AuthenticatedSystemMod
  filter_parameter_logging "password"
  before_filter :keep_format
 
  helper :all # include all helpers, all the time


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '580f6e0dbd3831ee944d7538ecf4481e'
  def keep_format
    if params[:format] && params[:format]!='xml'
      flash[:format]=params[:format]
    elsif flash[:format]
      params[:format]=flash[:format]
      flash[:format]=flash[:format]
    end
  end
end
