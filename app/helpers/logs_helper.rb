module LogsHelper
  def format_log_time(t)
    if t.to_date == Date.today
      t.strftime("Today at %-l:%M %p")
    else
      t.strftime("%a, %-m/%-d/%y at %-l:%M %p")
    end
  end
end
