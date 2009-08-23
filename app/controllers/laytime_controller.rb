class LaytimeController < ApplicationController
  def cpdetails
    @cpdetail = session[:cp_detail] || CpDetail.new
  end

  def portdetails
    session[:cp_detail] = CpDetail.new(params[:cp_detail])
    @portdetail = session[:port_detail] || PortDetail.new
  end

  def stfacts
    session[:port_detail] = PortDetail.new(params[:port_detail])
    @fact = session[:fact] || Fact.new
  end

  def result
    session[:cp_detail] = nil
    session[:port_detail] = nil
    session[:fact] = nil
  end
end
