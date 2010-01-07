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
