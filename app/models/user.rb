class User < ActiveRecord::Base
  attr_accessible :email, :id, :name, :pass
end