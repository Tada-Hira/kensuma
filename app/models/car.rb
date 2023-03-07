class Car < ApplicationRecord
  belongs_to :business
  belongs_to :car_insurance_company
  has_many :car_voluntary_insurances, class_name: 'CarVoluntaryInsurance', foreign_key: :car_voluntary_id, dependent: :destroy
  has_many :company_voluntaries, through: :car_voluntary_insurances, source: :company_voluntary
  accepts_nested_attributes_for :car_voluntary_insurances

  before_create -> { self.uuid = SecureRandom.uuid }

  enum usage: { "工事用": 0, "通勤用": 1 }

  VALID_VEHICLE_NUMBER_REGEX = /\A[\u30a0-\u30ff\u3040-\u309f\u3005-\u3006\u30e0-\u9fcf]{1,4}[a-zA-Z0-9._-]{1,3}[\u3040-\u309f-A-Z]{1}[0-9]{1,4}\z/
  validates :usage, presence: true
  validates :owner_name, presence: true
  validates :vehicle_name, presence: true
  validates :vehicle_model, presence: true
  validates :vehicle_number, presence: true, format: { with: VALID_VEHICLE_NUMBER_REGEX, message: :vehicle_number_invalid }
  validates :vehicle_inspection_start_on, presence: true
  validates :vehicle_inspection_end_on, presence: true
  validates :liability_securities_number, presence: true
  validates :liability_insurance_start_on, presence: true
  validates :liability_insurance_end_on, presence: true

  mount_uploaders :images, CarsUploader

  def to_param
    uuid
  end
end
