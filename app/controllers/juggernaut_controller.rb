class JuggernautController < ApplicationController
  
  protect_from_forgery :except => [:send_message]
  
  def index
  end
  
  def send_message
    render :juggernaut => {:type => :send_to_channel, :channel => 'test_channel'} do |page|
      page << 'parent.objj_msgSend(parent._appController, "renderNewMessage:", ["' + params[:sender] + '", "' + params[:message] + '"]);'
    end
    render :nothing => :true
  end
  
  def send_color
    render :juggernaut => {:type => :send_to_channel, :channel => 'test_channel'} do |page|
      page << 'parent.objj_msgSend(parent._appController, "renderColor:", "' + params[:color] + '");'
    end
    render :nothing => :true
  end
end
