# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_to_abitant(i)
    link_to i.to_s, "/#{i.to_param}"
  end
  def link_to_xml(url=request.request_uri.to_s)
    link_to(image_tag("xml.gif",:border=>0), add_format_to_url(url,"xml"))
  end
  def add_format_to_url(url,ext)
    if url.class==String
      if url =~ /\?/
        url="#{$`}.#{ext}?#{$'}"
      else
        url=url + "." + ext
      end
    else
      url=url.merge(:format=>:xml)
    end
  end

end
