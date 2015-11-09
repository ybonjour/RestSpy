require 'rest_spy/api'

module RestSpy
  describe Api do
    describe '#redirect_to' do
      let(:api) { Class.new { extend Api } }

      it 'returns a CreateDouble' do
        expect(api.redirect_to('http://redirect.url')).to be_instance_of(Api::CreateDouble)
      end

      it 'configures correct redirect header' do
        expect(api.redirect_to('http://redirect.url').send(:headers)['Location']).to eq('http://redirect.url')
      end

      it 'configures correct 302 status code' do
        expect(api.redirect_to('http://redirect.url').send(:status_code)).to eq(302)
      end

      it 'configures no body' do
        expect(api.redirect_to('http://redirect.url').send(:body)).to eq('')
      end
    end
  end
end