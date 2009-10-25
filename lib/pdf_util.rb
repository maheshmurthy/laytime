module PdfUtil
  include TimeUtil
  def create_pdf(name, report)
    Prawn::Document.generate(name) do |pdf|
      pdf.text "Laytime Calculation Report", :align => :center, :size => 16, :style => :bold

      pdf.move_down 20
      pdf.text "_____________________________________"
      pdf.text "<b>Vessel: </b>" + report.cp_detail.vessel
      pdf.move_down 10
      pdf.text "<b>Partner</b>: " + report.cp_detail.partner
      pdf.text "<b>From / To: </b>" + report.cp_detail.from + " / " + report.cp_detail.to
      pdf.text "<b>C/P</b>: " + report.cp_detail.cpName

      pdf.move_down 15
      pdf.text "<b>Loading at " + report.cp_detail.from + "</b>"
      pdf.move_down 10
      write_port_details(pdf, report.loading)

      pdf.move_down 15
      port_details = report.loading
      pdf.text " <b>From To % Remarks TimeUsed TotalTime </b>"
      write_fact_report(pdf, report.loading_fact_report_list)
      pdf.move_down 20
      write_summary(pdf, 
                    report.loading_time_available, 
                    report.loading_time_used,
                    report.loading_diff,
                    report.loading_amt)

      pdf.move_down 20
      pdf.text "<b>Discharging at " + report.cp_detail.to + "</b>"
      pdf.move_down 10
      write_port_details(pdf, report.discharging)
      pdf.move_down 15

      port_details = report.discharging
      pdf.text "<b> From To % Remarks TimeUsed TotalTime </b>"
      write_fact_report(pdf, report.discharging_fact_report_list)
      pdf.move_down 20
      write_summary(pdf, 
                    report.discharging_time_available, 
                    report.discharging_time_used,
                    report.discharging_diff,
                    report.discharging_amt)
    end
  end

  def write_summary(pdf, time_available, time_used, diff, amt)
      pdf.text "<b>Time Allowed</b> " + pretty_time_info(time_available)
      pdf.text "<b>Time Used</b> " + pad(time_used.hours) +  ":" + pad(time_used.mins)
      pdf.text "<b>Time saved</b> " + pretty_time_info(diff)
      pdf.text "<b>Despatch Due</b>" + amt.to_s
  end

  def write_fact_report(pdf, fact_report_list)
    fact_report_list.each do |f_list|
      f_list.each do |f|
        pdf.move_down 5
        pdf.text f.fact.from.to_s + " " + f.fact.to.to_s + " " + f.fact.val.to_s + " " + f.fact.remarks + " " + to_hr_min(f.time_used) + " " + f.running_total.to_s
        #
      end
    end
  end

  def write_port_details(pdf, port_details)
    pdf.text "<b>Cargo</b> " + port_details.quantity.to_s + " " + port_details.cargo + " " + port_details.description
    pdf.text "<b>Allowance</b> " + port_details.allowance.to_s + " " + port_details.allowanceType
    pdf.text "<b>Demurrage Rate</b> " + port_details.demurrage.to_s
    pdf.text "<b>Despatch Rate</b> " + port_details.despatch.to_s
  end
end
