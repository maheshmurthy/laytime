class LaytimeController < ApplicationController
  include TimeUtil
  include PdfUtil
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

  def generate_pdf
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

  def generate_report(loading_facts, discharging_facts, loading_avail, discharging_avail, loading, discharging, cp_detail)
    #Calculate demurrage/despatch for loading
    #Calculate demurrage/despatch for discharging 
    #Sum up both
    #TODO Override the new method to do this?
    loading_time_used = TimeInfo.new
    reset_time_info(loading_time_used)
    discharging_time_used = TimeInfo.new
    reset_time_info(discharging_time_used)

    loading_fact_report_list = build_fact_report_list(loading_facts)
    discharging_fact_report_list = build_fact_report_list(discharging_facts)

    # This is asking for trouble
    report_list = loading_fact_report_list[loading_fact_report_list.length - 1]
    loading_time_used = report_list[report_list.length - 1].running_total

    report_list = discharging_fact_report_list[discharging_fact_report_list.length - 1]
    discharging_time_used = report_list[report_list.length - 1].running_total

    report = Report.new
    report.loading_time_available = loading_avail
    report.discharging_time_available = discharging_avail
    report.loading_diff = loading_avail.diff(loading_time_used)
    report.discharging_diff = discharging_avail.diff(discharging_time_used)

    report.loading_time_used = loading_time_used
    report.discharging_time_used = discharging_time_used

    report.loading_amt = demurrage_despatch(report.loading_time_available, loading_time_used, loading.despatch, loading.demurrage)
    report.discharging_amt = demurrage_despatch(report.discharging_time_available, discharging_time_used, discharging.despatch, discharging.demurrage)

    report.cp_detail = cp_detail
    report.loading = loading
    report.discharging = discharging

    report.loading_fact_report_list = loading_fact_report_list
    report.discharging_fact_report_list = discharging_fact_report_list

    create_pdf("report.pdf", report)
    return report
  end

  def demurrage_despatch(available, used, despatch, demurrage)
    diff_days = (available.diff(used)).to_days
    if(available.greater_than(used))
      # despatch calculation
      return ((despatch * diff_days * 10**2).round.to_f)/(10**2)
    else
      # demurrage calculation
      return ((demurrage * diff_days * 10**2).round.to_f)/(10**2)
    end
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

    # Do whatever calculations you need to do and then send only those to generate report
    # which are required for display
    
    port = session[:port_details][0]
    loading_avail = calculate_available_time(port.cargo, port.quantity, port.allowanceType, port.allowance)
    port = session[:port_details][1]
    discharging_avail = calculate_available_time(port.cargo, port.quantity, port.allowanceType, port.allowance)

    @report = generate_report(session[:loading_facts],
                              session[:discharging_facts], 
                              loading_avail,
                              discharging_avail,
                              session[:port_details][0],
                              session[:port_details][1],
                              session[:cp_detail])
    #TODO Uncomment this.
    session[:report] = @report
    #clear_session
  end

  def calculate_available_time(unit, quantity, allowance_type, allowance)
    #For now this is super simple. Figure out if unit and allowance type can be 
    #different? IF so, calculation becomes much more complicated.
    total = quantity/allowance
    mins = (total * 24 * 60).to_i
    info = to_time_info(mins)
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

  def build_fact_report_list(facts)
    fact_report_list = Array.new
    running_total = 0
    facts.each do |fact|
      fact_reports = build_fact_report(fact.from.to_datetime, fact.to.to_datetime, fact.val, fact.remarks, running_total)
      running_total = fact_reports[fact_reports.length - 1].running_total.to_mins
      fact_report_list << fact_reports
    end
    return fact_report_list
  end

  def build_fact_report(from, to, pct, remarks, running_total)
    pct_val = (pct/100).to_i
    fact_report_list = Array.new
    fact_report = FactReport.new
    total_mins =((to - from) * 24 * 60).to_i
    if(total_mins < 1440) 
      fact_report.fact = build_fact(from, to, pct, remarks)
      fact_report.time_used = total_mins
      running_total = (total_mins * pct_val) + running_total
      fact_report.running_total = to_time_info(running_total)
      # Fill in other things
      fact_report_list << fact_report
      return fact_report_list
    end
    # Spans over multiple days
    end_of_day = DateTime.new(from.year, from.month, from.day, 24, 0, 0)
    mins_to_end_of_day = ((end_of_day - from) * 24 * 60).to_i
    running_total += (mins_to_end_of_day * pct_val)
    fact_report.fact = build_fact(from, end_of_day, pct, remarks)
    fact_report.time_used = mins_to_end_of_day
    fact_report.running_total = to_time_info(running_total)
    # Fill in other things
    fact_report_list << fact_report
    total_mins -= mins_to_end_of_day

    while total_mins > 1440 do
      running_total += (1440*pct_val)
      fact_report = FactReport.new
      fact_report.fact = build_fact(end_of_day, end_of_day + 1, pct, remarks)
      fact_report.time_used = 1440
      fact_report.running_total = to_time_info(running_total)
      end_of_day += 1
      # Fill in other things
      fact_report_list << fact_report
      total_mins -= 1440
    end

    fact_report = FactReport.new
    fact_report.fact = build_fact(end_of_day, to, pct, remarks)
    fact_report.time_used = ((to - end_of_day) * 24 * 60).to_i
    running_total += (fact_report.time_used * pct_val)
    fact_report.running_total = to_time_info(running_total)
    # Fill in other things
    fact_report_list << fact_report
    return fact_report_list
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

  def build_fact(from, to, pct, remarks)
    return Fact.new(:from => from, :to => to, :val => pct, :remarks => remarks)
  end
end
