require 'rails_helper'

RSpec.describe 'Documnents', type: :system do
  let(:user) { create(:user) }
  let(:business) { create(:business, user: user) }
  let(:order) { create(:order, business: business) }
  let(:request_order) { create(:request_order, business: business, order: order) }
  let(:document) { create(:document, business: business, request_order: request_order) }

  describe '書類関連' do
    before(:each) do
      user.skip_confirmation!
      user.save!
      business.save!
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'

      document_pages = 3
      document_pages.times { |page|
        create(:document, request_order: request_order, business: business, document_type: page)
      }
    end

    it 'ログイン後発注一覧画面へ遷移できること' do
      visit users_request_order_documents_path(request_order)
      expect(page).to have_content '書類一覧'
    end

    context '表紙' do
      it '表紙の詳細画面へ遷移できること' do
        document = create(:document, document_type: 'cover_document', content: {"business_name": nil, "submitted_on": nil})
        pp document.document_type
        pp request_order.uuid
        pp document.uuid
        visit users_request_order_document_path(request_order, document)
        # visit "/users/request_orders/#{request_order.uuid}/documents/#{document.uuid}"
        # expect(page).to have_content document.document_type_i18n
      end
    end
  end
end
