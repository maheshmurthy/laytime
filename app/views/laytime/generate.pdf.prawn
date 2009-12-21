def write_summary(pdf, time_available, time_used, diff, amt)
  pdf.text "<b>Time Allowed</b> " + time_available.to_s
  pdf.text "<b>Time Used</b> " + pad(time_used.hours) +  ":" + pad(time_used.mins)
  if time_available.greater_than(time_used)
    pdf.text "<b>Time saved</b> " + diff.to_s
  else
    pdf.text "<b>Time Lost</b> " + diff.to_s
  end
  if amt > 0
    pdf.text "<b>Despatch Due</b> " + amt.to_s
  else
    pdf.text "<b>Demurrage Due</b> " + amt.abs.to_s
  end
end

def write_fact_report(pdf, fact_report_list)
  table = Array.new
  fact_report_list.each do |f_list|
    f_list.each do |f|
      row = Array.new
      row << f.fact.from_string
      row << f.fact.to_string
      row << f.fact.val.to_s
      row << f.fact.remarks
      row << to_hr_min(f.time_used)
      row << f.running_total.to_s
      table << row
    end
  end
  pdf.table table, :font_size          => 10,
                   :vertical_padding   => 2,
                   :horizontal_padding => 5,
                   :position           => :center,
                   :row_colors         => :pdf_writer,
                   :headers            => ["From","To","%", "Remarks","Time Used","Total Time"]
  end

def write_port_details(pdf, port_details)
  pdf.text "<b>Cargo</b> " + port_details.quantity.to_s + " " + port_details.cargo + " " + port_details.description
  pdf.text "<b>Allowance</b> " + port_details.allowance.to_s + " " + port_details.allowanceType
  pdf.text "<b>Demurrage Rate</b> " + port_details.demurrage.to_s
  pdf.text "<b>Despatch Rate</b> " + port_details.despatch.to_s
end

pdf.text "Laytime Calculation report", :align => :center, :size => 16, :style => :bold

pdf.move_down 20
pdf.text "<b>Vessel: </b>" + @report.cp_detail.vessel
pdf.move_down 10
pdf.text "<b>Partner</b>: " + @report.cp_detail.partner
pdf.text "<b>From / To: </b>" + @report.cp_detail.from + " / " + @report.cp_detail.to
pdf.text "<b>C/P</b>: " + @report.cp_detail.cpName
pdf.move_down 5
pdf.stroke_horizontal_line 0, 500

pdf.move_down 15
pdf.text "<b>Loading at " + @report.cp_detail.from + "</b>"
pdf.move_down 10
write_port_details(pdf, @report.loading)

pdf.move_down 15
port_details = @report.loading
write_fact_report(pdf, @report.loading_fact_report_list)
pdf.move_down 20
write_summary(pdf, 
            @report.loading_time_available, 
            @report.loading_time_used,
            @report.loading_diff,
            @report.loading_amt)

pdf.start_new_page

pdf.text "<b>Discharging at " + @report.cp_detail.to + "</b>"
pdf.move_down 10
write_port_details(pdf, @report.discharging)
pdf.move_down 15


port_details = @report.discharging
write_fact_report(pdf, @report.discharging_fact_report_list)
pdf.move_down 20
write_summary(pdf, 
            @report.discharging_time_available, 
            @report.discharging_time_used,
            @report.discharging_diff,
            @report.discharging_amt)
pdf.move_down 30
pdf.text @report.balance_string + " " + @report.balance.to_s
