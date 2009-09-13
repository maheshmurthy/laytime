class LaytimeController < ApplicationController
  def cpdetails
    @cpdetail = session[:cp_detail] || CpDetail.new
  end

  def portdetails
    unless is_cpdetails_valid
      redirect_to :action => 'cpdetails'
      return
    end

    if session[:port_details]
    # XXX Fix this block
      @portdetails = session[:port_details]
      logger.info @portdetails[0].errors.inspect
      @portdetail = @portdetails[0]
    else
      @portdetails = Array.new

      portdetail = PortDetail.new
      portdetail.operation = "loading"
      @portdetails << portdetail

      portdetail = PortDetail.new
      portdetail.operation = "discharging"
      @portdetails << portdetail

      logger.info "***********************"
      logger.info @portdetails[0].operation
      logger.info @portdetails[1].operation
      logger.info "***********************"
    end
  end

  def stfacts
    unless is_portdetails_valid
      redirect_to :action => 'portdetails'
      return
    end

    if session[:facts]
      @facts = session[:facts]
    else
      @facts = Array.new
      @facts <<  Fact.new
      @facts << Fact.new
      # Need this for addRow method
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
      end
    session[:cp_detail] = nil
    session[:port_details] = nil
    session[:facts] = nil
  end

  private 

  def is_cpdetails_valid
    unless(session[:cp_detail] && session[:cp_detail].errors && session[:cp_detail].errors.empty?)
      # Take it from params if there is nothing in session 
      # or there are errors in session
      session[:cp_detail] = CpDetail.new(params[:cp_detail])
    end

    if session[:cp_detail].invalid?
      # redirect to cp detail page instead of back
      logger.info "Redirecting to cpdetail"
      return false
    end
    
    return true
  end

  def is_portdetails_valid
    unless(session[:port_details] && session[:port_details][0].errors && session[:port_details][1].errors && session[:port_details][0].errors.empty? && session[:port_details][1].errors.empty?)
      portdetails = Array.new
      port_detail = PortDetail.new(params['portdetail'][0])
      port_detail.calculation_type = params['calculation_type0']
      port_detail.calculation_time_saved = params['calculation_time_saved0']
      portdetails << port_detail

      port_detail = PortDetail.new(params['portdetail'][1])
      port_detail.calculation_type = params['calculation_type1']
      port_detail.calculation_time_saved = params['calculation_time_saved1']
      portdetails << port_detail
      session[:port_details] = portdetails
    end
    validity0 = session[:port_details][0].invalid?
    validity1 = session[:port_details][1].invalid?

    # The reason I did it this way is because I want to call
    # invalid method on both objects. If I do an or directly,
    # if the first one satisfies, it wouldn't even go to the
    # second object's invalid method
    if validity0 || validity1
      return false
    end
    #if session[:port_details][0].invalid?
    #  return false
    #end
    #if session[:port_details][1].invalid?
    #  return false
    #end
    return true
  end
end
