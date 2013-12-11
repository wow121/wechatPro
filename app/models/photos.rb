class Photos < ActiveRecord::Base
   attr_accessible :upload_type ,:user_id ,:merchant_id ,:photo_id,:file_path,:state,  :payment_id , :payment_email ,:paid_at,:weixin_image_path
end
