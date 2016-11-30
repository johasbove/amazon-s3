class Upload < ActiveRecord::Base
  require 'csv'
  require 'roo'
  require 'tempfile'

  has_many :routes

  validates :name, :url, presence: true

  accepts_nested_attributes_for :routes

  def self.process_file(url)
    region = 'us-east-1'
    bucket_name = 'test-llegando'
    file_name = url.split(".com/")[1]
    accessKeyId = 'AKIAIWUIOZVGMF37WACQ'
    secretAccessKey = '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'
    
    creds = Aws::Credentials.new(accessKeyId, secretAccessKey)
    s3 = Aws::S3::Client.new(region: region, credentials: creds)
    resp = s3.get_object(bucket: bucket_name, key: file_name)
    raw_file = resp.body #Es un StringIO
    
    file_extension = File.extname(url)

    upload = Upload.new(name: File.basename(url, ".*"), url: url)
    upload.transaction do
      
      if file_extension == ".csv"
        csv = CSV.parse(raw_file.string, :headers => true)
        csv.each do |row|
          assign_params(row)
          existent_route = Route.find_by_nid(@route_params[:nid])
          if existent_route
            route = existent_route
            upload.routes << route
          else
            route = upload.routes.build(@route_params)
          end
          route.stops.build(@stop_params)

          upload.save!
        end
      else
        raise "Unknown file type: #{file_extension}"
      end
    end
    upload
  end

  private

  def self.assign_params(row)
    @route_params = {nid: row[0], depot_at: row[1], depot: row[2] , action: row[3]}
    @stop_params = {nid: row[4], latitude: row[5], longitude: row[6], arrives_at: row[7], departs_at: row[8]}
  end
end
