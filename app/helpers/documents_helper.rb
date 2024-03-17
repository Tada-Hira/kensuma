# rubocop:disable all
module DocumentsHelper
  # 日付
  def document_date(column)
    l(column, format: :long) unless column.nil?
  end
  
  # document.contentの日付
  def doc_content_date(date)
    if action_name == 'edit'
      date.nil? ? '年　月　日' : date.to_date&.strftime('%Y年%-m月%-d日') # nilの場合のstrftime表示エラー回避
    else
      date.nil? ? '年　月　日' : wareki(date.to_date)
    end
  end

  # (4)施工体制台帳

  # 一次下請の情報
  def subcon_info
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    request_order if request_order.depth == 1
  end

  def subcons_info
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    request_order.children if request_order.depth.zero?
  end

  def document_subcon_info
    if RequestOrder.find_by(uuid: params[:request_order_uuid]).depth == 1
      subcon_info
    else
      @subcon
    end
  end
  
  
  # 一次下請の情報 (工事安全衛生計画書用)
  def document_subcon_info_for_10th_11th_19th
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    # 元請が下請の書類確認するとき
    if params[:sub_request_order_uuid] && request_order.parent_id.nil?
      RequestOrder.find_by(uuid: params[:sub_request_order_uuid])
    # 下請けが自身の書類確認するとき
    elsif request_order.parent_id && request_order.parent_id == request_order.parent&.id
      request_order
      # 下請けが存在しない場合
    else
      nil
    end
  end

  # 会社の名前
  def company_name(worker_id)
    worker = Worker.find_by(uuid: worker_id)
    Business.find_by(id: worker&.business_id)&.name
  end

  # 書類作成会社の名前
  def document_preparation_company_name
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    if params[:sub_request_order_uuid] && request_order.parent_id.nil? # 元請が下請の書類確認するとき
      sub_request_order = RequestOrder.find_by(uuid: params[:sub_request_order_uuid])
      sub_request_order.content&.[]('subcon_name')
    elsif params[:sub_request_order_uuid].nil? && request_order.parent_id.nil? # 元請が自身の書類確認するとき
      request_order.order.content&.[]('genecon_name')
    else # 下請けが自身の書類確認するとき
      request_order.content&.[]('subcon_name')
    end
  end

  # 作業員情報
  def worker(worker_uuid)
    Worker.find_by(uuid: worker_uuid)&.name
  end

  # 専任･非専任
  FULL_TIME_CHECK = {
    'full_time'     => '専任',
    'non_dedicated' => '非専任'
  }.freeze

  def full_time_check(check)
    status = FULL_TIME_CHECK[check]
    status == '専任' ? tag.span(status, class: :circle) : '専任'
  end

  def non_dedicated_check(check)
    status = FULL_TIME_CHECK[check]
    status == '非専任' ? tag.span(status, class: :circle) : '非専任'
  end

  # 外国人従事の状況
  ENGAGED_TYPE = {
    '有'             => '有',
    '無'             => '無'
  }.freeze

  def engaged_yes(engaged_type)
    status = ENGAGED_TYPE[engaged_type]
    status == '有' ? tag.span(status, class: :circle) : '有'
  end

  def engaged_no(engaged_type)
    status = ENGAGED_TYPE[engaged_type]
    status == '無' ? tag.span(status, class: :circle) : '無'
  end

  # 会社の保険加入状況
  INSURANCE_TYPE = {
    'join'       => '加入',
    'not_join'   => '未加入',
    'not_coverd' => '適用除外'
  }.freeze

  def insurance_join(insurance_type)
    status = INSURANCE_TYPE[insurance_type]
    status == '加入' ? tag.span(status, class: :circle) : '加入'
  end

  def insurance_not_join(insurance_type)
    status = INSURANCE_TYPE[insurance_type]
    status == '未加入' ? tag.span(status, class: :circle) : '未加入'
  end

  def insurance_not_coverd(insurance_type)
    status = INSURANCE_TYPE[insurance_type]
    status == '適用除外' ? tag.span(status, class: :circle) : '適用除外'
  end

  # (5)再下請負通知書（変更届）
  def skill_info(license, model)
    if license == "registered_core_engineer_qualification"
      License.find_by(id: model&.send(license))&.name
    else
      SkillTraining.find_by(id: model&.send(license))&.name
    end
  end

  def child_check(child)
    if child.present?
      Industry.joins(businesses: :business_industries).find_by(business_industries: {business_id: child&.business_id})&.name
    else
      "FALSE"
    end
  end

  def minister(license_permission_type)
    license_permission_type == '大臣' ? tag.span('大臣', class: :circle) : '大臣'
  end

  def governor(license_permission_type)
    license_permission_type == '知事' ? tag.span('知事', class: :circle) : '知事'
  end

  def identification(license_permission_type)
    license_permission_type == '特定' ? tag.span('特定', class: :circle) : '特定'
  end

  def general(license_permission_type)
    license_permission_type == '一般' ? tag.span('一般', class: :circle) : '一般'
  end

  def construction_license_construction_type(ordinal_number, type, d_info)
    permission_type = c_license_permission_type_identification_or_general(ordinal_number, d_info)
    permission_type == type ? tag.span(type, class: :circle) : type
  end

  def engineer_skill_training(engineer, document) # 対象者を判定した後、資格内容を返す
    s_id = document&.content&.[]("#{engineer}_engineer_skill_training_id")
    s_id.blank? ? "" : SkillTraining.find(s_id).name
  end

  def foreign_exist(foreign_type, d_info, yes_no) # 「有」か「無」判定

    f_type = d_info&.content&.[]("subcon_#{foreign_type}")
    if f_type == "available"
      f_type = "有"
    elsif f_type == "not_available"
      f_type = "無"
    end

    f_type == yes_no ? tag.span(yes_no, class: :circle) : yes_no
  end

  def get_occupations_for_selected_industries
    industry_ids =
      if params.dig(:business, :tem_industry_ids)&.any? # 新規 - 業種のみ選択
        params[:business][:tem_industry_ids].map(&:to_i).compact
      elsif @business&.tem_industry_ids&.any? # 編集 - 既定選択
        @business.tem_industry_ids.map(&:to_i).compact
      elsif session[:tem_industry_ids]&.any? # 新規 - 業種＆職種を選択
        session[:tem_industry_ids].map(&:to_i).compact
      else # 一切未選択
        []
      end

    Occupation.where(industry_id: industry_ids)
  end

  def constr_license_info(ordinal_number, document_type, column)
    constr_count = document_type.construction_license.size
    if ordinal_number <= constr_count
      element = document_type.construction_license[(ordinal_number.to_i) -1]
      if column == "industry_name"
        constr_value = Industry.find(BusinessIndustry.find(element).industry_id).name.gsub("工事業", "")
        return constr_value
      else
        constr_value = BusinessIndustry.find(element).send("construction_license_#{column}")
        return constr_value
      end
    end
  end

  # (6)(7)安全衛生管理に関する契約書

  # 一次下請の情報
  def primary_subcon_info_for_6th
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    if request_order.parent_id.nil?
      RequestOrder.find_by(parent_id: request_order.id)
    elsif request_order.depth == 1
      request_order
    else
      while request_order.depth != 1
        request_order = RequestOrder.find(request_order.parent_id)
      end
      request_order
    end
  end

  # (8)作業員名簿


  # 会社の名前
  def company_name(worker_id)
    worker = Worker.find_by(uuid: worker_id)
    Business.find_by(id: worker&.business_id)&.name
  end

  # 作業員情報
  def worker(worker_uuid)
    Worker.find_by(uuid: worker_uuid)&.name
  end

  # 作業員名簿の見出し番号
  def worker_index(number, index)
    number + index * 10
  end

  # 作業員の文字情報
  def worker_str(worker, column)
    worker&.content&.[](column)
  end

  # 作業員の性別を日本語に変換
  def worker_str_sex(worker, gender_key)
    gender = worker&.content&.[](gender_key)
    case gender
    when 'man'
      '男性'
    when 'woman'
      '女性'
    else
      ''
    end
  end

  # 作業員の日付情報
  def worker_date(worker, column)
    date = worker&.content&.[](column)
    date.nil? ? '年　月　日' : l(date&.to_date, format: :long)
  end

  # 作業員の電話番号情報
  def worker_phone_number(worker, column)
    worker&.content&.[](column)
  end

  # 作業員の年齢情報
  def worker_age(worker)
    birth_day = worker&.content&.[]('birth_day_on')
    if birth_day.nil?
      ''
    else
      age = (worker.created_at.to_date.strftime('%Y%m%d').to_i - birth_day.to_date.strftime('%Y%m%d').to_i) / 10000
      "#{age}歳"
    end
  end

  # 作業員の建設業退職金共済制度情報
  def worker_kentaikyo(worker)
    kentaikyo = worker&.content&.[]('worker_insurance')&.[]('severance_pay_mutual_aid_type')
    kentaikyo == 'kentaikyo' ? tag.span('健', class: :severance_pay_mutual_aid) : '健'
  end

  def worker_tyutaikyo(worker)
    tyutaikyo = worker&.content&.[]('worker_insurance')&.[]('severance_pay_mutual_aid_type')
    tyutaikyo == 'tyutaikyo' ? tag.span('中', class: :severance_pay_mutual_aid) : '中'
  end

  def worker_other(worker)
    other = worker&.content&.[]('worker_insurance')&.[]('severance_pay_mutual_aid_type')
    other == 'other' ? tag.span('他', class: :severance_pay_mutual_aid) : '他'
  end

  def worker_none(worker)
    none = worker&.content&.[]('worker_insurance')&.[]('severance_pay_mutual_aid_type')
    none == 'none' ? tag.span('無', class: :severance_pay_mutual_aid) : '無'
  end

  # 退職金共済制度
  def construction_industry(business)
    business&.content&.[]('subcon_retirement_benefit_mutual_aid_status') == 'construction_industry' ? '有' : '無' # 建設業退職金共済制度の有無
  end

  def smaller_companies(business)
    business&.content&.[]('subcon_retirement_benefit_mutual_aid_status') == 'smaller_companies' ? '有' : '無' # 中小企業退職金共済制度
  end

  # 作業員の血圧情報
  def blood_pressure(worker)
    min = worker&.content&.[]('worker_medical')&.[]('min_blood_pressure')
    max = worker&.content&.[]('worker_medical')&.[]('max_blood_pressure')
    min.nil? || max.nil? ? '~' : "#{max} ~ #{min}"
  end

  # 作業員健康診断の日付情報
  def worker_medical_date(worker, column)
    date = worker&.content&.[]('worker_medical')&.[](column)
    date.nil? ? '年　月　日' : wareki(date.to_date)
  end

  # 作業員の血液型情報
  BLOOD_TYPE = {
    'a'  => 'A',
    'b'  => 'B',
    'ab' => 'AB',
    'o'  => 'O'
  }.freeze

  def worker_abo_blood_type(worker)
    blood_type = worker&.content&.[]('abo_blood_type')
    BLOOD_TYPE[blood_type]
  end

  # 作業員の保険情報
  INSURANCE = {
    'health_insurance_association'           => '健康保険組合',
    'japan_health_insurance_association'     => '協会けんぽ',
    'construction_national_health_insurance' => '建設国保',
    'national_health_insurance'              => '国民健康保険',
    'exemption'                              => '適応除外',
    'welfare'                                => '厚生年金',
    'national'                               => '国民年金',
    'recipient'                              => '受給者',
    'insured'                                => '被保険者',
    'day'                                    => '日雇保険'
  }.freeze

  def worker_insurance(worker, column)
    insurance = worker&.content&.[]('worker_insurance')&.[](column)
    insurance unless insurance.nil?
    INSURANCE[insurance]
  end

  # 作業員の特別健康診断の種類
  def worker_special_med_exam(worker)
    exams = worker&.content&.[]('worker_medical')&.[]('special_med_exam_list')
    unless exams.nil?
      exams = exams.map { |exam| SpecialMedExam.find(exam).name }
      exams.join(' ')
    end
  end

  # 作業員の特別健康診断の種類その他
  def worker_special_med_exam_other(worker)
    exam_other = worker&.content&.[]('worker_medical')&.[]('special_med_exam_others')
    exam_other unless exam_other.nil?
  end

  # 作業員の特別教育情報
  def worker_special_education(worker)
    educations = worker&.content&.[]('worker_special_educations')
    unless educations.nil?
      educations = educations.map { |education| SpecialEducation.find(education['special_education_id']).name }
      educations.to_s.gsub(/,|"|\[|\]/) { '' }
    end
  end

  # 作業員の技能講習情報
  def worker_skill_training(worker)
    trainings = worker&.content&.[]('worker_skill_trainings')
    unless trainings.nil?
      trainings = trainings.map { |training| SkillTraining.find(training['skill_training_id']).short_name }
      trainings.to_s.gsub(/,|"|\[|\]/) { '' }
    end
  end

  # 作業員の免許情報
  def worker_license(worker)
    licenses = worker&.content&.[]('worker_licenses')
    unless licenses.nil?
      licenses = licenses.map { |license| License.find(license['license_id']).name }
      licenses.to_s.gsub(/,|"|\[|\]/) { '' }
    end
  end

  def age_border(age) # 入場年月日をもとに（65歳以上か18歳未満の）作業員を絞り込み
    target_ids = []
    document_info.field_workers.where.not(admission_date_start: nil).each do |field_worker|
      birth_date = field_worker.content['birth_day_on'].to_date
      str_date = field_worker.admission_date_start.to_date # 入場日
      case age
      when 18
        border_date = str_date.prev_year(18) # 入場日から18年前の日付
        if border_date < birth_date
          target_ids.push field_worker.id
        end

      when 65
        border_date = str_date.prev_year(65) # 入場日から65年前の日付
        if border_date >= birth_date
          target_ids.push field_worker.id
        end
      end
    end
    target_ids
  end

  # 作業員の入場年月日
  def field_worker_admission_date(worker)
    date = worker&.admission_date_start
    date.blank? ? '年　月　日' : wareki(date)
  end

  # 作業員の受入教育実施年月日
  def field_worker_education_date(worker)
    date = worker&.education_date
    date.blank? ? '年　月　日' : wareki(date)
  end

  # 作業員の記号
  def field_worker_symbol(worker)
    if worker.present?
      id = worker&.content&.[]('id')
      birth_day_on = worker&.content&.[]('birth_day_on')
      safety_health_education = worker&.content&.[]('worker_safety_health_educations').to_json
      foreigner = worker&.content&.[]('status_of_residence')

      site_agent = "現" if id == document_info.content&.[]('subcon_site_agent_name_id') # (現)現場代理人
      work_chief = "作" if id == document_info.content&.[]('subcon_work_chief_name_id') # (作)作業主任者
      if birth_day_on .present?
        under_18 = "未" if ((Date.today - birth_day_on.to_date) / 365.25).to_i < 18 # (未)18歳未満の作業員
      end
      sex = "女" if worker&.content&.[]('sex') == "woman" # 女
      lead_engineer = "主" if id == document_info.content&.[]('subcon_lead_engineer_name_id') # (主)主任技術者
      foreman = "職" if id == document_info.content&.[]('subcon_foreman_name_id') # (主)主任技術者
      safety_manager = "安" if id == document_info.content&.[]('subcon_safety_manager_name_id') # (安)安全衛生責任者
      ability_improving_education = "歳" if safety_health_education.include?("19") # (歳)能力向上教育
      danger_harmful_business = "再" if safety_health_education.include?("6") # (再)危険有害業務・再発防止教育
      skill_practice = "習" if foreigner == "skill_practice" # (習)外国人技能実習生
      construction_employment = "就" if foreigner == "construction_employment" # (就)外国人建設就労者
      specified_skill = "1特" if foreigner == "specified_skill" # (1特)1号特定技能外国人

      worker_symbols = site_agent, work_chief, under_18, sex, lead_engineer, foreman, safety_manager, ability_improving_education, danger_harmful_business, skill_practice, construction_employment, specified_skill
      worker_symbols.size > 1 ? worker_symbols.join(' ') : worker_symbols
    end
  end

  # 作業員の職種
  def worker_occupation(worker)
    worker&.occupation_id.nil? ? nil : Occupation.find(worker.occupation_id).short_name
  end

    # (12)工事・通勤用車両届

  # 車両情報(工事･通勤)
  def car_usage_commute(usage)
    usage == '通勤用' ? tag.span('通勤', class: :circle) : '通勤'
  end

  def car_usage_const(usage)
    usage == '工事用' ? tag.span('工事', class: :circle) : '工事'
  end

  # (10)高齢者就労報告書/(11)年少者就労報告書

  def age_for_admission_date_start(worker) # 入場年月日を起点に年齢を算出
    if worker.present?
      date_format = '%Y%m%d'
      birth_date = FieldWorker.find(worker.id).content['birth_day_on'].to_date.strftime(date_format).to_i # 生年月日
      str_date = FieldWorker.find(worker.id).admission_date_start.strftime(date_format).to_i # 入場日
      (str_date - birth_date) / 10000
    end
  end

  def age_border(age) # 入場年月日をもとに（65歳以上か18歳未満の）作業員を絞り込み
    target_ids = []
    document_info.field_workers.where.not(admission_date_start: nil).each do |field_worker|
      birth_date = field_worker.content['birth_day_on'].to_date
      str_date = field_worker.admission_date_start.to_date # 入場日
      case age
      when 18
        border_date = str_date.prev_year(18) # 入場日から18年前の日付
        if border_date < birth_date
          target_ids.push field_worker.id
        end

      when 65
        border_date = str_date.prev_year(65) # 入場日から65年前の日付
        if border_date >= birth_date
          target_ids.push field_worker.id
        end
      end
    end
    target_ids
  end

  # (13)移動式クレーン/車両系建設機械等使用届

  # 特殊車両情報(自社･リース)
  def lease_type_own(type)
    type == 'own' ? tag.span('自社', class: :circle) : '自社'
  end

  def lease_type_lease(type)
    type == 'lease' ? tag.span('リース', class: :circle) : 'リース'
  end

  # 特殊車両情報(区分)
  def vehicle_type_crane(type)
    type == 'crane' ? tag.span('移動式クレーン', class: :circle) : tag.span('移動式クレーン', class: :line_through)
  end

  def vehicle_type_construction(type)
    type == 'construction' ? tag.span('車両系建設機械', class: :circle) : tag.span('車両系建設機械', class: :line_through)
  end

  # (15)有機溶剤・特定化学物質等持込使用届

  # 作業手順書の添付の有・無
  def field_solvent_working_process_y(working_process)
    working_process == 'y' ? tag.span('有', class: :circle) : '有'
  end

  def field_solvent_working_process_n(working_process)
    working_process == 'n' ? tag.span('無', class: :circle) : '無'
  end

  # SDSの添付の有・無
  def field_solvent_sds_y(sds)
    sds == 'y' ? tag.span('有', class: :circle) : '有'
  end

  def field_solvent_sds_n(sds)
    sds == 'n' ? tag.span('無', class: :circle) : '無'
  end

  # (16)火気使用届

  # 現場火気情報(使用目的)
  def fire_use_target(name, num)
    fires = document_info.field_fires
    if fires.present?
      fires.first.fire_use_targets.map(&:id).include?(num) ? tag.span(name, class: :fire_check) : name
    else
      name
    end
  end

  # 現場火気情報(火気の種類)
  def fire_type(name, num)
    fires = document_info.field_fires
    if fires.present?
      fires.first.fire_types.map(&:id).include?(num) ? tag.span(name, class: :fire_check) : name
    else
      name
    end
  end

  # 現場火気情報(火気の管理方法)
  def fire_management(name, num)
    fires = document_info.field_fires
    if fires.present?
      fires.first.fire_managements.map(&:id).include?(num) ? tag.span(name, class: :fire_check) : name
    else
      name
    end
  end

  # (17)下請負業者編成表

  # 特定専門工事の有無(有･無)
  def professional_construction_yes(type)
    type == 'y' ? tag.span('有', class: :circle) : '有'
  end

  def professional_construction_no(type)
    type == 'n' ? tag.span('無', class: :circle) : '無'
  end

  # 二次下請会社情報
  def secondary_subcon_info(document_info, child_id)
    if document_info.instance_of?(Order)
      nil
    elsif document_info.child_ids[child_id].nil?
      nil
    else
      RequestOrder.find(document_info.child_ids[child_id])
    end
  end

  # 三次下請以下の会社情報
  def hierarchy_subcon_info(document_info, hierarchy, child_id) # hierarchyは階層の深さを指定する
    if document_info.instance_of?(Order)
      nil
    elsif document_info.find_all_by_generation(hierarchy).nil?
      nil
    elsif document_info.find_all_by_generation(hierarchy).ids[child_id]
      RequestOrder.find(document_info.find_all_by_generation(hierarchy).ids[child_id])
    end
  end

  # (13)移動式クレーン/車両系建設機械等使用届,(16)火気使用届,(17)下請負業者編成表

  # 一次下請会社名の情報
  def primary_subcon_info(document_info)
    if document_info.instance_of?(Order)
      nil
    elsif document_info.ancestors.count > 1
      RequestOrder.find(document_info.ancestor_ids[-2])
    elsif document_info.ancestors.count == 1
      document_info.content.nil? ? nil : document_info
    end
  end

  # (18)工事作業所災害防止協議会兼施工体系図

  # RequestOrderの情報を取得する
  def request_order_info(id)
    RequestOrder.find(id) if id.present?
  end

  # 三次下請け(1行目表示用)
  def provisional_tertiary_subcon_info(tertiary_id, quaternary_id)
    if tertiary_id.present?
      request_order_info(tertiary_id)
    else
      request_order_info(request_order_info(quaternary_id)&.parent_id)
    end
  end

  # 二次下請け(1行目表示用)
  def provisional_secondary_subcon_info(secondary_id,tertiary_id,quaternary_id)
    if secondary_id.present?
      request_order_info(secondary_id)
    else
      request_order_info(provisional_tertiary_subcon_info(tertiary_id, quaternary_id)&.parent_id)
    end
  end

  # 一次下請け(1行目表示用)
  def provisional_primary_subcon_info(primary_id,secondary_id,tertiary_id,quaternary_id)
    if primary_id.present?
      request_order_info(primary_id)
    else
      request_order_info(provisional_secondary_subcon_info(secondary_id,tertiary_id,quaternary_id)&.parent_id)
    end
  end

  # 一次下請け会社名の取得
  def primary_subcon_business_name
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    Business.joins(:request_orders).where(request_orders: { parent_id: request_order.id }).pluck(:name)
  end

  # (20)年間安全衛生計画書

  # 下請現場情報のidの取得
  def request_order_id
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid]).id
  end

  # 代表者名の役職取得
  def representative_name(business_id)
    Business.find(business_id).representative_name
  end

  # 作業員の役職取得
  def workers_post(worker_name)
    Worker.find_by(name: worker_name)&.job_title
  end

  # 和暦表示(date_select用)
  def date_select_ja(src_html)
    dst_html = src_html.gsub(/>\d{4}</) do |m|
      year = m.match(/>(\d{4})</)[1].to_i
      year_ja = case year
                when 2018
                  '平成30/令和元年'
                else
                  "令和#{year - 2018}"
                end
      ">#{year_ja}<"
    end
    dst_html.html_safe
  end

  # 和暦表示(年表示)
  def doc_ja_y_date(cont, column)
    date = cont.content&.[](column)
    date.blank? ? '' : l(date.to_date, format: :ja_y)
  end

  # 和暦表示(年月表示)
  def doc_ja_ym_date(cont, column)
    date = cont.content&.[](column)
    date.blank? ? '' : l(date.to_date, format: :ja_ym)
  end

  # 年月日表示
  def doc_ymd_date(cont, column)
    date = cont.content&.[](column)
    date.blank? ? '' : l(date.to_date, format: :long)
  end

  #現場作業員の人数の取得
  def number_of_field_workers(order)
    #元請の作業員の人数
    prime_contractor = FieldWorker.where(field_workerable_type: Order).where(field_workerable_id: order.id)
    prime_contractor.nil? ? number_of_prime_contractor = 0 : number_of_prime_contractor = prime_contractor.size
    #一次下請け以下の作業員の人数
    request_order = RequestOrder.where(order_id: order.id)
      array = []
      request_order.each do |record|
        array << record.id
      end
    number_of_primary_subcontractor = FieldWorker.where(field_workerable_type: RequestOrder).where("field_workerable_id IN (?)", array).size
    return (number_of_prime_contractor + number_of_primary_subcontractor)
  end

  # (22)作業間連絡調整書

  #下請会社(協力会社)のbusiness_idの取得
  def subcontractor_business_id(number)
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    request_order_list = RequestOrder.where(order_id: request_order.order_id).where.not(parent_id: nil)
    subcontractor_array = []
    request_order_list.each do |record|
      subcontractor_array << record.business_id
    end
    subcontractor_array.slice(number) if subcontractor_array[number].present?
  end

  #会社名の取得
  def subcontractor_name(id)
    Business.find(id).name if id.present?
  end

  #下請会社(協力会社)の職種名の取得
  def subcontractor_occupation(id)
    RequestOrder.find_by(business_id: id).occupation if id.present?
  end

  #入場作業員の人数の取得
  def number_of_field_workers_of_subcontractor(id)
    request_order_id = RequestOrder.find_by(business_id: id)&.id
    number_of_workers = FieldWorker.where(field_workerable_type: RequestOrder).where(field_workerable_id: request_order_id).size
    if number_of_workers == 0
      return nil
    else
      return number_of_workers
    end
  end

  #自社の作業員の名前を取得
  def name_of_workers
    current_business = RequestOrder.find_by(uuid: params[:request_order_uuid])
    Worker.where(business_id: current_business.business_id).pluck(:name)
  end

  #元請の作業員の名前を取得
  def name_of_genecon_workers
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    while request_order.parent_id.present?
      request_order = RequestOrder.find(request_order.parent_id)
    end
    genecon_id = request_order.business_id
    Worker.where(business_id: genecon_id).pluck(:name)
  end

  #下請けの作業員の名前を取得
  def name_of_subcon_workers(business_id)
    Worker.where(business_id: business_id).pluck(:name)
  end

  #元請・下請け以下の入場作業員の取得
  def name_of_field_workers_request_order(id)
    request_order_id = RequestOrder.find_by(business_id: id)&.id
    field_workers_name_request_order = FieldWorker.where(field_workerable_type: RequestOrder).where(field_workerable_id: request_order_id).pluck(:admission_worker_name)
  end

  # document.contentの時間表示
  def doc_content_time(time)
    time.nil? ? "" : time # nilの場合のstrftime表示エラー回避
  end

  #月日表示
  def doc_md_date(cont, column)
    date = cont.content&.[](column)
    date.blank? ? '' : l(date.to_date, format: :long2)
  end

  #時分表示
  def doc_hm_time(cont, column)
    date = cont.content&.[](column)
    date.blank? ? '' : l(date.to_datetime, format: :kan_hm)
  end

  #時表示(時は含めない)
  def doc_h_time(cont, column)
    date = cont.content&.[](column)
    date.blank? ? '' : l(date.to_datetime, format: :h)
  end

  #曜日表示
  def day_of_week(date)
    date.blank? ? '' : %w{日 月 火 水 木 金 土}[(date.to_date).wday]
  end

  # チェックボックスにチェックが入っているかを判別
  def box_checked?(checked_status)
    return true if checked_status == '1'
  end

  def checked_box(checked_status)
    if checked_status == '1'
      '☑︎'
    else
      '▢'
    end
  end

  #  ➈外国人建設就労者建設現場入場届出書
  # 'status_of_residence'に'construction_employment'が入っていた場合「特定活動(外国人建設就労者)」にチェックを入れる
  def checked_box_construction_employment(checked_status)
    if checked_status == 'construction_employment'
      '☑︎'
    else
      '▢'
    end
  end

  #  ➈外国人建設就労者建設現場入場届出書
  # 'status_of_residence'に'specified_skill'が入っていた場合「特定技能」にチェックを入れる
  def checked_box_specified_skill(checked_status)
    if checked_status == 'specified_skill'
      '☑︎'
    else
      '▢'
    end
  end

  #  ➈外国人建設就労者建設現場入場届出書
  # 'confirmed_check_date'に日付が入っていた場合「確認済み」にチェックを入れる
  def checked_box_confirmed_check_date(checked_status)
    if checked_status.present? && checked_status != 'false'
      '☑︎'
    else
      '▢'
    end
  end

  def checked_none_box(checked_status)
    '✓' if checked_status == '1'
  end

  # リスクの見積り
  def risk_estimation_level(risk_possibility, risk_seriousness)
    possibility_point, _possibility_comment = risk_possibility(risk_possibility)
    seriousness_point, _seriousness_comment = risk_seriousness(risk_seriousness)

    if risk_possibility.nil? || risk_seriousness.nil?
      ''
    else
      (possibility_point + seriousness_point)
    end
  end

  # 重大性
  def risk_seriousness_level(risk_possibility, risk_seriousness)
    possibility_point, _possibility_comment = risk_possibility(risk_possibility)
    seriousness_point, _seriousness_comment = risk_seriousness(risk_seriousness)

    if risk_possibility.nil? || risk_seriousness.nil?
      ''
    else
      (possibility_point + seriousness_point - 1)
    end
  end

  # リスクの見積りコメント
  def risk_estimation_comment(risk_possibility)
    _possibility_point, possibility_comment = risk_possibility(risk_possibility)
    possibility_comment
  end

  # リスクの重大性コメント
  def risk_seriousness_comment(risk_seriousness)
    _seriousness_point, seriousness_comment = risk_seriousness(risk_seriousness)
    seriousness_comment
  end

  # n次下請のn算出
  def subcontractor_num(worker_uuid, second_workers, third_workers, _forth_workers)
    second_workers_uuid = []
    third_workers_uuid = []
    forth_workers_uuid = []

    second_workers&.each do |second_worker|
      second_workers_uuid.push(second_worker.uuid)
    end

    third_workers&.each do |third_worker|
      third_workers_uuid.push(third_worker.uuid)
    end

    if second_workers_uuid.include?(worker_uuid)
      '2'
    elsif third_workers_uuid.include?(worker_uuid)
      '3'
    elsif forth_workers_uuid.include?(worker_uuid)
      '4'
    else
      ''
    end
  end

  def safety_and_health_construction_policy_example
    <<-"RUBY".strip_heredoc
    例)当社及び作業所の安全衛生ルールを遵守。
       特定した危険有害要因に対しての実施事項。
       (除去・低減策)の実施。作業開始前、 作業中の安全状態の指差し確認。
    RUBY
  end

  def safety_and_health_construction_objective_example
    <<-"RUBY".strip_heredoc
    例)墜落危険作業では安全帯を使用 (使用率 100%) する。
       移動式クレーン災害ゼロの実現のため、移動式クレーンの旋回範囲への立入禁止、アウトリガーの張出し、適正な玉掛けを徹底する。
       KY 活動における 「私たちはこうする」 を全員で遵守し、 不安全行動を排除する。
    RUBY
  end

  def daily_safety_and_health_activity_example
    <<-"RUBY".strip_heredoc
    例)・安全ミーティング
        ・KYK#{' '}
        ・作業中の指揮・監督#{' '}
        ・安全工程打合せ会#{' '}
        ・終業時片付け#{' '}
        ・作業終了報告#{' '}
    RUBY
  end

  def risk_reduction_measures_example
    <<-"RUBY".strip_heredoc
    例)1 設置地盤に凸凹、傾斜等がある場合は、地盤を整地するか角材等により水平にする。
         2 地耐力不足の場合は、地盤改良、敷き鉄板等で補強する。
    RUBY
  end

  # (23)全建統一様式第８号(安全ミーティング報告書)

  # 一次下請の情報 (安全ミーティング報告書)
  def document_subcon_info_for_23rd
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    # 元請が下請の書類確認するとき
    if params[:sub_request_order_uuid] && request_order.parent_id.nil?
      RequestOrder.find_by(uuid: params[:sub_request_order_uuid])
    # 下請けが自身の書類確認するとき
    elsif request_order.parent_id && request_order.parent_id == request_order.parent&.id
      request_order
      # 下請けが存在しない場合
    end
  end

  # リスクの見積り点数
  def risk_estimation_point(risk_possibility)
    possibility_point, _possibility_comment = risk_possibility(risk_possibility)
    possibility_point == 0 ? "" : possibility_point
  end

  # リスクの重大性点数
  def risk_seriousness_point(risk_seriousness)
    seriousness_point, _seriousness_comment = risk_seriousness(risk_seriousness)
    seriousness_point == 0 ? "" : seriousness_point
  end

  # 丸囲み文字
  def make_circle_enclosure_number(number)
    number.blank? ? tag.span('&nbsp;'.html_safe, class: :circle_hankaku_space) : tag.span(number, class: :circle_hankaku_number)
  end

  # 角囲み文字
  def make_square_enclosure_number(number)
    number.blank? ? tag.span('&nbsp;'.html_safe , class: :square_hankaku_space) : tag.span(number, class: :square_hankaku_number)
  end


  # (24)新規入場者調査票

  # 雇用契約書-「有り」
  def employment_contract_yes(worker)
    contract_status = worker&.content&.[]('employment_contract')
    contract_status == 'available' ? tag.span('1. 取り交わし済', class: :circle) : '1. 取り交わし済'
  end

  # 雇用契約書-「無し」
  def employment_contract_no(worker)
    contract_status = worker&.content&.[]('employment_contract')
    contract_status == 'not_available' ? tag.span('2. 未だ', class: :circle) : '2. 未だ'
  end

  # アンケート設問：（法人規模-「はい」）
  def questionnaire_business_type_yes(worker)
    w_name = worker&.content&.[]('name')
    r_name = document_info&.content&.[]("subcon_representative_name")
    if worker.content&.[]('business_owner_or_master') == true
      tag.span('1. はい', class: :circle)
    elsif w_name == r_name
      company_status = document_info&.content&.[]("subcon_business_type")
      company_status != '法人' ? tag.span('1. はい', class: :circle) : '1. はい'
    else
      '1. はい'
    end
  end

  # アンケート設問：（法人規模-「いいえ」）
  def questionnaire_business_type_no(worker)
    w_name = worker&.content&.[]('name')
    r_name = document_info&.content&.[]("subcon_representative_name")
    if worker.content&.[]('business_owner_or_master') == true
      '2. いいえ'
    elsif w_name != r_name
      tag.span('2. いいえ', class: :circle)
    else
      company_status = document_info&.content&.[]("subcon_business_type")
      company_status == '法人' ? tag.span('2. いいえ', class: :circle) : '2. いいえ'
    end
  end

  # アンケート設問：（労災保険-「はい」）
  def questionnaire_labor_insurance_yes(worker)
    company_status = document_info&.content&.[]("subcon_business_type")
    insurance_status = worker&.content&.[]('worker_insurance')['has_labor_insurance']

    if questionnaire_business_type_yes(worker) == tag.span('1. はい', class: :circle)
      insurance_status == 'join' ? tag.span('1. はい', class: :circle) : '1. はい'
    else
      '1. はい'
    end
  end

  # アンケート設問：（労災保険-「いいえ」）
  def questionnaire_labor_insurance_no(worker)
    insurance_status = worker&.content&.[]('worker_insurance')['has_labor_insurance']

    if questionnaire_business_type_yes(worker) == tag.span('1. はい', class: :circle)
      insurance_status != "join" ? tag.span('2. いいえ', class: :circle) : '2. いいえ'
    else
      '2. いいえ'
    end
  end

  # アンケート設問：（就業年数-基準値）
  def questionnaire_experience_term_calc(worker)
    date_format = '%Y%m%d'
    admission_date = worker.admission_date_start&.strftime(date_format).to_i
    hiring_date = worker.content['hiring_on'].to_date&.strftime(date_format).to_i
    hiring_on_term = (admission_date - hiring_date) / 10000
    experience_term_before_hiring = worker.content['experience_term_before_hiring'].to_i
    blank_term = worker.content['blank_term'].to_i
    return hiring_on_term + experience_term_before_hiring - blank_term
  end

  # アンケート設問：（就業年数-「1年未満」）
  def questionnaire_experience_term_short(worker)
    experience_term = questionnaire_experience_term_calc(worker)
    experience_term < 1 ? tag.span('1. 1年以内', class: :circle) : '1. 1年以内'
  end

  # アンケート設問：（就業年数-「1年以上から3年未満」）
  def questionnaire_experience_term_middle(worker)
    experience_term = questionnaire_experience_term_calc(worker)
    experience_term >= 1 && experience_term < 3 ? tag.span('2. 1～3年', class: :circle) : '2. 1～3年'
  end

  # アンケート設問：（就業年数-「3年以上」）
  def questionnaire_experience_term_long(worker)
    experience_term = questionnaire_experience_term_calc(worker)
    experience_term >= 3 ? tag.span('3. 3年以上', class: :circle) : '3. 3年以上'
  end

  # アンケート設問：（健康診断-「はい」）
  def questionnaire_health_exam_yes(worker)
    health_exam_status = worker&.content&.[]('worker_medical')['is_med_exam']
    health_exam_status == 'y' ? tag.span('1. 受けた', class: :circle) : '1. 受けた'
  end

  # アンケート設問：（健康診断-「いいえ」）
  def questionnaire_health_exam_no(worker)
    health_exam_status = worker&.content&.[]('worker_medical')['is_med_exam']
    health_exam_status == 'n' ? tag.span('2. 受けていない', class: :circle) : '2. 受けていない'
  end

  # アンケート設問：（健康状態-「よい」）
  def questionnaire_health_condition_good(worker)
    health_condition_status = worker&.content&.[]('worker_medical')['health_condition']
    health_condition_status == 'good' ? tag.span('1. よい', class: :circle) : '1. よい'
  end

  # アンケート設問：（健康状態-「まあまあである」）
  def questionnaire_health_condition_normal(worker)
    health_condition_status = worker&.content&.[]('worker_medical')['health_condition']
    health_condition_status == 'normal' ? tag.span('2. まあまあである', class: :circle) : '2. まあまあである'
  end

  # アンケート設問：（健康状態-「あまりよくない」）
  def questionnaire_health_condition_bad(worker)
    health_condition_status = worker&.content&.[]('worker_medical')['health_condition']
    health_condition_status == 'bad' ? tag.span('3. あまりよくない', class: :circle) : '3. あまりよくない'
  end

  # アンケート設問：（送り出し教育-「はい」）
  def questionnaire_sendoff_education_yes(worker)
    sendoff_status = worker.sendoff_education
    sendoff_status == 'educated' ? tag.span('1. はい', class: :circle) : '1. はい'
  end

  # アンケート設問：（送り出し教育-「いいえ」）
  def questionnaire_sendoff_education_no(worker)
    sendoff_status = worker.sendoff_education
    sendoff_status == 'not_educated' ? tag.span('2. いいえ', class: :circle) : '2. いいえ'
  end

  # 資格-技能講習-作業主任者-その他枠
  def worker_skill_training_work_other(worker)
    trainings = worker&.content&.[]('worker_skill_trainings')

    unless trainings.nil?
      trainings = trainings.map { |training| SkillTraining.find(training['skill_training_id']).short_name }
      trainings.to_s.gsub(/,|"|\[|\]/) { '' }
      no_work =
        %w[整地 基礎 解体 不整 高所 フォ ショ 小ク 床ク
           ガス 玉掛 コ破 地山 石綿 有機 型枠 足場 ボ取 コ解 酸欠]
      trainings.delete_if do |t_work|
        no_work.include?(t_work)
      end
    end

    trainings2 = trainings
    if trainings2.present?
      "■その他( #{trainings2.join(' / ')} )"
    else
      '▢その他（　　　　　　　　　　）'
    end
  end

  # 資格-特別教育-酸素欠乏危険作業枠
  def worker_special_education_oxygen(worker)
    text = ['酸素欠乏（1種）', '酸素欠乏（2種）']
    (text & worker_special_education(worker).split).present? ? '■酸素欠乏危険作業' : '▢酸素欠乏危険作業'
  end

  # 資格-特別教育-電気取扱枠
  def worker_special_education_electrical(worker)
    text = ['低圧電気取扱', '低圧電気取扱（開閉器の操作）', '高圧電気取扱', '特別高圧電気取扱']
    (text & worker_special_education(worker).split).present? ? '■電気取扱' : '▢電気取扱'
  end

  # 資格-特別教育-その他枠
  def worker_special_education_other(worker)
    educations = worker&.content&.[]('worker_special_educations')

    unless educations.nil?
      educations = educations.map { |education| SpecialEducation.find(education['special_education_id']).name }
      educations.to_s.gsub(/,|"|\[|\]/) { '' }
      no_education =
        %w[酸素欠乏（1種） 酸素欠乏（2種） 小型車両系建設機械（整地・運搬・積込み用及び掘削用）（3t未満）
           小型車両系建設機械（基礎工事用）（3t未満） ローラー 車両系建設機械（コンクリート打設用）
           小型車両系建設機械（解体用）（3t未満） 不整地運搬車（1t未満） 高所作業車(10m未満）
           ボーリングマシン フォークリフト（1t未満） ショベルローダー（1t未満） 巻上げ機 建設用リフト
           玉掛け（1t未満） ゴンドラ アーク溶接 研削砥石 低圧電気取扱 低圧電気取扱（開閉器の操作） 高圧電気取扱
           特別高圧電気取扱 足場の組立て ロープ高所作業 フルハーネス型の墜落制止用器具 ロングエレベーター
           石綿取扱い作業従事者特別教育講師]
      educations.delete_if do |e_work|
        no_education.include?(e_work)
      end
    end

    educations2 = educations
    if educations2.present?
      "■その他( #{educations2.join(' / ')} )"
    else
      '▢その他（　　　　　　　　　　）'
    end
  end

  def wareki(date)
    date.blank? ? '年　月　日' : l(date.to_date, format: :ja_kan)
  end

  # 作業員職種情報
  def worker_occupations(business)
    business.occupations.pluck(:name).join(', ')
  end

  # (14) 持込機械の機械名情報（持込時の点検表）
  def machine_tag_1st(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('アース線') ? '✔' : ''
    end
  end

  def machine_tag_2nd(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('接地クランプ') ? '✔' : ''
    end
  end

  def machine_tag_3rd(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('キャップタイヤ') ? '✔' : ''
    end
  end

  def machine_tag_4th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('コネクタ') ? '✔' : ''
    end
  end

  def machine_tag_5th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('接地端子の締結') ? '✔' : ''
    end
  end

  def machine_tag_6th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('充電部の絶縁') ? '✔' : ''
    end
  end

  def machine_tag_7th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('自動電撃防止装置') ? '✔' : ''
    end
  end

  def machine_tag_8th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('絶縁ホルダー') ? '✔' : ''
    end
  end

  def machine_tag_9th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('溶接保護面') ? '✔' : ''
    end
  end

  def machine_tag_10th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('操作スイッチ') ? '✔' : ''
    end
  end

  def machine_tag_11th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('絶縁抵抗測定値') ? '✔' : ''
    end
  end

  def machine_tag_12th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('各種ブレーキの作動') ? '✔' : ''
    end
  end

  def machine_tag_13th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('手すり・囲い') ? '✔' : ''
    end
  end

  def machine_tag_14th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('フックのはずれ止め') ? '✔' : ''
    end
  end

  def machine_tag_15th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('ワイヤロープ･チェーン') ? '✔' : ''
    end
  end

  def machine_tag_16th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('滑車') ? '✔' : ''
    end
  end

  def machine_tag_17th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('回転部の囲い等') ? '✔' : ''
    end
  end

  def machine_tag_18th(machine)
    tags = machine&.content&.[]('machine_tags')
    unless tags.nil?
      tags = tags.map { |tag| Tag.find(tag['tag_id']).name }
      tags.include?('危険表示') ? '✔' : ''
    end
  end

  # 持込時の点検表　「追加項目①〜⑥」点検事項
  def inspection_table_item1
    field_machines = FieldMachine.find(document_info.field_machine_ids)
    inspection_table_item1 = field_machines.map { |field_machine| FieldMachine.find(field_machine.id).content.[]('extra_inspection_item1') }.compact_blank.first
  end

  def inspection_table_item2
    field_machines = FieldMachine.find(document_info.field_machine_ids)
    inspection_table_item1 = field_machines.map { |field_machine| FieldMachine.find(field_machine.id).content.[]('extra_inspection_item2') }.compact_blank.first
  end

  def inspection_table_item3
    field_machines = FieldMachine.find(document_info.field_machine_ids)
    inspection_table_item1 = field_machines.map { |field_machine| FieldMachine.find(field_machine.id).content.[]('extra_inspection_item3') }.compact_blank.first
  end

  def inspection_table_item4
    field_machines = FieldMachine.find(document_info.field_machine_ids)
    inspection_table_item1 = field_machines.map { |field_machine| FieldMachine.find(field_machine.id).content.[]('extra_inspection_item4') }.compact_blank.first
  end

  def inspection_table_item5
    field_machines = FieldMachine.find(document_info.field_machine_ids)
    inspection_table_item1 = field_machines.map { |field_machine| FieldMachine.find(field_machine.id).content.[]('extra_inspection_item5') }.compact_blank.first
  end

  def inspection_table_item6
    field_machines = FieldMachine.find(document_info.field_machine_ids)
    inspection_table_item1 = field_machines.map { |field_machine| FieldMachine.find(field_machine.id).content.[]('extra_inspection_item6') }.compact_blank.first
  end

  # 持込時の点検表　「追加項目①〜⑥」番号（機械名）
  def machine_extra_inspection_item1(machine, column)
    extra_item1 = machine&.content&.[](column)
    unless inspection_table_item2.nil?
      extra_item1 == inspection_table_item1 ? '✔' : ''
    end
  end

  def machine_extra_inspection_item2(machine, column)
    extra_item2 = machine&.content&.[](column)
    unless inspection_table_item2.nil?
      extra_item2 == inspection_table_item2 ? '✔' : ''
    end
  end

  def machine_extra_inspection_item3(machine, column)
    extra_item3 = machine&.content&.[](column)
    unless inspection_table_item3.nil?
      extra_item3 == inspection_table_item3 ? '✔' : ''
    end
  end

  def machine_extra_inspection_item4(machine, column)
    extra_item4 = machine&.content&.[](column)
    unless inspection_table_item4.nil?
      extra_item4 == inspection_table_item4 ? '✔' : ''
    end
  end

  def machine_extra_inspection_item5(machine, column)
    extra_item5 = machine&.content&.[](column)
    unless inspection_table_item5.nil?
      extra_item5 == inspection_table_item5 ? '✔' : ''
    end
  end

  def machine_extra_inspection_item6(machine, column)
    extra_item6 = machine&.content&.[](column)
    unless inspection_table_item6.nil?
      extra_item6 == inspection_table_item6 ? '✔' : ''
    end
  end

  # 持込機械の文字情報
  def machine_str(machine, column)
    machine&.content&.[](column)
  end

  # 持込機械の文字情報　（編集ページで入力、documentsに保存）
  def machine_doc_str(doc_str)
    doc_str.blank? ? '' : doc_str
  end

  # 持込機械の日付情報（西暦）　（編集ページで入力、documentsに保存）
  def machine_doc_date(doc_date)
    if doc_date.blank? # documentのcontentがない場合のエラー回避（編集ページ初回表示）
      '年　月　日'
    else
      doc_date.blank? ? '年　月　日' : l(doc_date.to_date, format: :long)
    end
  end

  # 書類の背景色
  def document_background_color(genecon, subcon)
    controller.controller_path == 'users/sub_request_orders/documents' ? genecon : subcon
  end

  # (21) 新規入場時等教育実施報告書

  # 受講者氏名の時間情報　（編集ページで入力、documentsに保存）
  def implementation_time(time)
    time.blank? ? '時' : l(time.to_datetime, format: :hours_only)
  end

  # 教育の種類の新規入場時
  def newly_entrance_check(newly_entrance)
    newly_entrance == '1' ? tag.span('新規入場時', class: :circle) : '新規入場時'
  end

  # 教育の種類の雇入時
  def employer_in_check(employer_in)
    employer_in == '1' ? tag.span('雇入時', class: :circle) : '雇入時'
  end

  # 教育の種類の作業変更時
  def work_change_check(work_change)
    work_change == '1' ? tag.span('作業変更時', class: :circle) : '作業変更時'
  end

  private

  # リスクの可能性
  def risk_possibility(risk_possibility)
    case risk_possibility
    when 'low'
      possibility_point = 1
      possibility_comment = 'ほとんどない'
    when 'middle'
      possibility_point = 2
      possibility_comment = '可能性がある'
    when 'high'
      possibility_point = 3
      possibility_comment = '極めて高い'
    else
      possibility_point = 0
      possibility_comment = ''
    end
    [possibility_point, possibility_comment]
  end

  # リスクの重大性
  def risk_seriousness(risk_seriousness)
    case risk_seriousness
    when 'low'
      seriousness_point = 1
      seriousness_comment = '軽微'
    when 'middle'
      seriousness_point = 2
      seriousness_comment = '重大'
    when 'high'
      seriousness_point = 3
      seriousness_comment = '極めて重大'
    else
      seriousness_point = 0
      seriousness_comment = ''
    end
    [seriousness_point, seriousness_comment]
  end

  # 下請発注情報詳細画面

  # 現場情報-特殊車両-資格内容
  def target_license(worker_id)
      worker = Worker.find_by(id: worker_id)
    if worker.present?
      skill_tr_table = worker.skill_trainings.where(driving_related: 1)
      sp_education_table = worker.special_educations.where(driving_related: 1)
      dr_license_table = worker.driver_licences
      tem_table = skill_tr_table + sp_education_table
      tem_table.pluck(:name) + dr_license_table
    else
      "作業員を選択してください。"
    end
  end

  def use_company_info(target)
    if target == "company"
      @field_special_vehicles.distinct.pluck(:use_company_name)
    elsif target == "person"
      @field_special_vehicles.distinct.pluck(:use_company_representative_name)
    end
  end

  # 自身の書類一覧取得
  def current_user_documents(request_order)
    case request_order.depth
    when 0
      @genecon_documents
    when 1
      @first_subcon_documents
    when 2
      @second_subcon_documents
    else
      @third_or_later_subcon_documents
    end
  end

  # 自身の一つ下の階層の書類一覧取得
  def current_lower_first_documents_type(request_order)
    case request_order.depth
    when 1
      # 自身が元請けの場合：閲覧可能な一次下請け書類一覧
      RequestOrder.find_by(uuid: request_order.uuid).documents.current_lower_first_documents_type
    when 2
      # 自身が一次下請けの場合：閲覧可能な二次下請け書類一覧
      RequestOrder.find_by(uuid: request_order.uuid).documents.first_lower_second_documents_type
    when 3, 4
      # 自身が二次下請け以降の場合：閲覧可能な三次下請け以降の書類一覧
      RequestOrder.find_by(uuid: request_order.uuid).documents.lower_other_documents_type
    end
  end

  # 自身の二つ下の階層の書類一覧取得
  def current_lower_second_documents_type(request_order)
    case request_order.depth
    when 2
      # 自身が元請けの場合：閲覧可能な二次下請け書類一覧
      RequestOrder.find_by(uuid: request_order.uuid).documents.first_lower_second_documents_type
    when 3, 4
      # 自身が一次下請けの場合：閲覧可能な三次下請け以降の書類一覧
      RequestOrder.find_by(uuid: request_order.uuid).documents.lower_other_documents_type
    end
  end

  # 自身の三つ下以降の階層の書類一覧取得
  def current_lower_other_documents_type(request_order)
    case request_order.depth
    when 3, 4
      # 自身が元請けの場合：閲覧可能な三次下請け以降の書類一覧
      RequestOrder.find_by(uuid: request_order.uuid).documents.lower_other_documents_type
    end
  end

  # 元請けが下請け書類に記入が必要な場合の下請けshow画面へのリンク表示
  def lower_show_link(request_order_uuid, hierarchy_request_order_uuid, hierarchy_document)
    url = users_request_order_sub_request_order_document_path(request_order_uuid, hierarchy_request_order_uuid, hierarchy_document)

    if @request_order.order.business_id == @current_business.id
      case hierarchy_document.document_type
      when 'doc_13th'
        link_to '確認・点検事項 記入', url
      when 'doc_14th', 'doc_15th'
        link_to '確認事項 記入', url
      when 'doc_16th'
        link_to '確認・火気使用許可事項 記入', url
      end
    end
  end

  #doc_9
  # 自身の一つ上階層の会社情報&現場情報取得
  def get_myself_and_myparent_site
    request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
    if request_order.prime_contractor?
      @parent_request_order = nil
      @parent_business = nil
    else
      @parent_request_order = request_order.parent
      @parent_business = @parent_request_order.business
    end
  end
  # rubocop:enable all
end
