class StopsController < ApplicationController

  def index
    @page_header = "Stops' List"
    @stops = Stop.page(params[:page]).per(5)
  end

  private

  def upload_params
    params.require(:upload).permit(:name, :url)
  end
end
