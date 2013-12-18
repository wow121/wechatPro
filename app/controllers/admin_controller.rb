#encoding: utf-8
class AdminController < ApplicationController
   before_filter :check_login, :except => [:index, :login]

   #管理员登陆
   def login
     ope_type = params[:operation]

     if params[:name].blank? or params[:password].blank?
       flash[:alert] = "用户名或密码为空!" 
       redirect_to :back 
       return  
     end
     
     @merchant = Merchant.where(user_name: params[:name]).where(password: params[:password]).first 
     
     if @merchant == nil
       flash[:alert] = "用户名或密码错误!" 
       redirect_to :back
       return
     else @is_admin = @merchant.admin
     end
      if @is_admin == 1
           
      cookies[:merchant_id] = @merchant.user_name
     else
     flash[:alert] = "非管理员不可登陆，请确认信息！"
     redirect_to :back
     return
     end
      if ope_type == "new_project"
         redirect_to action: 'new_project' 
      else
         redirect_to action: 'manage_project'
      end
   end

    #新建项目
   def new_project
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
    @merchants = Merchant.where(admin:0).offset(10*(@current_page-1)).limit(10)
   end

   #项目内部照片管理
   def manage
       cookies[:project_id] = params[:project_id]  
        redirect_to action: 'manage_in'    
   end

   def manage_in
       @current_user = Merchant.where(user_name: cookies[:merchant_id])
      @project = MerchantProject.where(id: cookies[:project_id])
      @pictures_code = @project.first.code
    
     count = Photos.where(photo_id: @pictures_code).size()
     @max_page = (count - 1)/3 + 1
     if params[:current_page].blank? or params[:current_page].to_i <= 0 or params[:current_page].to_i > @max_page

       @current_page = 1
      else
       @current_page = params[:current_page].to_i
      end
 @pictures = Photos.where(photo_id: @pictures_code).offset(3*(@current_page -1)).limit(3)
    end
 

   #管理项目
   def manage_project
      count = MerchantProject.where(merchant_id: cookies[:merchant_id]).size()

     @max_page = (count + 10 -1)/10

       if params[:current_page].blank? or params[:current_page].to_i <= 0 or params[:current_page].to_i > @max_page
       @current_page = 1
       else

       @current_page = params[:current_page].to_i
      end
   @projects = MerchantProject.where(merchant_id: cookies[:merchant_id]).offset(10*(@current_page  - 1)).limit(10)

      
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
     if params[:project_name].blank? or params[:short_name].blank?
        flash[:alert] = "请填写项目信息"
        redirect_to action: 'new_project'
     elsif params[:code].blank?
           flash[:alert] = "请先生成项目授权码"
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
      
      p = Photos.find_by_id(params[:pic_id])
      p.update_attributes( :description => params[:pic_info])
    redirect_to action: 'manage_in' 
  end

  
   #生成授权码
  def generate
   token = params[:userid]
   Rails.logger.info token
   @code = WeixinHelper.mkqrcode(token)["code"] 
#   res = RestClient.get "http://0.0.0.0:3000/merchant/mkqrcode.json?userid=#{token}"
   redirect_to  "/admin/new_project.html?code=#{@code}" 
   end 


  #上传照片
  def upload
     username = params[:userid]
     pic = params[:pic]
     code = params[:code]
    extra = params[:extra]
    i = Merchant.where(token: username).first
    if pic == nil
        flash[:alert] = "请选择照片"
    redirect_to :back
      
    else 
    photo_name = i.user_name+i.loc_name+Time.now.strftime("%Y%m%d")+"01"+WeixinProcesser.mkrandom(6).to_s+".jpg"
     File.open("/home/weixin/user_photos/"+photo_name,"wb+") do |f|
     f.write(pic.read)
        end
     system 'convert '+"/home/weixin/user_photos/"+photo_name+' -resize 30% '+"/home/weixin/user_photos_small/"+photo_name
        Photos.create({:merchant_id=>i.user_name,:file_path=>photo_name,:photo_id=>code,:upload_type=>"isdownload",:description=>extra})
    flash[:notice] = "上传成功"    
  redirect_to action: 'manage_in'
    end  
  end


   #下载报表
  def download
  @current_user = Merchant.where(user_name: cookies[:merchant_id])
   end


  def download_xls
      userid = params[:userid]
      st = 0
      et = 1386937448
  redirect_to  "http://115.29.36.94/merchant/getlog?userid=#{userid}&stime=#{st}&etime=#{et}"
   end

  #注册商户
  def register
      @current_user = Merchant.where(user_name: cookies[:merchant_id])
     
  end



  def register_merchant
      if params[:username].blank? or params[:password].blank? or params[:loc_code].blank?
    flash[:alert] = "信息太少，无法注册商户？_ ？"
    redirect_to :back
    else
      username = params[:username]
      store_name = params[:name_store]
      password = params[:password]
      repassword = params[:repassword]
     company_name = params[:name_company]
     loc_code = params[:loc_code]
       if password != repassword
          flash[:alert] = "密码不一致*_*!"
           redirect_to :back
       else
     m =Merchant.new()
     m.user_name = username
     m.password = password
     m.loc_name = loc_code
     m.corp_name = company_name
     m.office_name = store_name
     m.admin = 0
     m.token = WeixinProcesser.mkrandom(12)
     m.save
    flash[:notice] = "注册商户成功~——~"
     redirect_to action: 'manage_merchant'
    end
  end
  end

  
  #修改商户信息
  def reset_merchant
      @merchant = Merchant.where(id: cookies[:mer_id]).first
      if params[:username].blank? or params[:password].blank? or params[:loc_name].blank?
      flash[:alert] = "必填项不能为空，请填写相关信息·_·"
      redirect_to :back
      else
      @merchant.user_name = params[:username]
       @merchant.password = params[:password]
      @merchant.loc_name = params[:loc_name]
      @merchant.office_name = params[:office_name]
      @merchant.corp_name = params[:corp_name]
     
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
              flash[:alert] = "非法code|_|,请确认后重新输入"
              redirect_to :back
 	    else
               @pic.each do |p|
                  if p.upload_type == "wait_download"
                      flash[:notice] = "照片存在"
                      break
                      return
                  else 
                    next
                  end
               end
                flash[:alert] = "不存在照片"
                redirect_to :back
           end
        end
     end         
end
