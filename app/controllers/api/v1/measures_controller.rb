module API
  module V1
    class MeasuresController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      resource_description do
        short 'Clinical Quality Measures'
        formats ['json']
        header 'X-API-EMAIL', 'user\'s email', required: true
        header 'X-API-TOKEN', 'user\'s current authentication token', required: true
        description <<-EOS
        Measures used by Cedar, referred to by CMS id.
        EOS
      end

      api! 'get all measures with query strings'
      param :tag, String, desc: 'Only show measures that have this tag'
      param :reporting_period, BUNDLE_MAP.keys, desc: 'Only show measures from this year'
      description 'Returns measures that satisfy all query paramters, or all measures if no query string is given.'
      def index
        render json: MeasureRepresenter.for_collection.new(Measure.all.top_level.where(query_params)
        .only(:tags, :cms_id, :name, :description, :hqmf_id, :bundle_id))
      end

      api! 'show single measure'
      def show
        # This is not respond_with because the API::V1 namespace makes it unable to find HealthDataStandards
        render json: MeasureRepresenter.new(Measure.find_by(cms_id: params[:id]))
      end

      private

      def query_params
        # Accept a tag and reporting period as query params
        filtered = params.permit(:tags, :reporting_period)
        if filtered[:reporting_period]
          # Measures don't have a reporting year attribute, so we have to filter manually using the bundle map (in constants.rb)
          bundle = HealthDataStandards::CQM::Bundle.all.to_a.select { |b| BUNDLE_MAP.key(b.measure_period_start) == filtered[:reporting_period] }[0]
          filtered[:bundle_id] = bundle.id
          filtered.delete :reporting_period
        end
        filtered
      end
    end
  end
end
