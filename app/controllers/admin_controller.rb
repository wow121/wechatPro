#encoding: utf-8
class AdminController < ApplicationController
   def upload
    if params[:pic] == nil
    flash[:notice] = "请选择照片" 
    redirect_to action 'manage_project'
    else
    file_name = "/home/weixin/user_name/" + params[:pic].original_filename
    File.open(file_name ,"wb+") do |f|
      f.write(params[:pic].read)
      flash[:notice] = "上传成功"
    redirect_to action 'manage_project'
    end
    end
   end

    def login
     ope_type = params[:operation]

     if params[:name].blank? or params[:password].blank?
       flash[:notice] = "用户名或密码为空!" 
       redirect_to :back 
       return  
     end
     
     @merchant = Merchant.where(user_name: params[:name]).where(password: params[:password]).first 

     if @merchant == nil
       flash[:notice] = "用户名或密码错误!" 
       redirect_to :back
       return
     else
      cookies[:merchant_id] = @merchant.user_name
     end
      if ope_type == "new_project"
         redirect_to action: 'new_project' 
      else
         redirect_to action: 'manage_project'
      end
   end

   def new_project
       Rails.logger.info "xxxxxxxxxxxxxxxx"
       Rails.logger.info cookies[:merchant_id]
 
       @current_user = Merchant.where(user_name: cookies[:merchant_id])
   end

   def manage_in
       cookies[:project_id] = params[:project_id]
       @current_user = Merchant.where(user_name: cookies[:merchant_id])
       @project = MerchantProject.where(id: params[:project_id]).first
       @project_code = @project.code
       @pictures = Photos.where(photo_id: @project_code)
       
       
   end

   def manage_project

     #  current_page = params[:current_page].to_i

       @current_user = Merchant.where(user_name: cookies[:merchant_id])
       @projects = MerchantProject.where(merchant_id: cookies[:merchant_id])
     #  @projects = MerchantProject.where(merchant_id: session[:merchant_id]).offset(10*(current_page-1)).limit(10)
     #  count = MerchantProject.where(merchant_id: session[:merchant_id]).size()
     #  min_page = 1
     #  max_page = (count + 10 - 1)/10
   end

   def delete_project
     id = params[:project_id]
     p = MerchantProject.find_by_id(id)
     p.delete
     flash[:notice] = "删除成功"
     redirect_to action: 'manage_project'
   end
   def delete_pic
       pic_id = params[:pic_id]
       p = Photos.find_by_id(pic_id)
       p.delete
      flash[:notice] = "该照片已删除"
      redirect_to action: 'manage_in?project_id=cookies[:project_id]'
   end

   def logout
     
     #merchant_id = session[:merchant_id]
     
     #@merchant = Merchant.find(merchant_id)
     
     session[:merchant_id] = nil
     render "index.html.erb"
   end

   def save
     Rails.logger.info "sssssssssssssssssssssss"
#     Rails.logger.info session[:merchant_id]
     Rails.logger.info cookies[:merchant_id]

      Rails.logger.info "xxxxxxxxxxxxxxxx"
      merchant_id = params[:current_name] 
#      Rails.logger.info merchant_id
#      session[:merchant_id] = merchant_id
      project_name = params[:project_name]
      short_name = params[:short_name]
      intro = params[:extra]
      
     if params[:project_name].blank? or params[:short_name].blank?
        flash[:alert] = "请填写项目信息"
        redirect_to action: 'new_project'
     else
      mp = MerchantProject.new
      mp.merchant_id = merchant_id
      mp.project_name = project_name
      mp.project_name_short = short_name
      mp.project_intro = intro
      mp.save
      flash[:notice] = "项目保存成功"
      redirect_to action: 'manage_project' 
      end
  end
end
