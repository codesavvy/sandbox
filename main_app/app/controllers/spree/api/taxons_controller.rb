module Spree
  module Api
    class TaxonsController < Spree::Api::BaseController
      respond_to :json
      def index
        if taxonomy
          @taxons = taxonomy.root.children
        else
          if params[:ids]
            @taxons = Taxon.where(:id => params[:ids].split(","))
          else
            @taxons = Taxon.leaves.ransack(params[:q]).result
          end
        end
        respond_with(@taxons)
      end

      def show
        @taxon = taxon
        respond_with(@taxon)
      end

      def jstree
        show
      end

      def create
        p '&'*140;p'in top of create method api taxons'
        sleep(3)
        authorize! :create, Taxon
        
        @taxon = Taxon.new(params[:taxon])
        @taxon.taxonomy_id = params[:taxonomy_id]
        taxonomy = Taxonomy.find_by_id(params[:taxonomy_id])
        
        if taxonomy.nil?
          @taxon.errors[:taxonomy_id] = "Invalid taxonomy_id."
          invalid_resource!(@taxon) and return 
        end
        
        @taxon.parent_id = taxonomy.root.id
        
        if @taxon.save
          respond_with(@taxon, :status => 201, :default_template => :show)
        else
          invalid_resource!(@taxon)
        end
      end

      def update
        authorize! :update, Taxon
        if taxon.update_attributes(params[:taxon])
          respond_with(taxon, :status => 200, :default_template => :show)
        else
          invalid_resource!(taxon)
        end
      end

      def destroy
        p'*'*140;p'Top destroy api - taxon'
        authorize! :delete, Taxon
        taxon.destroy
        respond_with(taxon, :status => 204)
      end

      private

      def taxonomy
        if params[:taxonomy_id].present?
          @taxonomy ||= Taxonomy.find(params[:taxonomy_id])
        end
      end

      def taxon
        @taxon ||= taxonomy.taxons.find(params[:id])
      end
    
    end
  end
end
