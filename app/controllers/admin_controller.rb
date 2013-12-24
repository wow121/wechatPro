#encoding: utf-8
class AdminController < ApplicationController
   before_filter :check_login, :except => [:index, :login,:find_pic,:register,:register_merchant]

   #管理员登陆
   def login
     ope_type = params[:operation]

     if params[:name].blank? or params[:password].blank?
       flash[:alert] = "用户名或密码为空!" 
       redirect_to :back 
       return  
     end
     pwd = Digest::MD5.hexdigest(params[:password])     
 @merchant = Merchant.where(user_name: params[:name]).where(password: pwd).first 
     
     if @merchant == nil
       flash[:alert] = "用户名或密码错误!" 
       redirect_to :back
       return
      end 
      if @merchant.admin == -1
         flash[:alert] = "商户不能登录，我也无能为力| 、|"
       redirect_to :back
        return
      end
       cookies[:admin] = @merchant.admin
      
      cookies[:merchant_id] = @merchant.user_name
             
      if ope_type == "new_project"
         redirect_to action: 'new_project' 
      else
         redirect_to action: 'manage_project'
      end
   end

    #新建项目
   def new_project
       @is_admin = cookies[:admin]
      Rails.logger.info @is_admin
      @pro_name =cookies[:pro_name]
      @short_name = cookies[:short_name]
      @intro = cookies[:intro]
      
       @code =  params[:code] 
       @current_user = Merchant.where(user_name: cookies[:merchant_id])
   end


   #管理商户
   def manage_merchant
      
       @current_user = Merchant.where(user_name: cookies[:merchant_id])
       count = Merchant.where(admin:0).size
       @max_page = (count + 9)/10
       if params[:current_page].blank? or params[:current_page].to_i <= 0 or params[:current_page].to_i > @max_page
        @current_page = 1 
      else 
      @current_page = params[:current_page].to_i
      end
    @merchants = Merchant.where("admin != ? ",1).offset(10*(@current_page-1)).limit(10).order("created_at desc")
    
   end

   #项目内部照片管理
   def manage
         
       cookies[:project_id] = params[:project_id]  
        redirect_to action: 'manage_in'    
   end

   def manage_in
        @is_admin = cookies[:admin]
       @current_user = Merchant.where(user_name: cookies[:merchant_id])
      @project = MerchantProject.where(id: cookies[:project_id])
      @pictures_code = @project.first.code
    
     count = Photos.where(photo_id: @pictures_code).size()
     @max_page = (count - 1)/5 + 1
     if params[:current_page].blank? or params[:current_page].to_i <= 0 or params[:current_page].to_i > @max_page

       @current_page = 1
      else
       @current_page = params[:current_page].to_i
      end
 @pictures = Photos.where(photo_id: @pictures_code).offset(5*(@current_page -1)).limit(5).order("created_at desc")
    end
 

   #管理项目
   def manage_project
          @is_admin = cookies[:admin]
      count = MerchantProject.where(merchant_id: cookies[:merchant_id]).size()

     @max_page = (count + 10 -1)/10

       if params[:current_page].blank? or params[:current_page].to_i <= 0 or params[:current_page].to_i > @max_page
       @current_page = 1
       else

       @current_page = params[:current_page].to_i
      end
   @projects = MerchantProject.where(merchant_id: cookies[:merchant_id]).offset(10*(@current_page  - 1)).limit(10).order("created_at desc")

      
       @current_user = Merchant.where(user_name: cookies[:merchant_id])
   end
   

   #删除项目
   def delete_project
     @id = params[:project_id]
     p = MerchantProject.find_by_id(@id)
     p.delete
     flash[:notice] = "删除成功"
     redirect_to action: 'manage_project'
   end

   
    # 删除照片
   def delete_pic
       pic_id = params[:pic_id]
       p = Photos.find_by_id(pic_id)
       p.delete
      flash[:notice] = "该照片已删除"   
      redirect_to action: 'manage_in'
   end


   #退出登录
   def logout
     cookies[:merchant_id] = nil
     render "index.html.erb"
   end


   #保存新建的项目
   def save
      merchant_id = cookies[:merchant_id] 
      project_name = params[:project_name]
      short_name = params[:short_name]
      intro = params[:extra]
      code = params[:code]
      cookies[:pro_name] = project_name
      cookies[:short_name] = short_name
      cookies[:intro] = intro
     if params[:project_name].blank? or params[:short_name].blank?
        flash[:alert] = "请填写项目信息"
        redirect_to action: 'new_project'
     elsif params[:short_name].size > 4
       flash[:alert] = "项目简称不能超过四个字 ；_ ；"
       cookies[:short_name] = nil
       redirect_to :back
     elsif params[:code].blank?
           flash[:alert ] = "请先生成项目授权码"
       redirect_to action: 'new_project'
     else
      mp = MerchantProject.new
      mp.merchant_id = merchant_id
      mp.project_name = project_name
      mp.project_name_short = short_name
      mp.project_intro = intro
      mp.code = code
      mp.save
      flash[:notice] = "项目保存成功"
      redirect_to action: 'manage_project' 
      end
  end


  #修改照片描述信息
  def change_info 
    @id = params[:pic_id] 
     
     Rails.logger.info"touteng"
     Rails.logger.info params[:pic_id]
     Rails.logger.info params[@id]
     p = Photos.where(id: params[:pic_id]).first
     p.update_attributes(:description => params[@id])
     flash[:notice] = "修改成功"
      redirect_to action: 'manage_in' 
  end

  
   #生成授权码
  def generate
   token = params[:userid]
   Rails.logger.info token
   @code = WeixinHelper.mkqrcode(token)["code"] 
   redirect_to  "/admin/new_project.html?code=#{@code}" 
   end 


  #上传照片
  def upload
     username = params[:userid]
     pic = params[:pic]
     code = params[:code]
    extra = params[:extra]
     title = params[:title]
    i = Merchant.where(token: username).first
    if pic == nil
        flash[:alert] = "请选择照片"
    redirect_to :back
    
      
    else 
    photo_name = i.user_name+i.loc_name+Time.now.strftime("%Y%m%d")+"01"+WeixinProcesser.mkrandom(6).to_s+".jpg"
    photo_name_small = photo_name[0,photo_name.length-4]+"_small.jpg"

     File.open("/home/weixin/user_photos/"+photo_name,"wb+") do |f|
     f.write(pic.read)
        end
     system 'convert '+"/home/weixin/user_photos/"+photo_name+' -resize 30% '+"/home/weixin/user_photos/"+photo_name_small
        Photos.create({:merchant_id=>i.user_name,:file_path=>photo_name,:photo_id=>code,:upload_type=>"1",:description=>extra,:title=>title})
    flash[:notice] = "上传成功"    
  redirect_to action: 'manage_in'
    end  
  end


   #下载报表
  def download
  @current_user = Merchant.where(user_name: cookies[:merchant_id])
  @link = params[:link]
   end


  def download_xls
      userid = params[:userid]
      st = params[:status]
      case st
          when "projectlist"
               status = "projectlist"
          when "weixinuserlist"
               status = "weixinuserlist"
          when "merchantlist"
               status = "merchantlist"
          when "photolist"
               status = "photolist"
       end
        if params[:merchantname].blank?
       
        else
          status = params[:merchantname] 
        end
      if params[:begin_year].blank? or params[:end_year].blank?
      st = 0 
      et = Time.now.to_i
      @link_download = MerchantHelper.getlog(userid,status,st,et)["url"]
        flash[:notice] = "时间填写不全，默认下载全部，点击下方链接下载^+^"
       encode_link = URI.encode(@link_download)
       redirect_to  "/admin/download.html?link=#{encode_link}" 
      else
        byear = params[:begin_year].to_i
        bmonth = params[:begin_month].to_i
        bday = params[:begin_day].to_i
        eyear = params[:end_year].to_i
        emonth = params[:end_month].to_i
        eday = params[:end_day].to_i
        st =Time.local(byear,bmonth,bday).to_i
        et = Time.local(eyear,emonth,eday).to_i
       if st >= et
         flash[:alert] = "起始时间超过终止时间|_|"
         redirect_to :back
       else
         @link_download = MerchantHelper.getlog(userid,status,st,et)["url"]
         flash[:notice] = "请点击下方下载，若未开始下载，可能这段时间段无照片，请重试，或重新填写时间段"
         encode_link = URI.encode(@link_download)
         redirect_to  "/admin/download.html?link=#{encode_link}"
       end
      end
   end

  #注册商户
  
 def register_merchant
  if params[:username].blank? or params[:password].blank? 
		flash[:alert] = "信息太少，无法注册商户？_ ？"
		redirect_to :back
       else
		username = params[:username]
		password = params[:password]
		password_md5 = Digest::MD5.hexdigest(password)
		repassword = params[:repassword]
		BackendLog.log "password"+password
		BackendLog.log "repassword"+repassword
		if password == repassword
			m =Merchant.new()
			m.user_name = username
			m.password = password_md5
			m.admin = 0
			m.token = WeixinProcesser.mkrandom(12)
			m.save
			flash[:notice] = "注册成功,开始登陆吧~——~"
			redirect_to "/admin/index.html"
		else
			flash[:alert] = "密码不一致*_*!"
			redirect_to :back
		end
      end
  end

  
  #修改商户信息
  def reset_merchant
   
      @merchant = Merchant.where(id: cookies[:mer_id]).first
      if params[:username].blank? or params[:loc_name].blank?
      flash[:alert] = "必填项不能为空，请填写相关信息·_·"
      redirect_to :back
      else
      @merchant.update_attributes(:user_name => params[:username])
      @merchant.update_attributes(:loc_name => params[:loc_name])
      @merchant.update_attributes(:office_name => params[:office_name])
      @merchant.update_attributes(:corp_name => params[:corp_name])
     
     flash[:notice] = "商户已修改，请查看~……~"
      redirect_to action: 'manage_merchant'
      
      end 
  end
 
 
 #修改商户
 def change_merchant
     @current_user = Merchant.where(user_name: cookies[:merchant_id])
     cookies[:mer_id] = params[:mer_id]
     @merchants = Merchant.where(id:params[:mer_id])
     
 
 end


  #删除商户
  def delete_merchant
     merchant = Merchant.where(id: params[:mer_id]).first
     merchant.delete
     flash[:notice] = "已删除该商户，若后悔请重新注册^_^"
    redirect_to :back
  end

 #查询照片
   def find_pic
       if params[:code].blank?
             flash[:alert] = "请输入code查询!"
             redirect_to :back
       else
          @pic =Photos.where(photo_id: params[:code])
              @pic_first = @pic.first
            if @pic.first == nil
              flash[:alert] = "不存在照片|_|,请确认后重新输入"
              redirect_to :back
 	    else
              flash[:notice] = "照片存在"
              redirect_to :back
           end
        end
    
 end

 #重置密码
 def resetpassword
     
     @merchant =Merchant.where(id: params[:mer_id])
     @current_user = Merchant.where(user_name: cookies[:merchant_id])
 end


 def reset
   if params[:password].blank? or params[:repassword].blank?
      flash[:alert] = "两次密码不一致，请重新输入‘——‘"
      redirect_to :back
   else 
   password = params[:password]  
   password_md5 =Digest::MD5.hexdigest(password)
   m = Merchant.where(id: params[:mer_id]).first
   m.update_attributes(:password => password_md5)
   flash[:notice] = "重置成功"
   redirect_to action: 'manage_merchant'
   
   end





 end

end
