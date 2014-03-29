class User < ActiveRecord::Base
   attr_accessible :subscribe,:openid,:nickname,:sex,:language,:city,:province,:country,:headimgurl,:subscribe_time
end
