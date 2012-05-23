class Task < ActiveRecord::Base
  belongs_to :user
  
  attr_accessible :duration, :name, :user_id
end
