FactoryBot.define do
  factory :worker_insurance do
    association :worker
    health_insurance_type { :health_insurance_association }
    sequence(:health_insurance_name) { |n| "health_insurance_name#{n}" }
    health_insurance_image { [Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec/fixtures/test.jpg'))] }
    pension_insurance_type { rand(3) }
    employment_insurance_type { :insured }
    employment_insurance_number { '123ｱ' }
    severance_pay_mutual_aid_type { :other }
    severance_pay_mutual_aid_name { 'テスト' }
  end
end
