module Users
  class DocumentsController < Users::Base
    include DocumentsConcern

    layout 'documents'
    before_action :set_documents # サイドバーに常時表示させるために必要
    before_action :set_document, except: :index # オブジェクトが1つも無い場合、indexで呼び出さないようにする
    before_action :set_cover_documents, only: :index # サイドバー表示 表紙一覧
    before_action :set_cover_document, except: :index # 同上

    # サイドバーリンク用
    before_action :set_cover_document_uuid, except: :index
    before_action :set_table_of_contents_document_uuid, except: :index
    before_action :set_second_document_uuid, except: :index

    def index; end

    def show; end

    def edit; end

    def update
      if @cover_document.update(document_params)
        flash[:success] = '更新に成功しました'
        redirect_to users_document_url(@document)
      else
        flash[:danger] = '更新に失敗しました'
        render :edit
      end
    end

    def cover
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: '表紙',
            layout: 'pdf',
            encording: 'UTF-8',
            page_size: 'A4'
        end
      end
    end

    private

    def set_document
      @document = current_business.documents.find_by(uuid: params[:uuid])
    end

    def set_cover_documents
      @cover_documents = current_business.documents.document_type_cover
    end

    def set_cover_document
      @cover_document = current_business.documents.document_type_cover.find_by(uuid: params[:uuid])
    end

    def document_params
      params.require(:document).permit.merge(
        content: {
          business_name: params[:document][:content][0],
          submitted_on: params[:document][:content][1]
        })
    end
  end
end
