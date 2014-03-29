class UserActivityLog < ActiveRecord::Base
   attr_accessible :open_id, :event,:content
end
