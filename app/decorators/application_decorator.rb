class ApplicationDecorator < Draper::Base
  def light(status)
    color = "green"
    case status
    when "available"
      color = "green"
    when "unavailable"
      color = "yellow"
    when "offline"
      color = "red"
    end
    h.image_tag "#{color}.png", :class => "light"
  end
end