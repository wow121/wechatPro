module ApplicationHelper
=begin
  def notice 
     msg =  ''
     msg << (content_tag :div, notice, :class => "notice") if notice
     sanitize msg
   end
=end
end
