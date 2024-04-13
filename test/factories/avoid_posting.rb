FactoryBot.define do
  factory(:avoid_posting) do
    sequence(:artist_name) { |n| "avoid_posting_#{n}" }
    is_active { true }
    association :creator, factory: :owner_user
    creator_ip_addr { "127.0.0.1" }
  end
end
