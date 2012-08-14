class EpisodesController < ApplicationController
  before_filter :find_episode

  def show
  end

  def parse
    @episode.parse
    redirect_to episode_path @episode
  end

  def play
    s = @episode.playlist
    send_data(s, {:filename=>"#{@episode.title}.m3u", :disposition=>"attatchment"})
  end

  def download
    @episode.download
    redirect_to episode_path @episode
  end

  def destroy
  end

  protected
  def find_episode
    @episode = Episode.find(params[:id])
  end
end
