class User < ActiveRecord::Base
   attr_accessible :weixin_id,:password,:status,:photo_count

   def self.abc
      Rails.logger.info "=================abc=============="
      BackendLog.log "=================abc=============="
   end
end
