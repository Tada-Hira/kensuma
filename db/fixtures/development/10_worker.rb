21.times do |n|
  Worker.seed(:id,
    {
      id:                            n+1,
      business_id:                   1,
      uuid:                           SecureRandom.uuid,
      name:                          "テスト作業員#{n+1}",
      name_kana:                     "テストサギョウイン#{n+1}",
      country:                       "JP",
      email:                         "test_#{n+1}@email.com",
      my_address:                    "東京都サギョウ区1-2-#{n+1}",
      my_phone_number:               "0123456#{sprintf('%04d', rand(9999))}",
      family_name:                   "連絡先氏名#{n+1}",
      relationship:                  "父",
      family_address:                "千葉県サギョウ区1-2-#{n+1}",
      family_phone_number:           "0123456#{sprintf('%04d', rand(9999))}",
      birth_day_on:                  rand(Date.parse('1950-01-01') .. Date.parse('2006-01-01')),
      abo_blood_type:                rand(0..3),
      rh_blood_type:                 rand(0..1),
      employment_contract:           rand(0..2),
      job_title:                     "主任#{n+1}",
      hiring_on:                     rand(Date.current.years_ago(10) .. Date.current.prev_month),
      experience_term_before_hiring: rand(1..10),
      blank_term:                    rand(1..10),
      career_up_id:                  "12345678901234",
      sex:                           rand(0..1),
      post_code:                     "123-4567"
    }
  )
end

21.times do |n|
  Worker.seed(:id,
    {
      id:                            n+22,
      business_id:                   2,
      uuid:                           SecureRandom.uuid,
      name:                          "テスト作業員#{n+22}",
      name_kana:                     "テストサギョウイン#{n+22}",
      country:                       'JP',
      email:                         "test_#{n+1}@email.com",
      my_address:                    "東京都サギョウ区1-2-#{n+22}",
      my_phone_number:               "0123456#{sprintf('%04d', rand(9999))}",
      family_name:                   "連絡先氏名#{n+22}",
      family_address:                "千葉県サギョウ区1-2-#{n+22}",
      relationship:                  "夫",
      family_phone_number:           "0123456#{sprintf('%04d', rand(9999))}",
      birth_day_on:                  rand(Date.parse('1950-01-01') .. Date.parse('2006-01-01')),
      abo_blood_type:                rand(0..3),
      rh_blood_type:                 rand(0..1),
      employment_contract:           rand(0..2),
      job_title:                     "係員#{n+22}",
      hiring_on:                     rand(Date.current.years_ago(10) .. Date.current.prev_month),
      experience_term_before_hiring: rand(1..10),
      blank_term:                    rand(1..10),
      career_up_id:                  "12345678901234",
      sex:                           rand(0..1),
      post_code:                     "123-4567"
    }
  )
end

21.times do |n|
  Worker.seed(:id,
    {
      id:                            n+1,
      business_id:                   1,
      uuid:                           SecureRandom.uuid,
      name:                          "テスト作業員#{n+1}",
      name_kana:                     "テストサギョウイン#{n+1}",
      country:                       "JP",
      email:                         "test_#{n+1}@email.com",
      my_address:                    "東京都サギョウ区1-2-#{n+1}",
      my_phone_number:               "0123456#{sprintf('%04d', rand(9999))}",
      family_name:                   "連絡先氏名#{n+1}",
      relationship:                  "父",
      family_address:                "千葉県サギョウ区1-2-#{n+1}",
      family_phone_number:           "0123456#{sprintf('%04d', rand(9999))}",
      birth_day_on:                  rand(Date.parse('1950-01-01') .. Date.parse('2006-01-01')),
      abo_blood_type:                rand(0..3),
      rh_blood_type:                 rand(0..1),
      employment_contract:           rand(0..2),
      job_title:                     "主任#{n+1}",
      hiring_on:                     rand(Date.current.years_ago(10) .. Date.current.prev_month),
      experience_term_before_hiring: rand(1..10),
      blank_term:                    rand(1..10),
      career_up_id:                  "12345678901234",
      sex:                           rand(0..1),
      post_code:                     "123-4567"
    }
  )
end

21.times do |n|
  Worker.seed(:id,
    {
      id:                            n+64,
      business_id:                   4,
      uuid:                           SecureRandom.uuid,
      name:                          "テスト作業員#{n+64}",
      name_kana:                     "テストサギョウイン#{n+64}",
      country:                       "jp",
      email:                         "test_#{n+1}@email.com",
      my_address:                    "東京都サギョウ区1-2-#{n+64}",
      my_phone_number:               "0123456#{sprintf('%04d', rand(9999))}",
      family_name:                   "連絡先氏名#{n+64}",
      family_address:                "千葉県サギョウ区1-2-#{n+64}",
      relationship:                  "姉",
      family_phone_number:           "0123456#{sprintf('%04d', rand(9999))}",
      birth_day_on:                  rand(Date.parse('1950-01-01') .. Date.parse('2006-01-01')),
      abo_blood_type:                rand(0..3),
      rh_blood_type:                 rand(0..1),
      job_title:                     "係員#{n+64}",
      hiring_on:                     rand(Date.current.years_ago(10) .. Date.current.prev_month),
      experience_term_before_hiring: rand(1..10),
      blank_term:                    rand(1..10),
      career_up_id:                  "12345678901234",
      sex:                           rand(0..1),
      post_code:                     "123-4567"
    }
  )
end

21.times do |n|
  Worker.seed(:id,
    {
      id:                            n+1,
      business_id:                   1,
      uuid:                           SecureRandom.uuid,
      name:                          "テスト作業員#{n+1}",
      name_kana:                     "テストサギョウイン#{n+1}",
      country:                       "JP",
      email:                         "test_#{n+1}@email.com",
      my_address:                    "東京都サギョウ区1-2-#{n+1}",
      my_phone_number:               "0123456#{sprintf('%04d', rand(9999))}",
      family_name:                   "連絡先氏名#{n+1}",
      relationship:                  "父",
      family_address:                "千葉県サギョウ区1-2-#{n+1}",
      family_phone_number:           "0123456#{sprintf('%04d', rand(9999))}",
      birth_day_on:                  rand(Date.parse('1950-01-01') .. Date.parse('2006-01-01')),
      abo_blood_type:                rand(0..3),
      rh_blood_type:                 rand(0..1),
      employment_contract:           rand(0..2),
      job_title:                     "主任#{n+1}",
      hiring_on:                     rand(Date.current.years_ago(10) .. Date.current.prev_month),
      experience_term_before_hiring: rand(1..10),
      blank_term:                    rand(1..10),
      career_up_id:                  "12345678901234",
      sex:                           rand(0..1),
      post_code:                     "123-4567"
    }
  )
end
