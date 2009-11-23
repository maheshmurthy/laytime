module LaytimeUtil
  def demurrage_despatch(available, used, despatch, demurrage)
    diff_days = (available.diff(used)).to_days
    if(available.greater_than(used))
      # despatch calculation
      return ((despatch * diff_days * 10**2).round.to_f)/(10**2)
    else
      # demurrage calculation
      return ((-demurrage * diff_days * 10**2).round.to_f)/(10**2)
    end
  end

  def calculate_available_time(unit, quantity, allowance_type, allowance)
    #For now this is super simple. Figure out if unit and allowance type can be 
    #different? IF so, calculation becomes much more complicated.
    total = quantity/allowance
    mins = (total * 60 * 24).round
    info = to_time_info(mins)
  end

  def build_fact_report_list(facts)
    fact_report_list = Array.new
    running_total = 0
    facts.each do |fact|
      fact.merge_fact_date
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
end
