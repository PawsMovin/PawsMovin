FactoryBot.define do
  factory(:ticket) do
    transient do
      content { nil }
    end

    reason { "test" }
    creator
    creator_ip_addr { "127.0.0.1" }
  end
end
