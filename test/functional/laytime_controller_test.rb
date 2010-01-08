require 'test_helper'

class LaytimeControllerTest < ActionController::TestCase

  fixtures :all
  setup do
    user = Factory.create(:user)
    UserSession.create(user)
  end

  test "any action if not logged in should redirect to login page" do
    UserSession.find.destroy
    post :portdetails
    assert_redirected_to login_path
  end

  test "redirect to payment page if free trial has expired" do
    account = UserSession.find.user.account
    account.created_at = Time.now - 8.days
    account.save!
    post :portdetails
    assert_redirected_to :controller => "payment", :action => "index"
  end

  test "cp detail not filled" do
    post :portdetails
    assert_equal "can't be blank", session[:cp_detail].errors["vessel"]
    assert_redirected_to :action => "cpdetails"
  end

  test "cp detail validation" do
    cp_detail = build_cp_details
    post(:portdetails,{:cp_detail => cp_detail})
    assert_response :success
    assert_equal "Banpu", session[:cp_detail].partner
    assert_equal "coal mining corp", session[:cp_detail].cpName
    assert_equal 1234, session[:cp_detail].number
    assert_equal "Medi Dublin", session[:cp_detail].vessel
    assert_equal "Jorong", session[:cp_detail].from
    assert_equal "Cochin", session[:cp_detail].to
    assert_equal "USD", session[:cp_detail].currency
    assert_equal "A", session[:cp_detail].ports_to_calculate
    assert_equal "Always", session[:cp_detail].once_on_demurrage
  end

  test "port detail validation" do
    loading_port_detail = build_loading_port

    discharging_port_detail =  build_discharging_port

    loading_facts = build_loading_facts

    discharging_facts = build_discharging_facts 

    pre_advise = [{"mins"=>"0", "days"=>"0", "hours"=>"0"}, {"mins"=>"0", "days"=>"0", "hours"=>"0"}]

    add_allowance = [{"mins"=>"0", "days"=>"5", "hours"=>"12"}, {"mins"=>"0", "days"=>"5", "hours"=>"12"}]

    port_details = Array.new
    port_details << loading_port_detail
    port_details << discharging_port_detail
    cp_detail = CpDetail.new(build_cp_details)
    post(:result, {:portdetail => port_details, 
                   :calculation_type0 => "normal", 
                   :calculation_type1 =>"normal",
                   :calculation_time_saved0 =>"working",
                   :calculation_time_saved1 =>"working",
                   :loading => loading_facts,
                   :discharging => discharging_facts,
                   :pre_advise => pre_advise,
                   :add_allowance => add_allowance,
                   :port_visited => "true"
                   }, {:cp_detail => cp_detail, :user_credentials => session['user_credentials'], :user_credentials_id => session['user_credentials_id']})

    assert_response :success
  end

  test "validate values in the report" do
    loading_facts = Array.new
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from_date"=>"04.06.09", "from_time" => "21:12", "to_date"=>"08.06.09", "to_time" => "10:45")
    loading_facts << fact
    fact = Fact.new("timeToCount"=>"Rain", "remarks"=>"", "val"=>"0", "from_date"=>"08.06.09", "from_time" => "10:45", "to_date"=>"08.06.09", "to_time" => "12:25")
    loading_facts << fact
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from_date"=>"08.06.09", "from_time" => "12:25", "to_date"=>"09.06.09", "to_time" => "00:00")
    loading_facts << fact
    fact = Fact.new("timeToCount"=>"Not to Count", "remarks"=>"", "val"=>"0", "from_date"=>"09.06.09", "from_time" => "00:00", "to_date"=>"09.06.09", "to_time" => "00:30")
    loading_facts << fact
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from_date"=>"09.06.09", "from_time" => "00:30", "to_date"=>"09.06.09", "to_time" => "04:30")
    loading_facts << fact

    discharging_facts = Array.new
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from_date"=>"14.06.09", "from_time" => "01:30", "to_date"=>"15.06.09", "to_time" => "17:30")
    discharging_facts << fact
    fact = Fact.new("timeToCount"=>"Rain", "remarks"=>"", "val"=>"0", "from_date"=>"15.06.09", "from_time" => "17:30", "to_date"=>"15.06.09", "to_time" => "18:30")
    discharging_facts << fact
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from_date"=>"15.06.09", "from_time" => "18:30", "to_date"=>"17.06.09", "to_time" => "04:00")
    discharging_facts << fact

    loading_avail = TimeInfo.new("hours" => 12, "days" => 3, "mins" => 10, "type" => "add_allowance")
    discharging_avail = TimeInfo.new("hours" => 12, "days" => 3, "mins" => 10, "type" => "add_allowance")

    loading_port_detail = PortDetail.new(build_loading_port)

    discharging_port_detail = PortDetail.new(build_discharging_port)

    cp_detail = CpDetail.new(build_cp_details)

 
    report = @controller.generate_report(loading_facts, discharging_facts, loading_avail, discharging_avail, loading_port_detail, discharging_port_detail, cp_detail)
    assert_equal 4, report.loading_time_used.days
    assert_equal 5, report.loading_time_used.hours
    assert_equal 8, report.loading_time_used.mins

    assert_equal 0, report.loading_diff.days
    assert_equal 16, report.loading_diff.hours
    assert_equal 58, report.loading_diff.mins

    assert_equal 3, report.discharging_time_used.days
    assert_equal 1, report.discharging_time_used.hours
    assert_equal 30,report.discharging_time_used.mins

    assert_equal 0, report.discharging_diff.days
    assert_equal 10, report.discharging_diff.hours
    assert_equal 40, report.discharging_diff.mins
  end

  test "available calculation time" do
    info = @controller.calculate_available_time('mts', 55000.0, 'mts/day', 10000.0)
    assert_equal 5, info.days
    assert_equal 12, info.hours
    assert_equal 0, info.mins
  end

  test "demurrage despatch calculation" do
    available = TimeInfo.new("hours" => 12, "days" => 5, "mins" => 0, "type" => "add_allowance")
    used = TimeInfo.new("hours" => 5, "days" => 4, "mins" => 8, "type" => "add_allowance")
    amount = @controller.demurrage_despatch(available, used, 25000.0, 50000.0)
    assert_equal amount, 32152.78 
  end

  test "fact report is built correctly" do
    from = DateTime.new(2009, 9, 5, 22, 0, 0)
    to = DateTime.new(2009, 9, 7, 11, 0, 0)
    fact_report_list = @controller.build_fact_report(from, to, 100.0, 'Full/Normal', 0)
    assert_equal 3, fact_report_list.length

    date1 = DateTime.new(2009, 9, 6, 0, 0)
    date2 = DateTime.new(2009, 9, 7, 0, 0)

    fact_report = fact_report_list[0]
    assert_equal fact_report.fact.from, from
    assert_equal fact_report.fact.to, date1
    assert_equal 120, fact_report.time_used

    time_info = TimeInfo.new(:days => 0, :hours => 2, :mins => 0)
    assert_equal time_info.attributes, fact_report.running_total.attributes

    fact_report = fact_report_list[1]
    assert_equal fact_report.fact.from, date1
    assert_equal fact_report.fact.to, date2
    assert_equal 1440, fact_report.time_used

    time_info = TimeInfo.new(:days => 1, :hours => 2, :mins => 0)
    assert_equal time_info.attributes, fact_report.running_total.attributes

    fact_report = fact_report_list[2]
    assert_equal fact_report.fact.from, date2
    assert_equal fact_report.fact.to, to
    assert_equal 660, fact_report.time_used

    time_info = TimeInfo.new(:days => 1, :hours => 13, :mins => 0)
    assert_equal time_info.attributes, fact_report.running_total.attributes

    fact_report_list.each do |fact_report|
      assert_equal 'Full/Normal', fact_report.fact.remarks
      assert_equal 100.0, fact_report.fact.val
    end

  end

  test "fact report for within a day" do
    from = DateTime.new(2009, 9, 5, 21, 0, 0)
    to = DateTime.new(2009, 9, 5, 23, 59, 0)
    fact_report_list = @controller.build_fact_report(from, to, 0.0, 'Rain', 0)
    assert_equal 1, fact_report_list.length

    fact_report = fact_report_list[0]
    assert_equal fact_report.fact.from, from
    assert_equal fact_report.fact.to, to
    assert_equal 0.0, fact_report.fact.val
    assert_equal 'Rain', fact_report.fact.remarks
    assert_equal 179, fact_report.time_used
  end

  def build_loading_facts
    [{"timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from_date"=>"04.06.09", "from_time" => "21:12", "to_date"=>"08.06.09", "to_time" => "10:45"}, {"timeToCount"=>"Rain", "remarks"=>"", "val"=>"0", "from_date"=>"08.06.09", "from_time" => "10:45", "to_date"=>"08.06.09", "to_time" => "12:25"}]
  end

  def build_discharging_facts
    [{"timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from_date"=>"14.06.09", "from_time" => "1:30", "to_date"=>"15.06.09", "to_time" => "17:30"}, {"timeToCount"=>"Rain", "remarks"=>"", "val"=>"0", "from_date"=>"15.06.09", "from_time" => "17:30", "to_date"=>"15.06.09", "to_time" => "18:30"}]
  end

  def build_loading_port
    {"location" => "Jorong",  "demurrage"=>"50000", "commission_pct"=>"0", "despatch"=>"25000", "quantity"=>"55000", "description"=>"Coal", "cargo"=>"mts", "allowanceType"=>"mts/day", "allowance" => 10000, "operation"=>"loading", "time_end_date"=>"09.06.09", "time_end_time" =>  "4:30", "time_start_date"=>"04.06.09", :time_start_time => "21:12" }
  end

  def build_discharging_port
    {"location" => "Cochin",  "demurrage"=>"50000", "commission_pct"=>"0", "despatch"=>"25000", "quantity"=>"55000", "description"=>"Coal", "cargo"=>"mts", "allowanceType"=>"mts/day", "allowance" => 10000, "operation"=>"discharging", "time_end_date"=>"17.06.09", "time_end_time" =>  "4:00", "time_start_date"=>"14.06.09", "time_start_time" => "1:30"}
  end

  def build_cp_details
    {:partner => "Banpu",
     :cpName => "coal mining corp",
     :number => "1234",
     :vessel => "Medi Dublin",
     :from => "Jorong",
     :to => "Cochin",
     :currency => "USD",
     :ports_to_calculate => "A",
     :once_on_demurrage => "Always",
     :user_id => 2}
  end
end
