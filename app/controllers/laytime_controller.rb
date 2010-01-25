class LaytimeController < ApplicationController
  include TimeUtil
  include PdfUtil
  include LaytimeUtil

  before_filter :ensure_user_logged_in, :except => [:index]
  before_filter :check_free_trial_validity

  def index
    clear_session
    if current_user
      @cp_details = load_saved
    end
  end

  def ensure_user_logged_in
    unless current_user
      redirect_to login_path
      return
    end
  end

  def clear_session 
      session[:cp_detail] = nil
      session[:port_details] = nil
      session[:loading_facts] = nil
      session[:discharging_facts] = nil
      session[:additional_time] = nil
      session[:after_pre_advise] = nil
      session[:report] = nil
      session[:report_card] = nil
  end

  def generate
    unless session[:report]
      redirect_to root_url
      return
    end
    @report = session[:report]
    respond_to do |format|
      format.pdf {render :layout => false}
    end
  end

  def email_report
    # This involves saving the pdf to the file system
    # and then sending an email.
    unless session[:report]
      redirect_to root_url
      return
    end
    @report = session[:report]
    Prawn::Document.generate("testme.pdf") do |pdf|
      generate_pdf(pdf, @report)
    end

    begin 
    Notifier.deliver_pdf_report
      render :text => "The report has been emailed successfully"
    rescue
      render :text => "There was an error sending email. Please try again later"
    end
  end

  def load
    clear_session
    cp_detail = CpDetail.find(params[:id])

    if cp_detail.user_id != current_user.id
      redirect_to root_url
      return
    end
    session[:cp_detail] = cp_detail
    session[:port_details] = cp_detail.port_details
    session[:loading_facts] = cp_detail.port_details[0].facts
    session[:discharging_facts] = cp_detail.port_details[1].facts
    session[:report_card] = cp_detail.report_card
    redirect_to :action => 'cpdetails'
  end

  def generate_report(loading_facts, discharging_facts, loading_avail, discharging_avail, loading, discharging, cp_detail)
    #Calculate demurrage/despatch for loading
    #Calculate demurrage/despatch for discharging 
    #Sum up both
    #TODO Override the new method to do this?
    loading_time_used = TimeInfo.new
    loading_time_used.reset
    discharging_time_used = TimeInfo.new
    discharging_time_used.reset

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
    #  @loading_facts <<  Fact.new
      @loading_facts << Fact.new
      # Need this for addRow method
      session[:loading_facts] = @loading_facts
    end

    if session[:discharging_facts]
      @discharging_facts = session[:discharging_facts]
    else
      @discharging_facts = Array.new
    #  @discharging_facts <<  Fact.new
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
    
    if session[:report_card]
      @report_card = session[:report_card]
    else
      @report_card = ReportCard.new
    end
  end

  def result
    unless is_portdetails_valid
      redirect_to :action => 'portdetails'
      return
    end
    #save_to_db

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
    session[:report] = @report
    #TODO Uncomment this.
    #clear_session
    respond_to do |format|
      format.html
    end
  end

  def addRow
    session[:facts] << Fact.new
  end

  def save_time_info(port_id, info)
    info.port_detail_id = port_id
    info.save
  end

  def save_to_db
    # EDGE CONDITION support later
    # if user deleted a fact, don't let them save.
    if session[:port_details][0].id
      # This is an update
      loading_id = session[:port_details][0].id
      discharging_id = session[:port_details][1].id
      if Fact.find_all_by_port_detail_id(loading_id).length > session[:loading_facts].length
        flash[:notice] = "Looks like you deleted one or more loading fact. You can not save the new form if fact is deleted."
        redirect_to :action => 'result', :save_to_db_visited => 'true'
        return
      end
      if Fact.find_all_by_port_detail_id(discharging_id).length > session[:discharging_facts].length
        flash[:notice] = "Looks like you deleted one or more discharging fact. You can not save the new form if fact is deleted."
        params[:save_to_db_visited] = true
        redirect_to :action => 'result', :save_to_db_visited => 'true'
        return
      end
    end
    @cpdetail = session[:cp_detail]
      if @cpdetail.save
        @portdetail = session[:port_details][0]
        @portdetail.cp_detail_id = @cpdetail.id
        @portdetail.save
        session[:loading_facts].each do |fact|
          fact.port_detail_id = @portdetail.id
          fact.save
        end

#        save_time_info(@portdetail.id, session[:after_pre_advise][0])
#        save_time_info(@portdetail.id, session[:additional_time][0])

        @portdetail = session[:port_details][1]
        @portdetail.cp_detail_id = @cpdetail.id
        @portdetail.save
        session[:discharging_facts].each do |fact|
          fact.port_detail_id = @portdetail.id
          fact.save
        end
        report = session[:report]
        save_report_card(report.loading_time_used, 
                         report.loading_time_available, 
                         report.discharging_time_used, 
                         report.discharging_time_available, 
                         report.loading_amt, 
                         report.discharging_amt, 
                         @cpdetail.id)

#        save_time_info(@portdetail.id, session[:after_pre_advise][1])
#        save_time_info(@portdetail.id, session[:additional_time][1])
        flash[:notice] = "Your calculation has been successfull saved!"
      else
        flash[:warning] = "Something went wrong. Please try again."
        logger.error "Save failed"
      end
      @cp_details = CpDetail.all
  end

  private

  def save_report_card(loading_time_used,
                       loading_time_available,
                       discharging_time_used,
                       discharging_time_available,
                       loading_amount,
                       discharging_amount,
                       cp_detail_id)
    if(session[:report_card])
      report_card = session[:report_card]
      loading_time_used = TimeInfo.find_by_id(report_card.loading_used_id)
      discharging_time_used = TimeInfo.find_by_id(report_card.discharging_used_id)
      loading_time_available = TimeInfo.find_by_id(report_card.loading_avail_id)
      discharging_time_available = TimeInfo.find_by_id(report_card.discharging_avail_id)
    else
      report_card = ReportCard.new
    end
    report_card.cp_detail_id = cp_detail_id

    loading_time_used.time_info_type = TimeInfo::TIME_INFO_TYPE['Report']
    loading_time_used.save
    report_card.loading_used_id = loading_time_used.id

    loading_time_available.time_info_type = TimeInfo::TIME_INFO_TYPE['Report']
    loading_time_available.save
    report_card.loading_avail_id = loading_time_available.id

    discharging_time_used.time_info_type = TimeInfo::TIME_INFO_TYPE['Report']
    discharging_time_used.save
    report_card.discharging_used_id = discharging_time_used.id

    discharging_time_available.time_info_type = TimeInfo::TIME_INFO_TYPE['Report']
    discharging_time_available.save
    report_card.discharging_avail_id = discharging_time_available.id

    report_card.loading_amount = loading_amount
    report_card.discharging_amount = discharging_amount
    report_card.save
  end

  def is_cpdetails_valid
    if params[:cp_visited] || session[:cp_detail] == nil
      # session[:cp_detail] will be null when someone deeplinks into port details page without
      # previously filling cp details
      if params[:cp_detail]
        cp_detail = CpDetail.find_by_id(params[:cp_detail].delete(:id))
      end
      if cp_detail
        cp_detail.attributes = params[:cp_detail]
        session[:cp_detail] = cp_detail
      else
        session[:cp_detail] = CpDetail.new(params[:cp_detail])
      end
      session[:cp_detail].user_id = current_user.id
    end

    if session[:cp_detail].invalid?
      # redirect to cp detail page instead of back
      return false
    end
    
    return true
  end

  def is_portdetails_valid
    if params[:save_to_db_visited]
      # When redirected from save_to_db, don't worry about validation again.
      return true
    end

    if !params[:port_visited]
      return false
    end
    #unless(session[:port_details] && session[:port_details][0].errors && session[:port_details][1].errors && session[:port_details][0].errors.empty? && session[:port_details][1].errors.empty?)
    portdetails = Array.new
    port_detail = PortDetail.find_by_id(params['portdetail'][0].delete(:id))
    if port_detail
      port_detail.attributes = params['portdetail'][0]
    else
      port_detail = PortDetail.new(params['portdetail'][0])
    end

    port_detail.location = session[:cp_detail].from
    port_detail.calculation_type = params['calculation_type0']
    port_detail.calculation_time_saved = params['calculation_time_saved0']
    portdetails << port_detail
    
    port_detail = PortDetail.find_by_id(params['portdetail'][1].delete(:id))
    if port_detail
      port_detail.attributes = params['portdetail'][1]
    else
      port_detail = PortDetail.new(params['portdetail'][1])
    end

    port_detail.location = session[:cp_detail].to
    port_detail.calculation_type = params['calculation_type1']
    port_detail.calculation_time_saved = params['calculation_time_saved1']
    portdetails << port_detail
    session[:port_details] = portdetails
    port_validity0_invalid = session[:port_details][0].invalid?
    port_validity1_invalid = session[:port_details][1].invalid?

    # The reason I did it this way is because I want to call
    # invalid method on both objects. If I do an or directly,
    # if the first one satisfies, it wouldn't even go to the
    # second object's invalid method
    
    # Do Statement of Facts validation as well here because both of they
    # are in the same page.

    loading_facts_invalid = is_facts_invalid('loading')
    discharging_facts_invalid = is_facts_invalid('discharging')

#    add_allowance_invalid = is_time_info_invalid('add_allowance')
#    pre_advise_invalid = is_time_info_invalid('pre_advise')


    if port_validity0_invalid || port_validity1_invalid || loading_facts_invalid || discharging_facts_invalid
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
    # Read from params only if there is no error in the fact object already
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
      fact_obj = Fact.find_by_id(fact.delete(:id))
      if fact_obj
        fact_obj.attributes = fact
      else
        fact_obj = Fact.new(fact)
      end
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

  def build_fact(from, to, pct, remarks)
    Fact.new(:from => from, :to => to, :val => pct, :remarks => remarks)
  end

  def check_free_trial_validity
    if current_user && current_user.account.pricing_plan == "FREE" && current_user.account.created_at < Time.now - 7.days
      redirect_to :controller => 'payment', :action => 'index'
    end
  end

  def load_saved
    # Load all the ones created by all users of this account.
    users = User.find_all_by_account_id(current_user.account_id)
    CpDetail.find(:all, :conditions => ['user_id in (?)', users ])
  end
end
