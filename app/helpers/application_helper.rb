module ApplicationHelper
  # Return a title on a per-page basis
  def title
    base_title = "Computing Sites"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
  def page_heading
    if @page_heading.nil?
      if @title.nil?
        params[:controller].capitalize
      else
        @title
      end
    else
      @page_heading
    end
  end
end
