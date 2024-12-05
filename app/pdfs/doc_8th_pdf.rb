class Doc8thPdf < Prawn::Document
  include ActionView::Helpers::TranslationHelper
  include ApplicationHelper
  include DocumentsHelper

  def initialize(document_site_info, document_info, document)
    super(page_size: 'A3', page_layout: :landscape)
    font 'app/assets/fonts/ipaexg.ttf'
    font_families.update("font" => {
      normal: "app/assets/fonts/ipaexg.ttf",
      bold: "app/assets/fonts/ipaexg.ttf"
    })
    @document_site_info = document_site_info
    @document_info = document_info
    @document = document
    # setup_document
    # 他の初期化処理
    @document_info.field_workers.each_slice(8).each_with_index do |(w1, w2, w3, w4, w5, w6, w7, w8), i|
      start_new_page if i > 0
      setup_document(w1, w2, w3, w4, w5, w6, w7, w8, i)
      # setup_template
      # stroke_axis
    end
    # stroke_axis
  end

  def setup_document(w1, w2, w3, w4, w5, w6, w7, w8, i)
    font("font")

    workers = [w1, w2, w3, w4, w5, w6, w7, w8]

    text_box "作　　業　　員　　名　　簿", at: [0, 775], size: 18, style: :bold, align: :center

    # 8-004 作成日
    text_box "(　　　　　　　　　　　　作成)", at: [0, 746], size: 10, style: :bold, align: :center
    bounding_box([500, 748], width: 100, height: 16) do
      text_box(wareki(@document.content&.[]('date_created')&.[]("field_worker_#{i}")), at: [2, 13], size: 10, style: :normal, align: :center)
    end

    text_box "事業所の名称", at: [29, 759], size: 9, style: :normal
    stroke_horizontal_line(89, 297, at: 748)
    bounding_box([89, 763], width: 208, height: 15) do
      text_box(@document_site_info.content&.[]("genecon_name") , at: [2, 13], size: 10, style: :normal)
    end

    text_box "現 　場 　ID", at: [29, 743], size: 9, style: :normal
    stroke_horizontal_line(89, 297, at: 732)
    bounding_box([89, 748], width: 208, height: 16) do
      text_box(@document_site_info.site_career_up_id, at: [2, 13], size: 10, style: :normal)
    end

    text_box "所 　長 　名", at: [29, 726], size: 9, style: :normal
    stroke_horizontal_line(89, 297, at: 716)
    bounding_box([89, 732], width: 208, height: 16) do
      text_box(@document_site_info.site_agent_name, at: [2, 13], size: 10, style: :normal)
    end

    text_box "　本書面に記載した内容は、作業員名簿として安", at: [312, 713], size: 9.1, style: :normal
    text_box "全衛生管理や労働災害発生時の緊急連絡・対応の", at: [312, 699], size: 9.1, style: :normal
    text_box "ために元請負業者に提示することについて、記載", at: [312, 685], size: 9.1, style: :normal
    text_box "者本人は同意しています。", at: [312, 670], size: 9.1, style: :normal

    # 8-005 一次会社名
    text_box "一次会社名", at: [550, 685], size: 9.1, style: :normal
    stroke_horizontal_line(611, 794, at: 669)
    bounding_box([610, 685], width: 184, height: 16) do
      text_box(primary_subcon_info(@document_info)&.content&.[]("subcon_name"), at: [2, 13], size: 10, style: :normal)
    end

    # 8-006 一次会社の「事業者ID(キャリアアップID)」
    text_box "事 業 者 ID", at: [551, 666], size: 9.1, style: :normal
    stroke_horizontal_line(611, 794, at: 653)
    bounding_box([610, 669], width: 184, height: 16) do
      text_box(primary_subcon_info(@document_info).content&.[]('subcon_career_up_id'), at: [2, 13], size: 10, style: :normal)
    end

    # 8-007 次, 8-009 自社の「会社名」
    text_box "(　　　　)　会社名", at: [828, 685], size: 9.1, style: :normal
    stroke_horizontal_line(912, 1095, at: 669)
    bounding_box([837, 686], width: 30, height: 16) do
      text_box(sc_hierarchy(@document_info), at: [2, 13], size: 9, style: :normal)
    end

    bounding_box([910, 685], width: 184, height: 16) do
      text_box(Business.find(@document_info.business_id).name, at: [2, 13], size: 10, style: :normal)
    end

    # 8-010 自社の「事業者ID(キャリアアップID)」
    text_box "事 業 者 ID", at: [840, 666], size: 9.1, style: :normal
    stroke_horizontal_line(912, 1095, at: 653)
    bounding_box([910, 669], width: 184, height: 16) do
      text_box(Business.find(@document_info.business_id).career_up_id, at: [2, 13], size: 10, style: :normal)
    end

    # 8-042 元請会社の確認欄
    bounding_box([873, 763], width: 222, height: 31) do
      stroke_rectangle([0, bounds.height], bounds.width, bounds.height)
      stroke_vertical_line(bounds.height, 0, at: 91) # 91ポイントの位置に縦線を引く
      text_box "元請", at: [37, cursor - 3], size: 9.1, style: :normal
      text_box "確認欄", at: [32, cursor - 17], size: 9.1, style: :normal
    end

    bounding_box([964, 763], width: 131, height: 31) do
      stroke_bounds
      text_box(@document.content&.[]('prime_contractor_confirmation'), at: [0, 20], size: 10, style: :normal, align: :center)
    end

    # 8-011 提出日
    text_box "提出日", at: [951, 712], size: 9.1, style: :normal
    stroke_horizontal_line(991, 1095, at: 701)
    bounding_box([991, 717], width: 104, height: 16) do
      text_box(wareki(@document.content&.[]('date_submitted')&.[]("field_worker_#{i}")), at: [2, 13], size: 10, style: :normal)
    end

    bounding_box([23, 643], width: 1072, height: 522) do
      stroke_rectangle([0, bounds.height], bounds.width, bounds.height)
      stroke_vertical_line(bounds.height, 0, at: 26)
      stroke_vertical_line(bounds.height, 0, at: 209)
      stroke_vertical_line(bounds.height, 0, at: 248)
      stroke_vertical_line(bounds.height, 0, at: 274)
      stroke_vertical_line(bounds.height, 0, at: 366)
      stroke_vertical_line(bounds.height, 0, at: 457)
      stroke_vertical_line(bounds.height, 0, at: 549)
      stroke_vertical_line(bounds.height - 29, 0, at: 693)
      stroke_vertical_line(bounds.height - 29, 0, at: 836)
      stroke_vertical_line(bounds.height, 0, at: 980)

      # 番号
      stroke_horizontal_line(457, bounds.width, at: bounds.height - 29)
      stroke_horizontal_line(0, bounds.width, at: bounds.height - 58)
      text_box "番", at: [9, bounds.height - 15], size: 10, style: :normal
      text_box "号", at: [9, bounds.height - 30], size: 10, style: :normal

      index_positions = [
        bounds.height - 80,
        bounds.height - 140,
        bounds.height - 197,
        bounds.height - 256,
        bounds.height - 315,
        bounds.height - 372,
        bounds.height - 430,
        bounds.height - 488
      ]

      index_positions.each_with_index do |y_position, index|
        bounding_box([-1, y_position], width: 30, height: 30) do
          text_box((index + 1 + i * 8).to_s, at: [0, 30], size: 10, style: :normal, align: :center)
        end
      end

      stroke_horizontal_line(26, 209, at: bounds.height - 19) # ふりがな,氏名,技能者IDの見出し
      stroke_horizontal_line(26, 209, at: bounds.height - 38)

      text_box "ふりがな", at: [105, bounds.height - 5], size: 7, style: :normal

      name_kana_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([26, name_kana_positions[index]], width: 183, height: 19) do
          text_box(worker_str(worker, "name_kana"), at: [0, 13], size: 7, style: :normal, align: :center)
        end
      end

      text_box "氏名", at: [109, bounds.height - 23], size: 9, style: :normal

      name_positions = [
        bounds.height - 77,
        bounds.height - 135,
        bounds.height - 193,
        bounds.height - 251,
        bounds.height - 309,
        bounds.height - 367,
        bounds.height - 425,
        bounds.height - 483
      ]

      workers.each_with_index do |worker, index|
        bounding_box([26, name_positions[index]], width: 183, height: 19) do
          text_box(worker_str(worker, "name"), at: [0, 13], size: 9, style: :normal, align: :center)
        end
      end

      text_box "技能者ID", at: [100, bounds.height - 43], size: 9, style: :normal

      career_up_id_positions = [
        bounds.height - 96,
        bounds.height - 154,
        bounds.height - 212,
        bounds.height - 270,
        bounds.height - 328,
        bounds.height - 386,
        bounds.height - 444,
        bounds.height - 502
      ]

      workers.each_with_index do |worker, index|
        bounding_box([26, career_up_id_positions[index]], width: 183, height: 20) do
          text_box(worker_str(worker, "career_up_id"), at: [0, 14], size: 9, style: :normal, align: :center)
        end
      end

      # 8-015 職種
      text_box "職 種", at: [219, bounds.height - 23], size: 9, style: :normal

      field_worker_occupation_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([209, field_worker_occupation_positions[index]], width:39, height: 58) do
          text_box(worker_occupation(worker).to_s, at: [0, 50], size: 7, style: :normal, align: :center)
        end
      end

      # 8-016 記号(※)
      text_box "※", at: [257, bounds.height - 23], size: 9, style: :normal

      field_worker_symbol_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([248, field_worker_symbol_positions[index]], width: 26, height: 58) do
          text_box(field_worker_symbol_pdf(worker).to_s, at: [3, 50], size: 8, style: :normal)
        end
      end

      text_box "生年月日", at: [303, bounds.height - 7], size: 9, style: :normal

      birth_day_on_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([274, birth_day_on_positions[index]], width: 92, height: 29) do
          text_box(wareki(worker_str(worker, "birth_day_on")), at: [0, 19], size: 9, style: :normal, align: :center)
        end
      end

      text_box "年齢", at: [311, bounds.height - 37], size: 9, style: :normal

      birth_day_on_positions = [
        bounds.height - 87,
        bounds.height - 145,
        bounds.height - 203,
        bounds.height - 261,
        bounds.height - 319,
        bounds.height - 377,
        bounds.height - 435,
        bounds.height - 493
      ]

      workers.each_with_index do |worker, index|
        bounding_box([274, birth_day_on_positions[index]], width: 92, height: 29) do
          text_box(worker_age(worker), at: [0, 19], size: 9, style: :normal, align: :center)
        end
      end

      text_box "健康保険", at: [394, bounds.height - 4], size: 9, style: :normal

      health_insurance_type_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([366, health_insurance_type_positions[index]], width: 91, height: 19) do
          text_box(worker_insurance(worker, "health_insurance_type"), at: [0, 14], size: 9, style: :normal, align: :center)
        end
      end

      text_box "年金保険", at: [394, bounds.height - 23], size: 9, style: :normal

      pension_insurance_type_positions = [
        bounds.height - 77,
        bounds.height - 135,
        bounds.height - 193,
        bounds.height - 251,
        bounds.height - 309,
        bounds.height - 367,
        bounds.height - 425,
        bounds.height - 483
      ]

      workers.each_with_index do |worker, index|
        bounding_box([366, pension_insurance_type_positions[index]], width: 91, height: 19) do
          text_box(worker_insurance(worker, "pension_insurance_type"), at: [0, 14], size: 9, style: :normal, align: :center)
        end
      end

      text_box "雇用保険", at: [394, bounds.height - 43], size: 9, style: :normal

      employment_insurance_type_positions = [
        bounds.height - 96,
        bounds.height - 154,
        bounds.height - 212,
        bounds.height - 270,
        bounds.height - 328,
        bounds.height - 386,
        bounds.height - 444,
        bounds.height - 502
      ]

      workers.each_with_index do |worker, index|
        bounding_box([366, employment_insurance_type_positions[index]], width: 91, height: 20) do
          text_box(worker_insurance(worker, "employment_insurance_type"), at: [0, 14], size: 9, style: :normal, align: :center)
        end
      end

      text_box "建設業退職金", at: [476, bounds.height - 1], size: 9, style: :normal
      text_box "共済制度", at: [485, bounds.height - 15], size: 9, style: :normal

      construction_industry_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([457, construction_industry_positions[index]], width: 92, height: 29) do
          text_box(construction_industry(@document_info), at: [0, 18], size: 9, style: :normal, align: :center)
        end
      end

      text_box "中小企業退職金", at: [472, bounds.height - 30], size: 9, style: :normal
      text_box "共済制度", at: [485, bounds.height - 44], size: 9, style: :normal

      smaller_companies_positions = [
        bounds.height - 87,
        bounds.height - 145,
        bounds.height - 203,
        bounds.height - 261,
        bounds.height - 319,
        bounds.height - 377,
        bounds.height - 435,
        bounds.height - 493
      ]

      workers.each_with_index do |worker, index|
        bounding_box([457, smaller_companies_positions[index]], width: 92, height: 29) do
          text_box(smaller_companies(@document_info), at: [0, 18], size: 9, style: :normal, align: :center)
        end
      end

      text_box "教 育・資 格・免 許", at: [715, bounds.height - 8], size: 9, style: :normal

      text_box "雇入・職⾧", at: [598, bounds.height - 30], size: 9, style: :normal
      text_box "特別教育", at: [603, bounds.height - 44], size: 9, style: :normal

      worker_special_education_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([549, worker_special_education_positions[index]], width: 144, height: 58) do
          text_box(worker_special_education(worker), at: [2, 57], size: 7, style: :normal)
        end
      end

      text_box "技能講習", at: [747, bounds.height - 37], size: 9, style: :normal

      worker_skill_training_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([693, worker_skill_training_positions[index]], width: 143, height: 58) do
          text_box(worker_skill_training(worker), at: [2, 57], size: 7, style: :normal)
        end
      end

      text_box "免　許", at: [895, bounds.height - 37], size: 9, style: :normal

      worker_license_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([836, worker_license_positions[index]], width: 144, height: 58) do
          text_box(worker_license(worker), at: [2, 57], size: 7, style: :normal)
        end
      end

      text_box "入場年月日", at: [1004, bounds.height - 8], size: 9, style: :normal

      text_box "受入教育", at: [1008, bounds.height - 30], size: 9, style: :normal

      field_worker_admission_date_positions = [
        bounds.height - 58,
        bounds.height - 116,
        bounds.height - 174,
        bounds.height - 232,
        bounds.height - 290,
        bounds.height - 348,
        bounds.height - 406,
        bounds.height - 464
      ]

      workers.each_with_index do |worker, index|
        bounding_box([980, field_worker_admission_date_positions[index]], width: 92, height: 29) do
          text_box(field_worker_admission_date(worker), at: [0, 19], size: 9, style: :normal, align: :center)
        end
      end

      text_box "実施年月日", at: [1004, bounds.height - 44], size: 9, style: :normal

      field_worker_education_date_positions = [
        bounds.height - 87,
        bounds.height - 145,
        bounds.height - 203,
        bounds.height - 261,
        bounds.height - 319,
        bounds.height - 377,
        bounds.height - 435,
        bounds.height - 493
      ]

      workers.each_with_index do |worker, index|
        bounding_box([980, field_worker_education_date_positions[index]], width: 92, height: 29) do
          text_box(field_worker_education_date(worker), at: [0, 19], size: 9, style: :normal, align: :center)
        end
      end

      stroke_horizontal_line(274, 366, at: bounds.height - 28) # 生年月日,年齢の見出し

      stroke_horizontal_line(366, 457, at: bounds.height - 19) # 健康保険,年金保険,雇用保険の見出し
      stroke_horizontal_line(366, 457, at: bounds.height - 38)

      # 1
      stroke_horizontal_line(0, bounds.width, at: bounds.height - 116)
      stroke_horizontal_line(26, 209, at: bounds.height - 96) # ふりがな,氏名,技能者ID
      stroke_horizontal_line(26, 209, at: bounds.height - 77)
      stroke_horizontal_line(274, 366, at: bounds.height - 87) # 生年月日,年齢
      stroke_horizontal_line(366, 457, at: bounds.height - 96) # 健康保険, 年金保険, 雇用保険
      stroke_horizontal_line(366, 457, at: bounds.height - 77)
      stroke_horizontal_line(457, 549, at: bounds.height - 87) # 建退共,中退共
      stroke_horizontal_line(980, bounds.width, at: bounds.height - 87) # 入場年月日,受入教育実施年月日

      # 2
      stroke_horizontal_line(0, bounds.width, at: bounds.height - 174)
      stroke_horizontal_line(26, 209, at: bounds.height - 154) # ふりがな,氏名,技能者ID
      stroke_horizontal_line(26, 209, at: bounds.height - 135)
      stroke_horizontal_line(274, 366, at: bounds.height - 145) # 生年月日,年齢
      stroke_horizontal_line(366, 457, at: bounds.height - 154) # 健康保険, 年金保険, 雇用保険
      stroke_horizontal_line(366, 457, at: bounds.height - 135)
      stroke_horizontal_line(457, 549, at: bounds.height - 145) # 建退共,中退共
      stroke_horizontal_line(980, bounds.width, at: bounds.height - 145) # 入場年月日,受入教育実施年月日

      # 3
      stroke_horizontal_line(0, bounds.width, at: bounds.height - 232)
      stroke_horizontal_line(26, 209, at: bounds.height - 212) # ふりがな,氏名,技能者ID
      stroke_horizontal_line(26, 209, at: bounds.height - 193)
      stroke_horizontal_line(274, 366, at: bounds.height - 203) # 生年月日,年齢
      stroke_horizontal_line(366, 457, at: bounds.height - 212) # 健康保険,年金保険,雇用保険
      stroke_horizontal_line(366, 457, at: bounds.height - 193)
      stroke_horizontal_line(457, 549, at: bounds.height - 203) # 建退共,中退共
      stroke_horizontal_line(980, bounds.width, at: bounds.height - 203) # 入場年月日,受入教育実施年月日

      # 4
      stroke_horizontal_line(0, bounds.width, at: bounds.height - 290)
      stroke_horizontal_line(26, 209, at: bounds.height - 270) # ふりがな,氏名,技能者ID
      stroke_horizontal_line(26, 209, at: bounds.height - 251)
      stroke_horizontal_line(274, 366, at: bounds.height - 261) # 生年月日,年齢
      stroke_horizontal_line(366, 457, at: bounds.height - 270) # 健康保険,年金保険,雇用保険
      stroke_horizontal_line(366, 457, at: bounds.height - 251)
      stroke_horizontal_line(457, 549, at: bounds.height - 261) # 建退共,中退共
      stroke_horizontal_line(980, bounds.width, at: bounds.height - 261) # 入場年月日,受入教育実施年月日

      # 5
      stroke_horizontal_line(0, bounds.width, at: bounds.height - 348)
      stroke_horizontal_line(26, 209, at: bounds.height - 328) # ふりがな,氏名,技能者ID
      stroke_horizontal_line(26, 209, at: bounds.height - 309)
      stroke_horizontal_line(274, 366, at: bounds.height - 319) # 生年月日,年齢
      stroke_horizontal_line(366, 457, at: bounds.height - 328) # 健康保険,年金保険,雇用保険
      stroke_horizontal_line(366, 457, at: bounds.height - 309)
      stroke_horizontal_line(457, 549, at: bounds.height - 319) # 建退共,中退共
      stroke_horizontal_line(980, bounds.width, at: bounds.height - 319) # 入場年月日,受入教育実施年月日

      # 6
      stroke_horizontal_line(0, bounds.width, at: bounds.height - 406)
      stroke_horizontal_line(26, 209, at: bounds.height - 386) # ふりがな,氏名,技能者ID
      stroke_horizontal_line(26, 209, at: bounds.height - 367)
      stroke_horizontal_line(274, 366, at: bounds.height - 377) # 生年月日,年齢
      stroke_horizontal_line(366, 457, at: bounds.height - 386) # 健康保険,年金保険,雇用保険
      stroke_horizontal_line(366, 457, at: bounds.height - 367)
      stroke_horizontal_line(457, 549, at: bounds.height - 377) # 建退共,中退共
      stroke_horizontal_line(980, bounds.width, at: bounds.height - 377) # 入場年月日,受入教育実施年月日

      # 7
      stroke_horizontal_line(0, bounds.width, at: bounds.height - 464)
      stroke_horizontal_line(26, 209, at: bounds.height - 444) # ふりがな,氏名,技能者ID
      stroke_horizontal_line(26, 209, at: bounds.height - 425)
      stroke_horizontal_line(274, 366, at: bounds.height - 435) # 生年月日,年齢
      stroke_horizontal_line(366, 457, at: bounds.height - 444) # 健康保険,年金保険,雇用保険
      stroke_horizontal_line(366, 457, at: bounds.height - 425)
      stroke_horizontal_line(457, 549, at: bounds.height - 435) # 建退共,中退共
      stroke_horizontal_line(980, bounds.width, at: bounds.height - 435) # 入場年月日,受入教育実施年月日

      # 8
      stroke_horizontal_line(26, 209, at: bounds.height - 502) # ふりがな,氏名,技能者ID
      stroke_horizontal_line(26, 209, at: bounds.height - 483)
      stroke_horizontal_line(274, 366, at: bounds.height - 493) # 生年月日,年齢
      stroke_horizontal_line(366, 457, at: bounds.height - 502) # 健康保険,年金保険,雇用保険
      stroke_horizontal_line(366, 457, at: bounds.height - 483)
      stroke_horizontal_line(457, 549, at: bounds.height - 493) # 建退共,中退共
      stroke_horizontal_line(980, bounds.width, at: bounds.height - 493) # 入場年月日,受入教育実施年月日
    end

    draw_text "（注）1.　 ※印欄には次の記号等を入れる。（表示されない情報があります。）", at: [25, 101], size: 7.5, style: :normal
    draw_text "現…現場代理人", at: [63, 90], size: 7.5, style: :normal
    draw_text "作…作業主任者（（注）２．）", at: [220, 90], size: 7.5, style: :normal
    draw_text "女…女性作業員", at: [365, 90], size: 7.5, style: :normal
    draw_text "未…18歳未満の作業員", at: [482, 90], size: 7.5, style: :normal
    draw_text "主…主任技術者", at: [63, 78], size: 7.5, style: :normal
    draw_text "職…職⾧", at: [220, 78], size: 7.5, style: :normal
    draw_text "安…安全衛生責任者", at: [365, 78], size: 7.5, style: :normal
    draw_text "歳…能力向上教育", at: [482, 78], size: 7.5, style: :normal
    draw_text "再…危険有害業務・再発防止教育", at: [63, 66], size: 7.5, style: :normal
    draw_text "習…外国人技能実習生", at: [220, 66], size: 7.5, style: :normal
    draw_text "就…外国人建設就労者 ", at: [365, 66], size: 7.5, style: :normal
    draw_text "1特…１号特定技能外国人 ", at: [482, 66], size: 7.5, style: :normal

    draw_text "（注）2.　 作業主任者は作業を直接指揮する義務を負うので、同時に施工されている他の現場や、同一現場においても他の作業個所との作業主任者を兼務するこ", at: [25, 54], size: 7.5, style: :normal
    draw_text "とは、法的に認められていないので、複数の選任としなければならない。", at: [63, 42], size: 7.5, style: :normal
    draw_text "（注）3.　 各社別に作成するのが原則だが、リース機械等の運転者は一緒でもよい。", at: [25, 30], size: 7.5, style: :normal
    draw_text "（注）4.　 資格・免許等の写しを添付することが望ましい。", at: [25, 18], size: 7.5, style: :normal
    draw_text "（注）5.　 健康保険欄には、左欄に健康保険の名称（健康保険組合、協会けんぽ、建設国保、国民健康保険）を記載。上記の保険に加入しておらず、後期高齢者", at: [25, 6], size: 7.5, style: :normal
    draw_text "である等により、国民健康保険の適用除外である場合には、左欄に「適用除外」と記載。 ", at: [63, - 5], size: 7.5, style: :normal

    draw_text "（注）6. 年金保険欄には、左欄に年金保険の名称（厚生年金、国民年金）を記載。", at: [630, 101], size: 7.5, style: :normal
    draw_text "各年金の受給者である場合は、左欄に「受給者」と記載。", at: [661, 91], size: 7.5, style: :normal
    draw_text "（注）7. 雇用保険欄には右欄に被保険者番号の下４けたを記載。（日雇労働被保険者の場合には左欄に「日雇保険」と記載）事業主で", at: [630, 81], size: 7.5, style: :normal
    draw_text "ある等により雇用保険の適用除外である場合には左欄に「適用除外」と記載。", at: [661, 68], size: 7.5, style: :normal
    draw_text "（注）8. 建設業退職金共済制度及び中小企業退職金共済制度への加入の有無については、それぞれの欄に「有」又は「無」と記載。", at: [630, 54], size: 7.5, style: :normal
    draw_text "（注）9. 安全衛生に関する教育の内容（例:雇入時教育、職⾧教育、建設用リフト の運転の業務に係る特別教育）については「雇入・", at: [630, 42], size: 7.5, style: :normal
    draw_text "職⾧特別教育」欄に記載。", at: [661, 30], size: 7.5, style: :normal
    draw_text "（注）10. 建設工事に係る知識及び技術又は技能に関する資格（例:登録○○基幹技能者、○級○○施工管理技士）を有する場合は、", at: [630, 18], size: 7.5, style: :normal
    draw_text "「免許」欄に記載。", at: [661, 6], size: 7.5, style: :normal
    draw_text "（注）11. 記載事項の一部について、別紙を用いて記載しても差し支えない。", at: [630, - 5], size: 7.5, style: :normal
  end
end
