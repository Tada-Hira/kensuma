require 'rails_helper'

RSpec.describe Car, type: :model do
  let(:car) { build(:car) }

  describe 'バリデーションについて' do
    subject { car }

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    describe '#usage' do
      context '存在しない場合' do
        before(:each) { subject.usage = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('使用目的を入力してください')
        end
      end
    end

    describe '#owner_name' do
      context '存在しない場合' do
        before(:each) { subject.owner_name = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('車両所有者名を入力してください')
        end
      end
    end

    describe '#vehicle_name' do
      context '存在しない場合' do
        before(:each) { subject.vehicle_name = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('車両名を入力してください')
        end
      end
    end

    describe '#vehicle_model' do
      context '存在しない場合' do
        before(:each) { subject.vehicle_model = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('車両型式を入力してください')
        end
      end
    end

    # describe '#vehicle_number' do
    #   context '存在しない場合' do
    #     before(:each) { subject.vehicle_number = nil }

    #     it 'バリデーションに落ちること' do
    #       expect(subject).to be_invalid
    #     end

    #     it 'バリデーションのエラーが正しいこと' do
    #       subject.valid?
    #       expect(subject.errors.full_messages).to include('車両番号(ナンバープレート)を入力してください')
    #     end
    #   end

    #   context '地域名がアルファベット大文字の場合' do
    #     before(:each) { subject.vehicle_number = '沖縄500Y1234' }

    #     it 'バリデーションが通ること' do
    #       expect(subject).to be_valid
    #     end
    #   end

    #   context '地域名,分類番号,平仮名等,一連指定番号が1文字の場合' do
    #     before(:each) { subject.vehicle_number = '外1わ1' }

    #     it 'バリデーションが通ること' do
    #       expect(subject).to be_valid
    #     end
    #   end

    #   context '地域名4文字,分類番号3文字,平仮名等1文字,一連指定番号が4文字の場合' do
    #     before(:each) { subject.vehicle_number = '尾張小牧500わ1234' }

    #     it 'バリデーションが通ること' do
    #       expect(subject).to be_valid
    #     end
    #   end

    #   %i[
    #     1234
    #     あ
    #     品川あ5001234
    #     品川500あ12-34
    #     品川5000あ1234
    #     品川500あ12345
    #     品川品川品500あ1234
    #     沖縄500y1234
    #   ].each do |vehicle_number|
    #     context '不正なvehicle_numberの場合' do
    #       before(:each) { subject.vehicle_number = vehicle_number }

    #       it 'バリデーションに落ちること' do
    #         expect(subject).to be_invalid
    #       end

    #       it 'バリデーションのエラーが正しいこと' do
    #         subject.valid?
    #         expect(subject.errors.full_messages).to include('車両番号(ナンバープレート)は地域名,分類番号,平仮名等,一連指定番号で入力してください(例：品川500あ1234)')
    #       end
    #     end
    #   end
    # end

    describe '#vehicle_inspection_start_on' do
      context '存在しない場合' do
        before(:each) { subject.vehicle_inspection_start_on = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('始期を入力してください')
        end
      end
    end

    describe '#vehicle_inspection_end_on' do
      context '存在しない場合' do
        before(:each) { subject.vehicle_inspection_end_on = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('終期を入力してください')
        end
      end
    end

    describe '#liability_securities_number' do
      context '存在しない場合' do
        before(:each) { subject.liability_securities_number = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('証券番号を入力してください')
        end
      end
    end

    describe '#liability_insurance_start_on' do
      context '存在しない場合' do
        before(:each) { subject.liability_insurance_start_on = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('始期を入力してください')
        end
      end
    end

    describe '#liability_insurance_end_on' do
      context '存在しない場合' do
        before(:each) { subject.liability_insurance_end_on = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('終期を入力してください')
        end
      end
    end
  end

  describe '保険会社とのアソシエーションについて' do
    let(:company) { create(:car_insurance_company) }
    let(:companies) { create_list(:car_insurance_company, 2) }

    context '紐づく自賠責保険会社がある場合' do
      subject { car.car_insurance_company = company }

      it '紐づく自賠保険会社を返すこと' do
        expect(subject).to eq(company)
      end
    end

    context '紐づく任意保険会社がある場合' do
      subject { car.company_voluntaries << companies }

      it '紐づく任意保険会社を返すこと' do
        expect(subject).to eq(companies)
      end
    end
  end
end
