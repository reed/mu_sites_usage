class SitesController < ApplicationController
  def index
  end

  def show
    @department = Department.find(params[:department_id])
  end

end
