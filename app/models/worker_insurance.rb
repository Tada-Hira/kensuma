class WorkerInsurance < ApplicationRecord
  belongs_to :worker

  enum health_insurance_type: {
    health_insurance_association:           0,
    japan_health_insurance_association:     1,
    construction_national_health_insurance: 2,
    national_health_insurance:              3,
    exemption:                              4,
    not_health_insurance:                   5
  }, _prefix: true

  enum pension_insurance_type: {
    welfare:        0,
    national:       1,
    recipient:      2,
    not_applicable: 3
  }, _prefix: true

  enum employment_insurance_type: {
    insured:   0,
    day:       1,
    exemption: 2
  }, _prefix: true

  enum severance_pay_mutual_aid_type: {
    kentaikyo: 0,
    tyutaikyo: 1,
    none:      2,
    other:     3
  }, _prefix: true

  enum has_labor_insurance: { join: 0, not_join: 1 }, _prefix: true # 労働保険特別加入の有無

  with_options unless: -> { worker.business&.user&.is_prime_contractor == true } do
    validates :health_insurance_type, presence: true
    validates :pension_insurance_type, presence: true
    validates :employment_insurance_type, presence: true
    validates :employment_insurance_type, absence: true, if: :business_owner_or_master
    validates :severance_pay_mutual_aid_type, presence: true
  end
  validates :health_insurance_name, presence: true, if: :insurance_name_valid?
  validates :health_insurance_name, absence: true, unless: :insurance_name_valid?
  validates :employment_insurance_number, length: { maximum: 4 }, format: { with: /\A[0-9｡-ﾟ]+\z/, message: 'は数字と半角カタカナのみ使用できます' }, if: :employment_insurance_number_valid?
  validates :employment_insurance_number, absence: true, unless: :employment_insurance_number_valid?
  validates :has_labor_insurance, presence: true, if: :business_owner_or_master
  validates :has_labor_insurance, absence: true, unless: :business_owner_or_master
  validates :severance_pay_mutual_aid_name, presence: true, if: :severance_pay_mutual_aid_name_valid?
  validate :valid_health_insurance_image

  mount_uploaders :health_insurance_image, WorkerInsurancesUploader

  private

  # 保険証の写しのバリデーション
  def valid_health_insurance_image
    # 健康保険が適用除外、未加入以外の場合、保険証の写しが必須
    if health_insurance_image_required?
      errors.add(:health_insurance_image, 'を入力してください') && return if health_insurance_image.blank?
    elsif health_insurance_image.present?
      errors.add(:health_insurance_image, 'は登録しないでください') && return
    end
  end

  # 健康保険が健康保険組合もしくは建設国保であればtrue
  def insurance_name_valid?
    %w[health_insurance_association construction_national_health_insurance].include?(health_insurance_type)
  end

  # 健康保険が適用除外、未加入以外の場合true
  def health_insurance_image_required?
    %w[health_insurance_association
       japan_health_insurance_association
       construction_national_health_insurance
       national_health_insurance].include?(health_insurance_type)
  end

  # 雇用保険が被保険者であればtrue
  def employment_insurance_number_valid?
    if worker.business_owner_or_master
      false
    else
      %w[insured day].include?(employment_insurance_type)
    end
  end

  def severance_pay_mutual_aid_name_valid?
    severance_pay_mutual_aid_type == 'other'
  end

  def business_owner_or_master
    worker.business_owner_or_master
  end
end
