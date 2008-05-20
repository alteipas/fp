# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_to_inhabitant(i)
    link_to i.to_s, "/#{i.to_param}"
  end
end
