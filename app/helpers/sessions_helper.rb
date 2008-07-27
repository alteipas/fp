module SessionsHelper
  def mobile_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/)/]
  end

end
