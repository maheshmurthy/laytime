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

  def load
    clear_session
    session[:cp_detail] = CpDetail.find(81)
    session[:port_details] = PortDetail.find(:all, :conditions => {:cp_detail_id => 81})
    session[:loading_facts] = Fact.find(:all, :conditions => {:port_detail_id => 31})
    session[:discharging_facts] = Fact.find(:all, :conditions => {:port_detail_id => 32})

    info = Array.new
    info << TimeInfo.find(:all, :conditions => {:port_detail_id => 31, :time_info_type => 'add_allowance'})
    info << TimeInfo.find(:all, :conditions => {:port_detail_id => 32, :time_info_type => 'add_allowance'})
    session[:additional_time] = info.flatten


    info = Array.new
    info << TimeInfo.find(:all, :conditions => {:port_detail_id => 31, :time_info_type => 'pre_advise'})
    info << TimeInfo.find(:all, :conditions => {:port_detail_id => 32, :time_info_type => 'pre_advise'})
    session[:after_pre_advise] = info.flatten

    redirect_to :action => 'cpdetails'
  end

  def generate_report(loading_facts, discharging_facts, additional_time, loading_demurrage, loading_despatch, discharging_demurrage, discharging_despatch)
    #Calculate demurrage/despatch for loading
    #Calculate demurrage/despatch for discharging 
    #Sum up both
    loading_time_used = TimeInfo.new
    reset_time_info(loading_time_used)
    discharging_time_used = TimeInfo.new
    reset_time_info(discharging_time_used)

    report = Report.new
    report.loading_time_used = loading_time_used
    report.discharging_time_used = discharging_time_used

    loading_facts.each do |fact|
      add_time_used(fact.from.to_datetime, fact.to.to_datetime, fact.val, loading_time_used)
    end

    discharging_facts.each do |fact|
      add_time_used(fact.from.to_datetime, fact.to.to_datetime, fact.val, discharging_time_used)
    end

    report.loading_time_available, report.discharging_time_available = additional_time

    return report
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
    @report = generate_report(session[:loading_facts], 
                              session[:discharging_facts], 
                              session[:additional_time],
                              session[:port_details][0].demurrage,
                              session[:port_details][0].despatch,
                              session[:port_details][1].demurrage,
                              session[:port_details][1].despatch)
                              
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
          fact.save
        end

        save_time_info(@portdetail.id, session[:after_pre_advise][0])
        save_time_info(@portdetail.id, session[:additional_time][0])

        @portdetail = session[:port_details][1]
        @portdetail.cp_detail_id = @cpdetail.id
        @portdetail.save
        session[:discharging_facts].each do |fact|
          fact.port_detail_id = @portdetail.id
          fact.save
        end

        save_time_info(@portdetail.id, session[:after_pre_advise][1])
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
      port_detail.location = session[:cp_detail].from
      port_detail.calculation_type = params['calculation_type0']
      port_detail.calculation_time_saved = params['calculation_time_saved0']
      portdetails << port_detail

      port_detail = PortDetail.new(params['portdetail'][1])
      port_detail.location = session[:cp_detail].to
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

  def build_time_info(time_infos, time_info_type)
    is_invalid = false

    time_infos.each do |time_info|
      # User does not fill they type which is why is done below.
      time_info.time_info_type = time_info_type
      # If there are any errors, info object will have errors field set
      is_invalid ||= time_info.invalid?
    end
      return is_invalid
  end

  def is_time_info_invalid(time_info_type)
    is_invalid = false

    if(time_info_type == 'add_allowance')
      unless(session[:additional_time] && session[:additional_time][0].errors.empty? && session[:additional_time][1].errors.empty?)
        session[:additional_time] = Array.new
        params[time_info_type].each do |info|
          session[:additional_time] << TimeInfo.new(info)
        end
        #session[:additional_time] = time_info_list
      end
      is_invalid = build_time_info(session[:additional_time], 'add_allowance')
    else
      unless(session[:after_pre_advise] && session[:after_pre_advise][0].errors.empty? && session[:after_pre_advise][1].errors.empty?)
        session[:after_pre_advise] = Array.new
        params[time_info_type].each do |info|
          session[:after_pre_advise]  << TimeInfo.new(info)
        end
      end
      is_invalid = build_time_info(session[:after_pre_advise], 'pre_advise')
    end
    return is_invalid
  end

  def read_from_params(facts)
    read_from_params = false
    if(facts)
      facts.each do |fact|
        read_from_params ||= !fact.errors.empty?
      end
    else
      read_from_params = true
    end
    return read_from_params
  end

  def is_facts_invalid(operation)

    fact_list = Array.new
    params[operation].each do |fact|
      fact_obj = Fact.new(fact)
      fact_list << fact_obj
    end
    
    is_invalid = false
    if(operation == 'loading')
      if(read_from_params(session[:loading_facts]))
        session[:loading_facts] = fact_list
      end
      session[:loading_facts].each do |fact|
        is_invalid ||= fact.invalid?
      end
    else
      if(read_from_params(session[:discharging_facts]))
        session[:discharging_facts] = fact_list
      end
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

  def add_time_used(from, to, pct, time_used)
    days = ((to - from)).to_i
    hours =((to - from) * 24).to_i % 24
    mins =((to - from) * 24 * 60).to_i % 60
    total_count_in_mins = ((days*24*60 + hours*60 + mins) * (pct/100)).to_i
    total_count_in_mins_accounted = ((time_used.days*24*60 + time_used.hours*60 + time_used.mins)).to_i
    total_count_in_mins += total_count_in_mins_accounted

    time_used.mins = total_count_in_mins % 60
    rem_hours = (total_count_in_mins/60).to_i
    time_used.hours = rem_hours % 24
    time_used.days = (rem_hours/24).to_i
  end
end
