Factory.define :user do |f|
  f.sequence(:username) {|n| "mushu#{n}"}
  f.password "foobar"
  f.password_confirmation {|u| u.password}
  f.sequence(:email) { |n| "mushu#{n}@mulan.com"}
  f.association :account
end

Factory.define :account do |f|
  f.pricing_plan "FREE"
end

Factory.define :cp_detail do |f|
  f.partner "Banpu"
  f.cpName "coal mining corp"
  f.number "1234"
  f.vessel "Medi Dublin"
  f.from "Jorong"
  f.to "Cochin"
  f.currency "USD"
  f.ports_to_calculate "A"
  f.once_on_demurrage "Always"
  f.association :user
end

Factory.define :port_detail do |f|
  f.demurrage "50000"
  f.commission_pct "0"
  f.despatch "25000"
  f.quantity "55000"
  f.description "Coal"
  f.cargo "mts"
  f.allowanceType "mts/day"
  f.allowance  "10000"
end

Factory.define :loading_port_details, :parent => :port_detail do |f|
  f.location  "Jorong"
  f.operation "loading"
  f.time_end_date "09.06.09"
  f.time_end_time "4:30"
  f.time_start_date "04.06.09"
  f.time_start_time "21:12 "
end

Factory.define :discharging_port_details, :parent => :port_detail do |f|
  f.location  "Cochin"
  f.operation "discharging"
  f.time_end_date "17.06.09"
  f.time_end_time "4:00"
  f.time_start_date "14.06.09"
  f.time_start_time "1:30"
end

Factory.define :fact do |f|
  f.from "17.06.09"
end
