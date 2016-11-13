require 'nokogiri'
require 'open-uri'
require 'fileutils'

class FourChan
  BASE_URL = "http://boards.4chan.org"
  SFW_BOARDS = ["x"]
  NSFW_BOARDS = ["b", "pol", "soc", "s4s", "a"]
  BASE_PATH = "assets"

  class NotUserImageException < StandardError; end
  class ExtensionNotSupportedException < StandardError; end

  def initialize
    @image_names = []
    @load_index = -1

    @save_lock = Mutex.new
    @load_lock = Mutex.new

    10.times { Thread.new { download_random_image } }
  end

  def random_image_path(sfw)
    @sfw = sfw

    Thread.new { download_random_image }

    image_name = @load_lock.synchronize do
      index = [@load_index + 1, @image_names.count].min
      image_name = @image_names.at(index)
      @load_index = index
      image_name
    end

    "assets/#{image_name}"
  end

  def release_asset(path)
    name = path.split("/").last

    @save_lock.synchronize do
      index = @image_names.index(name)
      @image_names.slice!(index)
    end

    FileUtils.rm_rf(path)
  end

  def clean_up
    @save_lock.synchronize do
      @image_names.each do |name|
        FileUtils.rm_rf("assets/#{name}")
      end

      @image_names.clear
    end
  end

  private

  def download_random_image
    image_url = random_image_url
    image_name = image_url.split("/").last
    extension = image_name.split(".").last

    @save_lock.synchronize do
      @image_names << image_name
      image_name
    end

    open("assets/#{image_name}", 'wb') do |file|
      file << open("http://#{image_url}").read
    end
  end

  def random_page_url
    boards = SFW_BOARDS
    boards += NSFW_BOARDS unless @sfw
    board = boards.sample
    page = Random.rand(10)

    url = "#{BASE_URL}/#{board}/#{page}"
  end

  def random_image_url
    html = Nokogiri::HTML(open(random_page_url))
    images = html.css("img")
    count = images.count
    image_url = images.at(Random.rand(count)).attributes["src"].value

    raise NotUserImageException unless image_url.include?("//i.4cdn.org")

    extension = image_url.split(".").last

    raise ExtensionNotSupportedException unless ["jpg", "png"].include?(extension)

    image_url.gsub!("//i.4cdn.org", "i.4cdn.org")
  rescue NotUserImageException, ExtensionNotSupportedException
    retries ||= 0

    retry if (retries += 1) < 10

    return nil
  end
end
