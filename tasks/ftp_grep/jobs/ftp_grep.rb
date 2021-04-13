require 'net/ftp'
require 'csv'
require 'fileutils'

class FtpGrepJob < Job
  def initialize config
    @config = config
  end

  def options
    @config
  end

  def perform
    copy_files_to_tmp(options)
    matching_files = run_grep(options)
    move_matched_delete_others(options, matching_files)
  end
  def copy_files_to_tmp(options, attempts = 1)


    unless File.directory?( options["temp_folder"] )
      FileUtils.mkdir_p( options["temp_folder"] )
    end

    excluded_file_types = [".pdf",".jpg",".tiff",".tif",".jpeg",".png", ".zip"]

    folder_listings = []
    while folder_listings.length < options["ftp_server_count"] do
      Net::FTP.open(options["host"], options["user"], options["password"]) do |ftp|

        listing = ftp.nlst(options["check_folder"])

        unless folder_listings.include?( listing )

          folder_listings << listing
          files = ftp.nlst(options["search_folder"])

          p "FTP location contents: " + files.to_s if options["debug"]

          files.each do |file|

            ext = File.extname file

            unless excluded_file_types.include? ext.downcase
              p "Downloading: " + file
              ftp.get( file, options["temp_folder"] + File.basename(file))
            end
          end
        end
      end
    end

  rescue SocketError

    p "Connection error, attempt " + attempts.to_s

    if attempts < 5 then copy_files_to_tmp(options, (attempts + 1).to_s) end

  end

  def run_grep(options)

    matching_files = []

    Dir.foreach( options["temp_folder"] ) do |file|

      if file != "." && file != ".." then

        file_path = File.join(options["temp_folder"],file)

        unless File.open(file_path).grep(options["search_pattern"]).empty?
          p "Match in " + options["output_folder"] + file
          matching_files << file_path
        end
      end
    end

    return matching_files

  end

  def move_matched_delete_others(options, matching_files)

    Dir.foreach( options["temp_folder"] ) do |file|

      file_path = File.join(options["temp_folder"],file)

      if matching_files.include? file_path then

        File.rename file_path, File.join(options["output_folder"],file)

      else
        begin
          File.delete(file_path)
        rescue Errno::EISDIR
          #Trying to delete a directory and failing as it should, do nothing.
        end
      end
    end
  end
end