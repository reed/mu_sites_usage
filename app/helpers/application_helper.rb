module ApplicationHelper
  # Return a title on a per-page basis
  def title
    base_title = "Sites Usage"
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
  
  def department_links
    depts = Department.order("display_name")
    render :partial => 'department_link', :collection => depts
  end
  
  def site_links(dept_id)
    sites = Department.find(dept_id).sites.enabled.order("display_name")
    render :partial => 'site_link', :collection => sites
  end
  
  def department_link_active?(id)
    (params[:controller] == "departments" || params[:controller] == "sites") && @department.present? && @department.id == id
  end
  
  def submenu_link_active?(name)
    name == params[:controller]
  end
  
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil)
  end
      
end
