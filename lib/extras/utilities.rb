module Utilities
  class DateFormatters
    def self.week(wk)
      week_start = Date.strptime("#{wk} 0", "%Y %U %w")
      week_end = Date.strptime("#{wk} 6", "%Y %U %w")
      if week_start.year == week_end.year && week_start.month == week_end.month
        week_start.strftime("%b %e-") + week_end.strftime("%e") + "<br/>" + week_end.strftime("%Y")
      elsif week_start.year == week_end.year
        week_start.strftime("%b %e - ") + week_end.strftime("%b %e") + "<br/>" + week_end.strftime("%Y")
      else
        week_start.strftime("%b %e, %Y -") + "<br/>" + week_end.strftime("%b %e, %Y")
      end
    end
    
    def self.month(m)
      Date.strptime(m, '%Y-%m').strftime('%B %Y')
    end
    
    def self.day(d)
      Date.strptime(d, '%Y-%m-%d').strftime('%-m/%-d/%y')
    end
    
    def self.hour(h)
      n = h == "23" ? "00" : (h.to_i + 1).to_s
      DateTime.strptime(h, '%H').strftime('%-l %p') + " - " + DateTime.strptime(n, '%k').strftime('%-l %p')
    end
  end
end