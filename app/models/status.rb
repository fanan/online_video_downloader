class Status < ActiveRecord::Base
  attr_accessible :name

  def self.UNSTARTED
    1
  end

  def self.WAITING
    2
  end

  def self.DOWNLOADING
    3
  end

  def self.ERROR
    4
  end
  
  def self.FINISHED
    5
  end

end
