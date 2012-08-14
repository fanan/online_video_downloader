require 'open-uri'
class Episode < ActiveRecord::Base
  attr_accessible :number, :series_id, :title, :url

  validates :url, :uniqueness => true
  belongs_to :series
  has_many :segments

  def parse
    #used to gather infomations
    #first, read the url, load into json
    #second, parse title
    #third, get segments again, check the segment status, if finished, leave alone, else, update segment url.
    #save the changes
    video_id = get_video_id(self.url)
    data = get_json(video_id)
    seed = data["seed"]
    logger.debug "seed = #{seed}"
    stream_file_ids = data["streamfileids"]
    title = data["title"].strip
    self.update_column(:title, title)
    #self.title = title
    #self.save
    if stream_file_ids.key? "hd2"
      file_ids = stream_file_ids["hd2"]
      video_type = "hd2"
    elsif stream_file_ids.key? "mp4"
      file_ids = stream_file_ids["mp4"]
      video_type = "mp4"
    else
      file_ids = stream_file_ids["flv"]
      video_type = "flv"
    end
    real_id = get_file_id(file_ids, seed)
    segs = data["segs"]
    n = segs[video_type].length
    folder_name = video_type == "mp4" ? "mp4" : "flv"
    format = video_type == "mp4" ? 2 : 1
    n.times do |i|
      url = "http://f.youku.com/player/getFlvPath/sid/00_00/st/#{folder_name}/fileid/#{real_id[0..7]}#{get_hex_number(i)}#{real_id[10..-1]}?K=#{segs[video_type][i]["k"]},k2=#{segs[video_type][i]["k2"]}"
      size = segs[video_type][i]["size"].to_i
      new_segment = Segment.new(:episode_id=>self.id, :number=>i, :url=>url, :size=>size, :format_id=>format)
      unless new_segment.save
        #segment = Segment.where(:episode_id=>self.id, :number=>i)
        segment = Segment.find_by_episode_id_and_number(self.id, i)
        logger.debug "before update: #{segment.inspect}, #{segment.class}"
        segment.update_column(:url, url)
        logger.debug "after update: #{segment.inspect}"
      end
    end
    logger.debug self.segments.inspect
  end
  

  def download
    #parse then download
    segments = Segment.find_all_by_episode_id(self.id)
    if segments.empty?
      self.parse
      segments = Segment.find_all_by_episode_id(self.id)
    end
    segments.each do |segment|
      segment.push_to_task_queue
    end
  end

  def playlist
    segments = Segment.find_all_by_episode_id(self.id)
    s = ""
    segments.each do |segment|
      s << "#{segment.filename}\n"
    end
    return s
  end

  protected
  @@base_uri = "http://v.youku.com/player/getPlayList/VideoIDS/"

  def get_video_id(video_url)
    r = video_url.match(/id_([^\.]+)\.html/)
    video_id = r.captures.length > 0 ? r.captures[0] : nil
    return video_id
  end

  def get_key(key1, key2)
    #this method is deprecated
    key = key1.to_i(16)
    key ^= 0xA55AA5A5
    return key2 + key.to_s(16)
  end

  def get_json(id)
    s = open(@@base_uri + id).read
    data = JSON.parse(s)["data"][0]
    return data
  end

  def get_mixed_string(seed)
    seed = seed.to_i
    source = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\\:._-1234567890"
    mixed = ""
    l = source.length
    l.times do
      seed = (seed * 211 + 30031) % 65536
      index = (seed.to_f / 65536 * source.length).to_i
      c = source[index]
      mixed << c
      source.delete! c
    end
    return mixed
  end

  def get_file_id(file_ids, seed)
    mixed = get_mixed_string(seed)
    #puts file_ids
    real_id = ""
    file_ids.scan(/\d+/).each do |i|
      real_id << mixed[i.to_i]
    end
    return real_id
  end

  def get_hex_number(n, base=16)
    s = n.to_s(base)
    s = "0#{s}" if s.length == 1
    return s.upcase
  end


end
