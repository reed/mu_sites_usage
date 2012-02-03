class SitesController < ApplicationController
  def index
  end

  def show
    @department = Department.find(params[:department_id])
    @site = SiteDecorator.find(params[:id])
  end

end
