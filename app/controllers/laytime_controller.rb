class LaytimeController < ApplicationController
  def index
      session[:cp_detail] = nil
      session[:port_details] = nil
      session[:loading_facts] = nil
      session[:discharging_facts] = nil
      session[:loading] = nil
      session[:discharging] = nil
  end

  def cpdetails
    @cpdetail = session[:cp_detail] || CpDetail.new
  end

  def portdetails
    unless is_cpdetails_valid
      redirect_to :action => 'cpdetails'
      return
    end

    if session[:port_details]
      @portdetails = session[:port_details]
    else
      @portdetails = Array.new

      portdetail = PortDetail.new
      portdetail.operation = "loading"
      @portdetails << portdetail

      portdetail = PortDetail.new
      portdetail.operation = "discharging"
      @portdetails << portdetail

    end

    if session[:loading_facts]
      @loading_facts = session[:loading_facts]
    else
      @loading_facts = Array.new
      @loading_facts <<  Fact.new
      @loading_facts << Fact.new
      # Need this for addRow method
      session[:loading_facts] = @loading_facts
    end

    if session[:discharging_facts]
      @discharging_facts = session[:discharging_facts]
    else
      @discharging_facts = Array.new
      @discharging_facts <<  Fact.new
      @discharging_facts << Fact.new
      # Need this for addRow method
      session[:discharging_facts] = @discharging_facts
    end

  end

  def result
    unless is_portdetails_valid
      redirect_to :action => 'portdetails'
      return
    end
    save_to_db
  end

  def addRow
    session[:facts] << Fact.new
  end

  def save_to_db
    @cpdetail = session[:cp_detail]
      if @cpdetail.save
        logger.info "Saved!"
        logger.info @cpdetail.id
        @portdetail = session[:port_details][0]
        @portdetail.cp_detail_id = @cpdetail.id
        @portdetail.save
        session[:loading_facts].each do |fact|
          logger.info "***********************"
          fact.port_detail_id = @portdetail.id
          fact.inspect
          fact.save
          logger.info "***********************"
        end

        @portdetail = session[:port_details][1]
        @portdetail.cp_detail_id = @cpdetail.id
        @portdetail.save
        session[:discharging_facts].each do |fact|
          logger.info "***********************"
          fact.port_detail_id = @portdetail.id
          fact.inspect
          fact.save
          logger.info "***********************"
        end
      else
        logger.info "Failed to save!"
      end
    session[:cp_detail] = nil
    session[:port_details] = nil
    session[:loading_facts] = nil
    session[:discharging_facts] = nil
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
    port_validity0_invalid = session[:port_details][0].invalid?
    port_validity1_invalid = session[:port_details][1].invalid?

    # The reason I did it this way is because I want to call
    # invalid method on both objects. If I do an or directly,
    # if the first one satisfies, it wouldn't even go to the
    # second object's invalid method
    
    # Do Statement of Facts validation as well here because both of them
    # are in the same page.

    loading_facts_invalid = is_facts_invalid('loading')
    discharging_facts_invalid = is_facts_invalid('discharging')

    if port_validity0_invalid || port_validity1_invalid || loading_facts_invalid || discharging_facts_invalid
      return false
    end
    return true
  end

  def is_facts_invalid(operation)
    fact_list = Array.new
    params[operation].each do |fact|
      fact_obj = Fact.new(fact)
      logger.info fact_obj.inspect
      fact_list << fact_obj
    end
    
    is_invalid = false
    if(operation == 'loading')
      session[:loading_facts] = fact_list
      session[:loading_facts].each do |fact|
        is_invalid ||= fact.invalid?
      end
    else
      session[:discharging_facts] = fact_list
      session[:discharging_facts].each do |fact|
        is_invalid ||= fact.invalid?
      end
    end
    logger.info "Validity is " + is_invalid.to_s
    return is_invalid
  end
end
