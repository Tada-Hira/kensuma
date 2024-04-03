require 'rails_helper'

RSpec.describe WorkerInsurance, type: :model do
  let(:worker_insurance) { create(:worker_insurance) }

  describe 'バリデーションについて' do
    subject do
      worker_insurance
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    describe '#health_insurance_type' do
      context '存在しない場合' do
        before :each do
          subject.health_insurance_type = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('健康保険を入力してください')
        end
      end
    end

    describe '#health_insurance_name' do
      context '健康保険が健康保険組合または、建設国保の場合' do
        before :each do
          subject.health_insurance_name = nil
        end

        it 'バリデーションに落ちること(健康保険組合)' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと(健康保険組合)' do
          subject.valid?
          expect(subject.errors.full_messages).to include('保険名を入力してください')
        end

        it 'バリデーションに落ちること(建設国保)' do
          subject.health_insurance_type = :construction_national_health_insurance
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと(建設国保)' do
          subject.health_insurance_type = :construction_national_health_insurance
          subject.valid?
          expect(subject.errors.full_messages).to include('保険名を入力してください')
        end
      end

      context '健康保険が健康保険組合、建設国保以外の場合' do
        before :each do
          subject.health_insurance_name = nil
        end

        it 'バリデーションにとおること(協会けんぽ)' do
          subject.health_insurance_type = :japan_health_insurance_association
          expect(subject).to be_valid
        end

        it 'バリデーションにとおること(国民健康保険)' do
          subject.health_insurance_type = :national_health_insurance
          expect(subject).to be_valid
        end

        it 'バリデーションにとおること(適応除外)' do
          subject.health_insurance_type = :exemption
          subject.health_insurance_image = []
          expect(subject).to be_valid
        end
      end
    end

    describe '#pension_insurance_type' do
      context '存在しない場合' do
        before :each do
          subject.pension_insurance_type = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('年金保険を入力してください')
        end
      end
    end

    describe '#employment_insurance_number' do
      shared_examples '無効な被保険者番号' do |numbers, error_message|
        numbers.each do |number|
          before(:each) do
            subject.employment_insurance_type = :insured
            subject.employment_insurance_number = number
          end

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include(error_message)
          end
        end
      end

      context '被保険者の場合' do
        context '無効な形式の場合' do
          numbers = %i[
            123あ
            ア123
          ]
          error_message = '被保険者番号は数字と半角カタカナおよびハイフンのみ使用できます'
          include_examples '無効な被保険者番号', numbers, error_message
        end

        context '無効な長さの場合' do
          numbers = %i[
            123456
            1234ｱｲ
          ]
          error_message = '被保険者番号は5文字以内で入力してください'
          include_examples '無効な被保険者番号', numbers, error_message
        end
      end
    end

    describe '#severance_pay_mutual_aid_type' do
      context '存在しない場合' do
        before :each do
          subject.severance_pay_mutual_aid_type = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('建設業退職金共済手帳を入力してください')
        end
      end
    end

    describe '#severance_pay_mutual_aid_name' do
      before :each do
        subject.severance_pay_mutual_aid_name = nil
      end

      context '建設業退職金共済手帳がその他の時、存在しない場合' do
        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('その他（建設業退職金共済手帳）を入力してください')
        end
      end

      context '建設業退職金共済手帳がその他以外の場合' do
        it 'バリデーションに通ること（建退共手帳）' do
          subject.severance_pay_mutual_aid_type = :kentaikyo
          expect(subject).to be_valid
        end

        it 'バリデーションに通ること中退共手帳）' do
          subject.severance_pay_mutual_aid_type = :tyutaikyo
          expect(subject).to be_valid
        end

        it 'バリデーションに通ること（無し）' do
          subject.severance_pay_mutual_aid_type = :none
          expect(subject).to be_valid
        end
      end
    end
  end
end
