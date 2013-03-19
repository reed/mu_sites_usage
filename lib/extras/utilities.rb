module Utilities
  class DateFormatters
    def self.week(wk)
      week_start = Date.strptime("#{wk} 0", "%Y %U %w")
      week_end = week_start + 6.days
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
    
    def self.snapshot_time(day, time)
      DateTime.strptime(day + time, '%Y-%m-%d%H%M')
    end
    
    def self.format_date_for_subtitle(start_date = nil, end_date = nil)
      f_start = DateTime.strptime(start_date, "%m/%d/%Y") if start_date.present?
      f_end = DateTime.strptime(end_date, "%m/%d/%Y") if end_date.present?
      if start_date.present? && end_date.present?
        if start_date == end_date
          f_start.strftime("%b %e, %Y")
        elsif f_start.month == f_end.month && f_start.year == f_end.year
          f_start.strftime("%b %e - ") + f_end.strftime("%e, %Y")
        elsif f_start.year == f_end.year
          f_start.strftime("%b %e - ") + f_end.strftime("%b %e, %Y")
        else
          f_start.strftime("%b %e, %Y - ") + f_end.strftime("%b %e, %Y")
        end
      elsif start_date.present?
        f_start.strftime("Since %b %e, %Y")
      elsif end_date.present?
        f_end.strftime("Before %b %e, %Y")
      else
        ""
      end
    end
  end
  
  class DateCalculations
    def self.days_between(s, e)
      s = Date.strptime(s, '%Y-%m-%d')
      e = Date.strptime(e, '%Y-%m-%d')
      e.mjd - s.mjd + 1
    end
    
    def self.minute_increments(inc)
      increments = Hash.new
      return increments if inc == 0
      return increments if 60 % inc != 0
      ("00".."23").each do |h|
        ("00".."59").step(inc) do |m|
          increments[h + m] = 0
        end
      end
      increments
    end
  end
  
end