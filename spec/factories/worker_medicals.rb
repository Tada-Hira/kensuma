FactoryBot.define do
  factory :worker_medical do
    association :worker
    med_exam_on { '2021-12-24' }
    special_med_exam_on { '2021-12-24' }
    max_blood_pressure { 120 }
    min_blood_pressure { 70 }

    after(:create) do |worker_medical|
      create_list(:worker_exam, 1, worker_medical: worker_medical, special_med_exam: SpecialMedExam.create!(name: 'テスト特別健康診断の種類'))
    end
  end
end
