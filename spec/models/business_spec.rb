require 'rails_helper'

RSpec.describe Business, type: :model do
  let(:business) { build(:business) }

  describe 'バリデーションについて' do
    subject { business }

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    describe '#name' do
      context '存在しない場合' do
        before(:each) { subject.name = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('会社名を入力してください')
        end
      end
    end

    describe '#name_kana' do
      context '存在しない場合' do
        before(:each) { subject.name_kana = nil }

        it 'バリデーションが通ること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('会社名(カナ)はカタカナで入力して下さい。')
        end

        %i[
          てすときぎょう
          TEST企業
        ].each do |name_kana|
          context '不正なname_kanaの場合' do
            before(:each) { subject.name_kana = name_kana }

            it 'バリデーションに落ちること' do
              expect(subject).to be_invalid
            end

            it 'バリデーションのエラーが正しいこと' do
              subject.valid?
              expect(subject.errors.full_messages).to include('会社名(カナ)はカタカナで入力して下さい。')
            end
          end
        end
      end
    end

    describe '#representative_name' do
      context '存在しない場合' do
        before(:each) { subject.representative_name = nil }

        it 'バリデーションが通ること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('代表者名を入力してください')
        end
      end
    end

    describe '#email' do
      context '存在しない場合' do
        before(:each) { subject.email = nil }

        it 'バリデーションが通ること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('メールアドレスを入力してください')
        end
      end

      %i[
        email0.com
        あああ.com
        今井.com
        @@.com
      ].each do |email|
        context '不正なemailの場合' do
          before(:each) { subject.email = email }

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include('メールアドレスは不正な値です')
          end
        end
      end
    end

    describe '#address' do
      context '存在しない場合' do
        before(:each) { subject.address = nil }

        it 'バリデーションが通ること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('本社住所を入力してください')
        end
      end
    end

    describe '#post_code' do
      context '存在しない場合' do
        before(:each) { subject.post_code = nil }

        it 'バリデーションが通ること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('郵便番号を入力してください')
        end
      end

      %i[
        01234567
        0123
        012345
        012-3456
      ].each do |post_code|
        context '不正なpost_codeの場合' do
          before(:each) { subject.post_code = post_code }

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include('郵便番号は不正な値です')
          end
        end
      end
    end

    describe '#phone_number' do
      context '存在しない場合' do
        before(:each) { subject.phone_number = nil }

        it 'バリデーションが通ること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('電話番号を入力してください')
        end
      end

      %i[
        012345678987
        012345678
        012-3456-7898
        012/3456/7898
      ].each do |phone_number|
        context '不正なphone_numberの場合' do
          before(:each) { subject.phone_number = phone_number }

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include('電話番号は不正な値です')
          end
        end
      end
    end

    describe '#business_type' do
      context '存在しない場合' do
        before(:each) { subject.business_type = nil }

        it 'バリデーションが通ること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('会社形態を入力してください')
        end
      end
    end

    describe '#business_health_insurance_status' do
      context '存在しない場合' do
        before(:each) { subject.business_health_insurance_status = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('加入状況を入力してください')
        end
      end
    end

    describe '#business_health_insurance_association' do
      context '不正なbusiness_health_insurance_associationの場合' do
        before(:each) { subject.business_health_insurance_association = 'テスト健康保険組合012345678901' }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('組合名は20文字以内で入力してください')
        end
      end
    end

    describe '#business_health_insurance_office_number' do
      %i[
        012345678901234567890
        あいうえお12345アイウエオ123456
      ].each do |business_health_insurance_office_number|
        context '不正なbusiness_health_insurance_office_numberの場合' do
          before(:each) { subject.business_health_insurance_office_number = business_health_insurance_office_number }

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include('事業所整理記号及び事業所番号は20文字以内で入力してください')
          end
        end
      end
    end

    describe '#business_welfare_pension_insurance_join_status' do
      context '存在しない場合' do
        before(:each) { subject.business_welfare_pension_insurance_join_status = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('加入状況を入力してください')
        end
      end
    end

    describe '#business_welfare_pension_insurance_office_number' do
      %i[
        012345678901234567890
        あいうえお12345アイウエオ123456
      ].each do |business_welfare_pension_insurance_office_number|
        context '不正なbusiness_welfare_pension_insurance_office_numberの場合' do
          before(:each) { subject.business_welfare_pension_insurance_office_number = business_welfare_pension_insurance_office_number }

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include('事業所整理記号は20文字以内で入力してください')
          end
        end
      end
    end

    describe '#business_employment_insurance_join_status' do
      context '存在しない場合' do
        before(:each) { subject.business_employment_insurance_join_status = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('加入状況を入力してください')
        end
      end
    end

    describe '#business_employment_insurance_number' do
      %i[
        012345678901234567890
        あいうえお12345アイウエオ123456
      ].each do |business_employment_insurance_number|
        context '不正なbusiness_employment_insurance_numberの場合' do
          before(:each) { subject.business_employment_insurance_number = business_employment_insurance_number }

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include('雇用保険番号は20文字以内で入力してください')
          end
        end
      end
    end

    describe '#business_retirement_benefit_mutual_aid_status' do
      context '存在しない場合' do
        before(:each) { subject.business_retirement_benefit_mutual_aid_status = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('制度を入力してください')
        end
      end
    end

    describe '#construction_license_status' do
      context '存在しない場合' do
        before(:each) { subject.construction_license_status = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('建設許可証を入力してください')
        end
      end
    end

    # describe '#construction_license_permission_type_minister_governor' do
    #   context '存在しない場合' do
    #     before(:each) { subject.construction_license_permission_type_minister_governor = nil }

    #     it 'バリデーションに落ちること' do
    #       expect(subject).to be_invalid
    #     end

    #     it 'バリデーションのエラーが正しいこと' do
    #       subject.valid?
    #       expect(subject.errors.full_messages).to include('種類を入力してください')
    #     end
    #   end
    # end

    # describe '#construction_license_governor_permission_prefecture' do
    #   context '存在しない場合' do
    #     before(:each) { subject.construction_license_governor_permission_prefecture = nil }

    #     it 'バリデーションに落ちること' do
    #       expect(subject).to be_invalid
    #     end

    #     it 'バリデーションのエラーが正しいこと' do
    #       subject.valid?
    #       expect(subject.errors.full_messages).to include('都道府県知事許可を入力してください')
    #     end
    #   end
    # end

    # describe '#construction_license_permission_type_identification_general' do
    #   context '存在しない場合' do
    #     before(:each) { subject.construction_license_permission_type_identification_general = nil }

    #     it 'バリデーションに落ちること' do
    #       expect(subject).to be_invalid
    #     end

    #     it 'バリデーションのエラーが正しいこと' do
    #       subject.valid?
    #       expect(subject.errors.full_messages).to include('建設許可証(種別)を入力してください')
    #     end
    #   end
    # end

    # describe '#construction_license_number_double_digit' do
    #   %i[
    #     0
    #     012
    #   ].each do |construction_license_number_double_digit|
    #     context '不正なbusiness_welfare_pension_insurance_office_numberの場合' do
    #       before(:each) { subject.construction_license_number_double_digit = construction_license_number_double_digit }

    #       it 'バリデーションに落ちること' do
    #         expect(subject).to be_invalid
    #       end

    #       it 'バリデーションのエラーが正しいこと' do
    #         subject.valid?
    #         expect(subject.errors.full_messages).to include('建設許可証(和暦年度)は数字2桁で入力してください')
    #       end
    #     end
    #   end
    # end

    # describe '#construction_license_number_six_digits' do
    #   %i[
    #     0123456
    #   ].each do |construction_license_number_six_digits|
    #     context '不正なconstruction_license_number_six_digitsの場合' do
    #       before(:each) { subject.construction_license_number_six_digits = construction_license_number_six_digits }

    #       it 'バリデーションに落ちること' do
    #         expect(subject).to be_invalid
    #       end

    #       it 'バリデーションのエラーが正しいこと' do
    #         subject.valid?
    #         expect(subject.errors.full_messages).to include('建設許可証(番号)は数字6桁以下で入力してください')
    #       end
    #     end
    #   end
    # end

    # describe '#construction_license_number' do
    #   context '存在しない場合' do
    #     before(:each) { subject.construction_license_number = nil }

    #     it 'バリデーションに落ちること' do
    #       expect(subject).to be_invalid
    #     end

    #     it 'バリデーションのエラーが正しいこと' do
    #       subject.valid?
    #       expect(subject.errors.full_messages).to include('建設許可番号を入力してください')
    #     end
    #   end
    # end

    # describe '#construction_license_updated_at' do
    #   context '存在しない場合' do
    #     before(:each) { subject.construction_license_updated_at = nil }

    #     it 'バリデーションに落ちること' do
    #       expect(subject).to be_invalid
    #     end

    #     it 'バリデーションのエラーが正しいこと' do
    #       subject.valid?
    #       expect(subject.errors.full_messages).to include('更新日を入力してください')
    #     end
    #   end
    # end
  end

  describe '車両情報とのアソシエーションについて' do
    let(:business) { create(:business, cars: cars) }
    let(:cars) { create_list(:car, 2) }

    context '紐づく車両情報がある場合' do
      subject { business.cars }

      it '紐づく車両情報を返すこと' do
        expect(subject).to eq(cars)
      end
    end
  end

  describe '現場情報とのアソシエーションについて' do
    let(:business) { create(:business, orders: orders) }
    let(:orders) { create_list(:order, 2) }

    context '紐づく現場情報がある場合' do
      subject { business.orders }

      it '紐づく現場情報を返すこと' do
        expect(subject).to eq(orders)
      end
    end
  end

  describe '下請発注情報とのアソシエーションについて' do
    let(:request_orders) { create_list(:request_order, 2, business: business) }

    context '紐づく下請発注情報がある場合' do
      subject { business.request_orders }

      it '紐づく下請発注情報を返すこと' do
        expect(subject).to eq(request_orders)
      end
    end
  end

  describe '書類とのアソシエーションについて' do
    let(:documents) { create_list(:document, 3, business: business) }

    context '紐づく書類がある場合' do
      subject { business.documents }

      it '紐づく書類を返すこと' do
        expect(subject).to eq(documents)
      end
    end
  end
end
