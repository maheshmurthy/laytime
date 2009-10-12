require 'test_helper'

class LaytimeControllerTest < ActionController::TestCase

  test "cp detail not filled" do
    post :portdetails
    assert_equal "can't be blank", session[:cp_detail].errors["vessel"]
    assert_redirected_to :action => "cpdetails"
  end

  test "cp detail validation" do
    post(:portdetails,{:cp_detail => {:partner => "Banpu",
                        :cpName => "coal mining corp",
                        :number => "1234",
                        :vessel => "My vessel",
                        :from => "Jorong",
                        :to => "Cochin",
                        :currency => "USD",
                        :ports_to_calculate => "A",
                        :once_on_demurrage => "A"}})
    assert_response :success
    assert_equal "Banpu", session[:cp_detail].partner
    assert_equal "coal mining corp", session[:cp_detail].cpName
    assert_equal 1234, session[:cp_detail].number
    assert_equal "My vessel", session[:cp_detail].vessel
    assert_equal "Jorong", session[:cp_detail].from
    assert_equal "Cochin", session[:cp_detail].to
    assert_equal "USD", session[:cp_detail].currency
    assert_equal "A", session[:cp_detail].ports_to_calculate
    assert_equal "A", session[:cp_detail].once_on_demurrage
  end

  test "port_detail validation" do

    loading_port_detail = {"location" => "Jorong",  "demurrage"=>"50000", "commission_pct"=>"0", "despatch"=>"25000", "quantity"=>"55000", "description"=>"Coal", "cargo"=>"mts", "allowanceType"=>"mts/day", "allowance" => 10000, "operation"=>"loading", "time_end"=>"2009-06-09 04:30:00 UTC", "time_start"=>"2009-06-04 21:12:00 UTC"}

    discharging_port_detail = {"location" => "Cochin",  "demurrage"=>"50000", "commission_pct"=>"0", "despatch"=>"25000", "quantity"=>"55000", "description"=>"Coal", "cargo"=>"mts", "allowanceType"=>"mts/day", "allowance" => 10000, "operation"=>"discharging", "time_end"=>"2009-06-17 04:00:00 UTC", "time_start"=>"2009-06-14 01:30:00 UTC"}

    loading_facts = [{"timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from"=>"2009-06-04 21:12:00 UTC", "to"=>"2009-06-08 10:45:00 UTC"}, {"timeToCount"=>"Rain", "remarks"=>"", "val"=>"0", "from"=>"2009-06-08 10:45:00 UTC", "to"=>"2009-06-08 12:25:00 UTC"}]

    discharging_facts = [{"timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from"=>"2009-06-14 01:30:00 UTC", "to"=>"2009-06-15 17:30:00 UTC"}, {"timeToCount"=>"Rain", "remarks"=>"", "val"=>"0", "from"=>"2009-06-15 17:30:00 UTC", "to"=>"2009-06-15 18:30:00 UTC"}]

    pre_advise = [{"mins"=>"0", "days"=>"0", "hours"=>"0"}, {"mins"=>"0", "days"=>"0", "hours"=>"0"}]

    add_allowance = [{"mins"=>"0", "days"=>"5", "hours"=>"12"}, {"mins"=>"0", "days"=>"5", "hours"=>"12"}]

    port_details = Array.new
    port_details << loading_port_detail
    port_details << discharging_port_detail
    cp_detail = CpDetail.new(:partner => "Banpu",
                        :cpName => "coal mining corp",
                        :number => "1234",
                        :vessel => "My vessel",
                        :from => "Jorong",
                        :to => "Cochin",
                        :currency => "USD",
                        :ports_to_calculate => "A",
                        :once_on_demurrage => "A")

    post(:result, {:portdetail => port_details, 
                   :calculation_type0 => "normal", 
                   :calculation_type1 =>"normal",
                   :calculation_time_saved0 =>"working",
                   :calculation_time_saved1 =>"working",
                   :loading => loading_facts,
                   :discharging => discharging_facts,
                   :pre_advise => pre_advise,
                   :add_allowance => add_allowance
                   }, {:cp_detail => cp_detail})

    assert_response :success
  end

  test "validate values in the report" do
    loading_facts = Array.new
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from"=>"2009-06-04 21:12:00 UTC", "to"=>"2009-06-08 10:45:00 UTC")
    loading_facts << fact
    fact = Fact.new("timeToCount"=>"Rain", "remarks"=>"", "val"=>"0", "from"=>"2009-06-08 10:45:00 UTC", "to"=>"2009-06-08 12:25:00 UTC")
    loading_facts << fact
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from"=>"2009-06-08 12:25:00 UTC", "to"=>"2009-06-08 24:00:00 UTC")
    loading_facts << fact
    fact = Fact.new("timeToCount"=>"Not to Count", "remarks"=>"", "val"=>"0", "from"=>"2009-06-09 00:00:00 UTC", "to"=>"2009-06-09 00:30:00 UTC")
    loading_facts << fact
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from"=>"2009-06-09 00:30:00 UTC", "to"=>"2009-06-09 04:30:00 UTC")
    loading_facts << fact

    discharging_facts = Array.new
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from"=>"2009-06-14 01:30:00 UTC", "to"=>"2009-06-15 17:30:00 UTC")
    discharging_facts << fact
    fact = Fact.new("timeToCount"=>"Rain", "remarks"=>"", "val"=>"0", "from"=>"2009-06-15 17:30:00 UTC", "to"=>"2009-06-15 18:30:00 UTC")
    discharging_facts << fact
    fact = Fact.new("timeToCount"=>"Full", "remarks"=>"", "val"=>"100", "from"=>"2009-06-15 18:30:00 UTC", "to"=>"2009-06-17 04:00:00 UTC")
    discharging_facts << fact

    additional_time_infos = Array.new
    additional_time_infos << TimeInfo.new("hours" => 12, "days" => 3, "mins" => 10, "type" => "add_allowance")
    additional_time_infos << TimeInfo.new("hours" => 12, "days" => 3, "mins" => 10, "type" => "add_allowance")

    report = @controller.generate_report(loading_facts, discharging_facts, additional_time_infos, 50000, 25000, 50000, 25000)
    assert_equal 4, report.loading_time_used.days
    assert_equal 5, report.loading_time_used.hours
    assert_equal 8, report.loading_time_used.mins

    assert_equal 3, report.discharging_time_used.days
    assert_equal 1, report.discharging_time_used.hours
    assert_equal 30,report.discharging_time_used.mins
  end
end
