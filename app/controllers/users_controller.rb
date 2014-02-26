class UsersController < ApplicationController
   def test
    render:json=>{"xxx"=>"z123"}
     
   end

   

   def find
      Rails.logger.info "xxxxxxxxxxxxxxxxxxxxxxxxxx"
      Rails.logger.info params[:id]

      u = User.find(params[:id].to_i)
      render :json => {"u" => u}
   end

   def test1
      @u = User.find(params[:id].to_i)
      @test = params[:test]

      Rails.logger.info @u.to_json
   end

end
