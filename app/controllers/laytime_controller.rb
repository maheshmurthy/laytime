class LaytimeController < ApplicationController
  def index
    clear_session
  end

  def clear_session 
      session[:cp_detail] = nil
      session[:port_details] = nil
      session[:loading_facts] = nil
      session[:discharging_facts] = nil
      session[:additional_time] = nil
      session[:after_pre_advise] = nil
  end

  def generate
    @cpdetails = CpDetail.find(:all)
    respond_to do |format|
      format.pdf {render :layout => false}
    end
  end

  def generate_report
    #Calculate demurrage/despatch for loading
    #Calculate demurrage/despatch for discharging 
    #Sum up both
    loading_time_used = TimeInfo.new
    reset_time_info(loading_time_used)
    discharging_time_used = TimeInfo.new
    reset_time_info(discharging_time_used)
    session[:loading_facts].each do |fact|
      add_time_used(fact, loading_time_used)
    end

    session[:discharging_facts].each do |fact|
      add_time_used(fact, discharging_time_used)
    end

    logger.info "****************************"
    logger.info loading_time_used.days
    logger.info loading_time_used.hours
    logger.info loading_time_used.mins
    logger.info "****************************"
    logger.info discharging_time_used.days
    logger.info discharging_time_used.hours
    logger.info discharging_time_used.mins
    logger.info "****************************"
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
      portdetail.location = session[:cp_detail].from
      @portdetails << portdetail

      portdetail = PortDetail.new
      portdetail.operation = "discharging"
      portdetail.location = session[:cp_detail].to
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
    
    if session[:additional_time]
      @additional_time = session[:additional_time]
    else
      @additional_time = Array.new
      @additional_time << TimeInfo.new
      @additional_time << TimeInfo.new
    end

    if session[:after_pre_advise]
      @after_pre_advise = session[:after_pre_advise]
    else
      @after_pre_advise = Array.new
      @after_pre_advise << TimeInfo.new
      @after_pre_advise << TimeInfo.new
    end
  end

  def result
    unless is_portdetails_valid
      redirect_to :action => 'portdetails'
      return
    end
    save_to_db
    generate_report
    clear_session
  end

  def addRow
    session[:facts] << Fact.new
  end

  def save_time_info(port_id, info)
    info.port_detail_id = port_id
    info.save
  end

  def save_to_db
    @cpdetail = session[:cp_detail]
      if @cpdetail.save
        logger.info "Saved!"
        @portdetail = session[:port_details][0]
        @portdetail.cp_detail_id = @cpdetail.id
        @portdetail.save
        session[:loading_facts].each do |fact|
          fact.port_detail_id = @portdetail.id
          fact.inspect
          fact.save
        end

        save_time_info(@portdetail.id, session[:pre_advise_invalid][0])
        save_time_info(@portdetail.id, session[:additional_time][0])

        @portdetail = session[:port_details][1]
        @portdetail.cp_detail_id = @cpdetail.id
        @portdetail.save
        session[:discharging_facts].each do |fact|
          fact.port_detail_id = @portdetail.id
          fact.inspect
          fact.save
        end

        save_time_info(@portdetail.id, session[:pre_advise_invalid][1])
        save_time_info(@portdetail.id, session[:additional_time][1])
      else
        logger.info "Failed to save!"
      end
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

    add_allowance_invalid = is_time_info_invalid('add_allowance')
    pre_advise_invalid = is_time_info_invalid('pre_advise')

    if port_validity0_invalid || port_validity1_invalid || loading_facts_invalid || discharging_facts_invalid || add_allowance_invalid || pre_advise_invalid
      return false
    end
    return true
  end

  def is_time_info_invalid(time_info_type)
    time_info_list = Array.new
    params[time_info_type].each do |time_info|
      info = TimeInfo.new(time_info)
      # If there are any errors, info object will have errors field set
      info.invalid?
      time_info_list << info
    end

    if(time_info_type == 'add_allowance')
      session[:additional_time] = time_info_list
    else
      session[:after_pre_advise] = time_info_list
    end
  end

  def is_facts_invalid(operation)
    fact_list = Array.new
    params[operation].each do |fact|
      fact_obj = Fact.new(fact)
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
    return is_invalid
  end

  def reset_time_info(time_info)
    time_info.days= 0
    time_info.hours = 0
    time_info.mins = 0
  end

  def add_time_used(fact, time_used)
    pct = fact.val
    days = fact.to.day - fact.from.day
    hours = fact.to.hour = fact.from.hour
    mins = fact.to.min - fact.from.min
    total_count_in_mins = ((days*24*60 + hours*60 + mins) * (pct/100)).to_i
    time_used.mins += total_count_in_mins % 60
    rem_hours = (total_count_in_mins/60).to_i
    time_used.hours += rem_hours % 24
    time_used.days += (rem_hours/24).to_i
  end


end
