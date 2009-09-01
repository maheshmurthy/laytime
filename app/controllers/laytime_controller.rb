require 'factlist'

class LaytimeController < ApplicationController
  def cpdetails
    @cpdetail = session[:cp_detail] || CpDetail.new
  end

  def portdetails
    session[:cp_detail] = CpDetail.new(params[:cp_detail])
    if session[:port_details]
      @portdetails = session[:port_details]
    else
      @portdetails = Array.new
      @portdetails << PortDetail.new
      @portdetails << PortDetail.new
    end
  end

  def stfacts
    session[:port_details] = PortDetail.new(params[:port_details])
    if session[:facts]
      @facts = session[:facts]
    else
      @facts = Array.new
      @facts <<  Fact.new
      @facts << Fact.new
      session[:facts] = @facts
    end
  end

  def addRow
    session[:facts] << Fact.new
    redirect_to :back
  end

  def result
    session[:cp_detail] = nil
    session[:port_details] = nil
    session[:facts] = nil
  end
end
