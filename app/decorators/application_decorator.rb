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
  
  def radial_gradient(stops = [], cx = 0.5, cy = 0.5, r = 0.5)
    {
      radialGradient: { cx: cx, cy: cy, r: r},
      stops: stops
    }
  end
  
  def linear_gradient(stops = [], p1 = [0, 0.5], p2 = [1, 0.5])
    {
      linearGradient: { x1: p1[0], y1: p1[1], x2: p2[0], y2: p2[1] },
      stops: stops
    }
  end
end