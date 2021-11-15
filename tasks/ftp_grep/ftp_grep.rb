require 'csv'

class FtpGrep < Task
  def initialize args
    @options = {}
    @options["user"] = args[:user]
    @options["host"] = 'ftp.teamwilberforce.com'
    @options["ftp_server_count"] = 2
    @options["check_folder"] = '/success/2021-11-30'
    @options["ftp_credentials_path"] = 'input/ftp_grep/FTP Credentials.csv'
    @options["temp_folder"] = '/tmp/ftp-grep/'
    @options["output_folder"] = 'output/ftp_grep/'
    if @options["user"].nil?
      raise "User not set"
    end

    CSV.foreach(@options["ftp_credentials_path"]) do |row|

      if row[0] == @options["user"] then
        @options["password"] = row[1]
      end

    end

    @options["search_pattern"] = /#{Regexp.new(args[:pattern])}/
    puts @options["search_pattern"]
    raise "Need to specify text to search" if @options["search_pattern"].nil?
    @options["search_folder"] = args[:folder]
    raise "Need to specify folder to search" if @options["search_folder"].nil?
  end

  def run
    FtpGrepJob.perform_now @options
  end

  private
  attr :consignment_numbers
end
