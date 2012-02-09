class LogsController < ApplicationController
  load_and_authorize_resource
  def index
    @title = "Device Logs"
    @logs = LogDecorator.decorate(Log.includes(:client => :site).page(params[:page]))
  end

end
