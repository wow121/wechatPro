class User < ActiveRecord::Base
   attr_accessible :weixin_id,:password,:status,:photo_count
end
