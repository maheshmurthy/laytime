pdf.font "Helvetica"

@cpdetails.each do |cp_detail|
    pdf.text "Partner: #{cp_detail.partner}"
    pdf.text "Form: #{cp_detail.cpName}"
    pdf.text "Date: #{cp_detail.created_at}"
    pdf.text "From: #{cp_detail.from}"
    pdf.text "To: #{cp_detail.to}"
    pdf.text "Currency: #{cp_detail.currency}"
end
