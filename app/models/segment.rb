class Segment < ActiveRecord::Base
  attr_accessible :episode_id, :format_id, :number, :size, :status_id, :url

  validates :url, :presence => true
  validates_uniqueness_of :number, :scope=>:episode_id

  belongs_to :episode
  belongs_to :series
  belongs_to :status
  belongs_to :format

  def push_to_task_queue
    if self.status_id == Status.WAITING or self.status_id == Status.DOWNLOADING
      return
    end
    logger.debug "downloading push to task queue #{self.inspect}"
    self.update_column(:status_id, Status.WAITING)
    self.delay.download
  end

  def download
    if self.status_id == Status.UNSTARTED
      self.push_to_task_queue
      return
    end

    if self.status_id == Status.DOWNLOADING
      logger.warn "already downloading! segment: #{self.inspect}"
      return
    end

    if self.status_id == Status.ERROR
      self.push_to_task_queue
      return
    end

    if self.status_id == Status.FINISHED
      f = File.new self.filename
      f_size = f.lstat.size
      if self.size == f_size
      else
        logger.warn "file size does not match! segment: #{self.inspect}, size:#{f_size}"
        self.update_column(:status_id, Status.ERROR)
      end
      return
    end

    if self.status_id == Status.WAITING
      now = Time.now
      updated_at = self.updated_at.to_time
      #the url will be unvalid after an hour
      if now - updated_at > 3600
        logger.debug "need reparse! now: #{now.inspect}, updated_at: #{updated_at.inspect}"
        episode = Episode.find self.episode_id
        episode.parse
      end
    end

    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8) AppleWebKit/536.25 (KHTML, like Gecko) Version/6.0 Safari/536.25"
    c = Curl::Easy.new(self.url) do |curl|
      curl.on_header {self.download_start}
      curl.on_success {self.download_finish}
      curl.on_failure {self.downlaod_fail}
    end
    c.headers["User-Agent"] = user_agent
    c.follow_location = true
    c.perform
    open(self.filename, "wb") do |_f|
      _f.write(c.body_str)
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

end
