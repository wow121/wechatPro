task :rm_photo => :environment do
   WeixinHelper.mv_old_photo 
end
task :add_photo_log => :environment do
   WeixinHelper.add_photo_log 
end

task :check_error  => :environment do
	MerchantHelper.checkerror
end
