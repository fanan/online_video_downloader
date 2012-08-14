require 'open-uri'
class Series < ActiveRecord::Base
  attr_accessible :path, :title, :url
  has_many :episodes
  has_many :segments, :through => :episodes
  
  #validates :title, :presence => true
  validates :url, :presence => true, :uniqueness => true, :format => {:with => /^http:\/\/(www|v)\.youku\.com\//, :message => "We only support youku now, more sites will be added later!"}

  #before_create :unify_url

  def parse
    #This method will get the episodes list of the series.
    #If the list has already exists, it will update.
    #The job of get the episode title will be put into the queue
    doc = Nokogiri::HTML(open self.url)
    doc.css('div#episode ul>li>a').each do |anchor|
      ep = Episode.new(:url=>anchor.attribute('href').value, :title=>anchor.attribute('title').value)
      if ep.save
        self.episodes << ep
      end
    end
    logger.debug "episodes: #{self.episodes.inspect}"
  end

  def download
    episodes = Episode.find_all_by_series_id(self.id)
    logger.debug "=====================episodes: #{episodes.inspect}"
    #Episode.find_by_series_id(self.id).each do |episode|
    episodes.each do |episode|
      episode.download
    end
  end

  def play
    s = ""
    Episode.find_by_series_id(self.id).each do |episode|
      s << episode.playlist
    end
    return s
  end

  #protected
  def unify_url
    #support YOUKU only
    #Check whether the url is "http://www.youku.com/show_page..." or not
    #If url matches "http://v.youku.com/..."
    #try to get the standard url

    self.url.strip!
    p = Regexp.new('^http:\/\/v\.youku')
    if self.url.match p
      doc = Nokogiri::HTML(open self.url)
      temp = doc.css('div#vpofficialinfo_wrap li.show_title>a')
      #logger.debug "doc selects #{temp.inspect}"
      if temp.length != 1
        logger.warn "series #{self.url} error: cannot standardize"
      else
        self.url = temp[0].attribute('href').value
      end
    end
    
    doc = Nokogiri::HTML(open self.url)
    temp = doc.css('div#title')
    logger.debug "div#title #{temp.inspect}"
    if temp.length == 1
      self.title = temp[0].inner_text.gsub(/(\n|\t)/,'')
    end

    if !self.save
      logger.warn "series #{self.url} save error: #{self.errors.inspect}"
    end
  end

end
