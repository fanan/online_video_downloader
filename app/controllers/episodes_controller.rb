class EpisodesController < ApplicationController
  before_filter :find_episode

  def show
  end

  def parse
    @episode.parse
    redirect_to episode_path @episode
  end

  def play
  end

  def download
  end

  def show
  end

  def destroy
  end

  protected
  def find_episode
    @episode = Episode.find(params[:id])
  end
end
