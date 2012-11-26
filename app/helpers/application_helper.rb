module ApplicationHelper
  # Return a title on a per-page basis
  def title
    base_title = "MU DoIT Sites Usage"
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
    depts = Rails.cache.fetch 'department_list' do
      Department.order("display_name").all
    end
    render :partial => 'department_link', :collection => depts
  end
  
  def site_links(dept_id)
    dept = Department.find(dept_id)
    sites = dept.sites.enabled.includes(:department)
    sites = sites.external unless allow? :sites, :view_internal_sites
    grouped_sites = sites.to_a.group_by{|s| s.site_type }
    render partial: 'site_links', locals: { grouped_sites: grouped_sites, department: dept }
  end
  
  def department_link_active?(id)
    (params[:controller] == "departments" || params[:controller] == "sites") && @department.present? && @department.id == id
  end
  
  def submenu_link_active?(name)
    if name == "sites"
      name == params[:controller] && params[:action] == "index"
    else
      name == params[:controller]
    end
  end
  
  def sortable(column, title = nil)
    title ||= column.titleize
    icons = {"asc" => "ui-icon-triangle-1-n", "desc" => "ui-icon-triangle-1-s"}
    icon = column == sort_column ? content_tag(:span, "", :class => "sort-icon ui-icon #{icons[sort_direction]}") : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link = link_to title, params.merge(:sort => column, :direction => direction, :page => nil).reject { |k,v| k == "_" }
    link + icon
  end
      
end
