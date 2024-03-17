class Business < ApplicationRecord
  belongs_to :user
  has_many :cars, dependent: :destroy
  has_many :special_vehicles, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :request_orders, dependent: :destroy
  has_many :workers, dependent: :destroy
  has_many :machines, dependent: :destroy
  has_many :solvents, dependent: :destroy
  has_many :business_occupations
  has_many :occupations, through: :business_occupations
  has_many :business_industries
  has_many :industries, through: :business_industries
  accepts_nested_attributes_for :business_occupations, allow_destroy: true
  accepts_nested_attributes_for :business_industries, allow_destroy: true

  before_create -> { self.uuid = SecureRandom.uuid }

  enum business_type: { corporation: 0, Individual_five_over: 1, Individual_five_less: 2, freelance: 3 }
  enum business_health_insurance_status: { join: 0, not_join: 1, not_coverd: 2 }, _prefix: true               # 健康保険(加入状況)
  enum business_welfare_pension_insurance_join_status: { join: 0, not_join: 1, not_coverd: 2 }, _prefix: true # 厚生年金保険(加入状況)
  enum business_employment_insurance_join_status: { join: 0, not_join: 1, not_coverd: 2 }, _prefix: true # 雇用保険(加入状況)
  enum business_retirement_benefit_mutual_aid_status: { construction_industry: 0, smaller_companies: 1, not_available: 2 }, _prefix: true # 退職金共済制度(加入状況)
  enum construction_license_status: { available: 0, not_available: 1 }, _prefix: true                         # 建設許可証(許可状況)
  enum foreign_work_status_exist: { available: 0, not_available: 1 }, _prefix: true                           # 外国人就労の有無
  enum specific_skilled_foreigners_exist: { available: 0, not_available: 1 }, _prefix: true                   # 一号特定技能外国人の従事の状況
  enum foreign_construction_workers_exist: { available: 0, not_available: 1 }, _prefix: true                  # 外国人建設就労者の従事の状況
  enum foreign_technical_intern_trainees_exist: { available: 0, not_available: 1 }, _prefix: true             # 人技能実習生の従事の状況

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: true
  validates :branch_address, presence: true, unless: proc { |b| b.branch_name.blank? }
  validates :name_kana, presence: true, format: { with: /\A[ァ-ヴー・]+\z/u, message: 'はカタカナで入力して下さい。' }
  validates :career_up_id, length: { maximum: 14, minimum: 14 }, allow_blank: true
  validates :representative_name, presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :address, presence: true
  validates :branch_name, presence: true, unless: proc { |b| b.branch_address.blank? }
  validates :post_code, presence: true, format: { with: /\A\^\d{5}$|^\d{7}\z/ }
  validates :phone_number, presence: true, format: { with: /\A\d{10,11}\z/ }
  validates :fax_number, format: { with: /\A\d{10,11}\z/ }, allow_blank: true
  validates :business_type, presence: true
  validates :business_health_insurance_status, presence: true # 健康保険(加入状況)
  validates :business_health_insurance_association, length: { maximum: 20 } # 健康保険(組合名)
  validates :business_health_insurance_office_number, length: { maximum: 20 }, allow_blank: true # 健康保険(事業所整理記号及び事業所番号)
  # validates :business_health_insurance_office_number, allow_blank: true, format: { with: /\A\d{6,8}\z/, message: 'は数字6桁または8桁で入力してください' } # 健康保険(事業所整理記号及び事業所番号) 一旦6桁から8桁で保存可能として実装
  validates :business_welfare_pension_insurance_join_status, presence: true # 厚生年金保険(加入状況)
  validates :business_welfare_pension_insurance_office_number, length: { maximum: 20 }, allow_blank: true # 厚生年金保険(事業所整理記号)
  validates :business_employment_insurance_join_status, presence: true # 雇用保険(加入状況)
  validates :business_employment_insurance_number, length: { maximum: 20 }, allow_blank: true # 雇用保険(番号)
  validates :business_retirement_benefit_mutual_aid_status, presence: true # 退職金共済制度(加入状況)
  validates :construction_license_status, presence: true
  validates :foreign_work_status_exist, presence: true # 外国人就労の有無
  before_validation :convert_to_full_width_katakana # 会社名(カナ)に対して半角で入力しても全角に変換する

  mount_uploaders :stamp_images, StampImagesUploader
  mount_uploaders :career_up_card_copy, CareerUpCardCopyUploader

  private

  # 半角カタカナを全角カタカナに変換する
  def convert_to_full_width_katakana
    if name_kana.present?
      self.name_kana = name_kana.gsub(/[\uFF61-\uFF9F]+/) { |str| str.unicode_normalize(:nfkc) }
    end
  end
end
