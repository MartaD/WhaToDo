class User < ActiveRecord::Base
  has_many :tasks
  
  attr_accessible :email, :id, :name, :pass
end
