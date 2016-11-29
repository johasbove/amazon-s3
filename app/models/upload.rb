class Upload < ActiveRecord::Base
  require 'csv'
  # require 'open-uri'
  require 'rest-client'
  require 'roo'

  has_many :routes

  validates :name, :url, presence: true

  def self.process_file(url)
    Upload.transaction do
      # open(url) do |file|
      #   puts "file #{file}"
      # end
      # Me dio error de autenticacion
      # # file_contents = open(url) { |f| f.read }
      # # puts "file_contents #{file_contents}"

      # file_otro = File.read(url)
      # puts "file_otro #{file_otro}"

      # private_resource = RestClient::Resource.new url, 'AKIAIWUIOZVGMF37WACQ', 'YCQsNq96CHYZIPW/7//KT32MjKhpvm9Q9GYWW5PQ'
      # private_resource.get

      # file_name = url.split(".com/")[1]
      # a = RestClient::Request.execute(method: :get, url: "http://s3.amazonaws.com/test-llegando/#{file_name}")
      # RestClient::Request.execute(method: :get, url: url, headers: {params: {'accessKeyId': 'AKIAIWUIOZVGMF37WACQ', 'secretAccessKey': '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'}})
      # accessKeyId = 'AKIAIWUIOZVGMF37WACQ'
      # secretAccessKey = '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'
      # a = RestClient::Request.execute(method: :get, url: url, headers: {params: {'Authorization': "AWS {#{accessKeyId}}:'.amazon_hmac(secretAccessKey)'"}})
      raw_file = RestClient::Request.execute(method: :get, url: url)
      puts " RESPUESTA: #{raw_file}"

      # Buehhhh, como no pude hacer que el archivo se guardara publico.... supongo que "raw_file" es tal que puedo hacer (sino otra 
        # opcion seria usar StringIO como abajo :/ ):
      file_extension = File.extname(raw_file.original_filename)
      if file_extension == ".csv"
        csv_text = File.read(raw_file)
        csv = CSV.parse(csv_text, :headers => true)
        csv.each do |row|
          assign_params(row)
          route = Route.new(@route_params)
          route.transaction do
            route.upload = self
            route.stops.build(@stop_params)
            route = route.save!
          end
        end
      elsif file_extension == ".xls"
        xls = Roo::Spreadsheet.open(raw_file)
        xls_arr = []
        2.upto(xls.last_row) do |index|
          xls_arr << xls.row(index)
          assign_params(xls_arr)
          route = Route.new(@route_params)
          route.transaction do
            route.upload = self
            route.stops.build(@stop_params)
            route = route.save!
          end
          xls_arr = []
        end
      else
        raise "Unknown file type: #{file.original_filename}"
      end

      # StringIO.open(url) do |data|
      #    puts "data.string #{data.string}"
      #    # data.class.class_eval { attr_accessor :original_filename, :content_type }
      #    # data.original_filename = original_filename
      #    # data.content_type = content_type
      #    # self.file = data
      #    puts "otro_mas #{data}"
      #  end

      upload = Upload.create!(name: raw_file.original_filename, url: url)
    end
    upload
  end

  def assign_params(arr)
    @route_params = {nid: arr[0], depot_at: arr[1], depot: arr[2] , action: arr[3]}
    @stop_params = {nid: arr[4], latitude: arr[5], longitude: arr[6], arrives_at: arr[7], departs_at: arr[8]}
  end
end
