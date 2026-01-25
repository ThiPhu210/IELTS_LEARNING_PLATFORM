FactoryBot.define do
  factory :course do
    title { "Test Course" }
    price { 999999 }
    band_min { 3 }
    band_max { 7 }
    duration_days { 30 }
    status { :published }   # hoặc :draft nếu enum có
  end
end
