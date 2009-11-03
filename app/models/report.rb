class Report
  attr_accessor :loading_time_used, 
                :discharging_time_used, 
                :loading_time_available, 
                :discharging_time_available, 
                :loading_diff,
                :discharging_diff,
                :loading_amt,
                :discharging_amt,
                :cp_detail,
                :loading,
                :discharging,
                :loading_fact_report_list,
                :discharging_fact_report_list

  def balance_string
    if balance >= 0
      return "Balance Despatch"
    else
      return "Balance Demurrage"
    end
  end

  def balance
    (loading_amt + discharging_amt).abs
  end
end
