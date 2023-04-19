class Worker < ApplicationRecord
  belongs_to :business
  has_one :worker_insurance, dependent: :destroy
  accepts_nested_attributes_for :worker_insurance, allow_destroy: true

  has_many :worker_licenses, dependent: :destroy
  has_many :licenses, through: :worker_licenses
  accepts_nested_attributes_for :worker_licenses, allow_destroy: true,
    reject_if:     proc { |attributes| attributes['license_id'].blank? }

  has_many :worker_skill_trainings, dependent: :destroy
  has_many :skill_trainings, through: :worker_skill_trainings
  accepts_nested_attributes_for :worker_skill_trainings, allow_destroy: true,
    reject_if:     proc { |attributes| attributes['skill_training_id'].blank? }

  has_many :worker_special_educations, dependent: :destroy
  has_many :special_educations, through: :worker_special_educations
  accepts_nested_attributes_for :worker_special_educations, allow_destroy: true,
    reject_if:     proc { |attributes| attributes['special_education_id'].blank? }

  has_many :worker_safety_health_educations, dependent: :destroy
  has_many :safety_health_educations, through: :worker_safety_health_educations
  accepts_nested_attributes_for :worker_safety_health_educations, allow_destroy: true,
    reject_if:     proc { |attributes| attributes['safety_health_education_id'].blank? }

  has_one :worker_medical, dependent: :destroy
  accepts_nested_attributes_for :worker_medical, allow_destroy: true

  enum abo_blood_type: { a: 0, b: 1, ab: 2, o: 3 }
  enum rh_blood_type: { plus: 0, minus: 1, rh_null: 2 }
  enum employment_contract: { available: 0, not_available: 1, not_applicable: 2 }, _prefix: true       # 雇用契約書取り交わし状況
  enum sex: { man: 0, woman: 1 }
  enum status_of_residence: { permanent_resident: 0, skill_practice: 1, construction_employment: 2, specified_skill: 3 }, _prefix: true # 在留資格
  enum confirmed_check: { checked: 1, unchecked: 0 }, _prefix: true # キャリアアップシステム登録情報が最新であることの確認日

  before_create -> { self.uuid = SecureRandom.uuid }

  VALID_PHONE_NUMBER_REGEX = /\A^$|\A\z|\A\d{10,11}\z/
  VALID_EMAIL_REGEX = /\A^$|\A\z|\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_UNDER_THREE_DIGITS_REGEX = /\A^$|\A\z|\A\d{1,2}\z/
  FORMAT_D_LICENCE = { with: /\A^$|\A\z|\A\d{12}\z/, message: 'は12桁の数字で入力してください' }.freeze
  PHONE_NUMBER_MS = 'は10桁または11桁の数字で入力してください'.freeze
  UNDER_THREE_DIGITS_MS = 'は3桁以上は入力できません'.freeze
  validates :career_up_id, format: { with: /\A^$|\A\z|\A\d{14}\z/, message: 'は14桁の数字で入力してください' }, allow_nil: true
  validates :name, presence: true
  validates :name_kana, presence: true, format: { with: /\A^$|\A[ァ-ヴ][ァ-ヴー ]+\ [ァ-ヴー]+\z/, message: 'はカタカナで入力してください' }
  validates :country, presence: true
  validates :email, format: { with: VALID_EMAIL_REGEX, message: 'はexample@email.comのような形式で入力してください' }, allow_nil: true
  validates :post_code, format: { with: /\A^$|\A\z|\A\d{7}\z/, message: 'は7桁の数字で入力してください' }, allow_nil: true
  validates :my_address, presence: true
  validates :my_phone_number, presence: true, format: { with: VALID_PHONE_NUMBER_REGEX, message: PHONE_NUMBER_MS }
  validates :family_address, presence: true
  validates :family_phone_number, presence: true, format: { with: VALID_PHONE_NUMBER_REGEX, message: PHONE_NUMBER_MS }
  validates :birth_day_on, presence: true
  validates :abo_blood_type, presence: true
  validates :rh_blood_type, presence: true
  validates :hiring_on, presence: true
  validates :experience_term_before_hiring, presence: true, format: { with: VALID_UNDER_THREE_DIGITS_REGEX, message: UNDER_THREE_DIGITS_MS }
  validates :blank_term, presence: true, format: { with: VALID_UNDER_THREE_DIGITS_REGEX, message: UNDER_THREE_DIGITS_MS }
  validates :employment_contract, presence: true
  validates :family_name, presence: true
  validates :relationship, presence: true
  validates :sex, presence: true
  validates :driver_licence_number, absence: true, unless: :driver_licence_present?
  validates :driver_licence_number, presence: true, if: :driver_licence_present?
  validates :driver_licence_number, format: FORMAT_D_LICENCE, allow_nil: true, if: :driver_licence_present?
  validates :status_of_residence, presence: true, if: :foreigner?
  validates :status_of_residence, absence: true, unless: :foreigner?
  validates :maturity_date, presence: true, if: :specified_skill_or_construction_employment?
  validates :maturity_date, absence: true, unless: :specified_skill_or_construction_employment?
  validates :confirmed_check, presence: true, if: :specified_skill_or_construction_employment?
  validates :confirmed_check, absence: true, unless: :specified_skill_or_construction_employment?
  validates :confirmed_check_date, presence: true, if: :confirmed_check_checked?
  validates :confirmed_check_date, absence: true, unless: :confirmed_check_checked?

  def to_param
    uuid
  end

  def driver_licence_present?
    driver_licences.present?
  end

  def foreigner?
    country != 'JP'
  end

  def specified_skill_or_construction_employment?
    foreigner? && %w[construction_employment specified_skill].include?(status_of_residence)
  end

  def confirmed_check_checked?
    specified_skill_or_construction_employment? && confirmed_check == 'checked'
  end

  def disabled_convert(params, key)
    self.update(key => '') if params.blank?
  end
end
