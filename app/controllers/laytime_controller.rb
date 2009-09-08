
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
  end

  def result
    @cpdetail = session[:cp_detail]
      if @cpdetail.save
        logger.info "Saved!"
      else
        logger.info "Failed to save!"
        logger.info @cpdetail.vessel
      end
    session[:cp_detail] = nil
    session[:port_details] = nil
    session[:facts] = nil
  end
end
