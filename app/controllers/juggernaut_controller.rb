class JuggernautController < ApplicationController
  
  protect_from_forgery :except => [:send_message]
  
  def index
  end
  
  def send_message
    message = {:sender => params[:sender], :message => params[:message]}.to_json
    render :juggernaut => {:type => :send_to_channel, :channel => 'test_channel'} do |page|
      page << 'parent.objj_msgSend(parent._appController, "renderNewMessage:", ' + message + ');'
    end
    render :nothing => :true
  end
  
  def send_color
    color = {:cssString => params[:color]}.to_json
    render :juggernaut => {:type => :send_to_channel, :channel => 'test_channel'} do |page|
      page << 'parent.objj_msgSend(parent._appController, "renderColor:", ' + color + ');'
    end
    render :nothing => :true
  end
end
