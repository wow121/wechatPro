class Merchant < ActiveRecord::Base
   attr_accessible :user_name,:password,:corp_name,:loc_name,:office_name,:token
end
