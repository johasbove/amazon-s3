class UploadsController < ApplicationController

  def index
    @page_header = "Files' List"
    @uploads = Upload.page(params[:page]).per(5)
  end

  def new
  end

  def create
    @upload = Upload.process_file(params[:url])
    @url = "/uploads/#{@upload.id}"

    respond_to :json
  end

  def show
    @page_header = "File Especifications"
    @upload = Upload.find(params[:id])
  end

  private

  def upload_params
    params.require(:upload).permit(:name, :url)
  end
end
