class Segment < ActiveRecord::Base
  attr_accessible :episode_id, :format_id, :number, :size, :status_id, :url

  validates :url, :presence => true
  validates_uniqueness_of :number, :scope=>:episode_id

  belongs_to :episode
  belongs_to :series
  belongs_to :status
  belongs_to :format

  def download
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8) AppleWebKit/536.25 (KHTML, like Gecko) Version/6.0 Safari/536.25"
    c = Curl::Easy.new(self.url) do |curl|
      curl.on_header {self.download_start}
      curl.on_success {self.download_finish}
      curl.on_failure {self.downlaod_fail}
    end
    c.headers["User-Agent"] = user_agent
    c.follow_location = true
    c.perform
    open(self.filename, "wb") do |f|
      f.write(c.body_str)
    end
    c.close
  end

  def filename
    episode = Episode.find(self.episode_id)
    series = Series.find(episode.series_id)
    _filename = "#{episode.title}_#{number}.#{self.format.name}"
    return File.join(series.path, _filename)
  end

  protected
  def download_start
    logger.debug "downloading start #{self.inspect}"
    self.update_column(:status_id, Status.DOWNLOADING)
  end

  def download_finish
    logger.debug "downloading finish #{self.inspect}"
    self.update_column(:status_id, Status.FINISHED)
  end

  def downlaod_fail
    logger.debug "downloading fail #{self.inspect}"
    self.update_column(:status_id, Status.ERROR)
end
