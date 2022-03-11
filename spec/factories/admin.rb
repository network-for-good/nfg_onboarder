FactoryBot.define do
  factory :admin, class: Admin do
    first_name { "Jim" }
    last_name { "Smith" }
    email { "jim@smith.com" }
  end
end