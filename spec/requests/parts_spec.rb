require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe 'Parts', type: :request do
  let!(:mechanic) do
    Mechanic.create!(
      name: 'test',
      email: 'test@test.com',
      experience: '1',
      password: '12345678'
    )
  end

  let!(:admin) do
    AdminUser.create!(
      email: 'admin@test.com',
      password: '12345678'
    )
  end

  let!(:customer) do
    Customer.create!(
      name: 'test',
      email: 'customer@test.com',
      phone: '1234567890',
      password: '12345678'
    )
  end

  let!(:part) do
    Part.create!(
      name: 'Brake Pad',
      price: 25.50,
      stock: 100
    )
  end

  describe 'GET /parts' do
    context 'when 200 (authenticated as mechanic)' do
      before do
        sign_in mechanic
        get '/parts'
      end

      it 'returns ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when redirected (authenticated as customer)' do
      before do
        sign_in customer
        get '/parts'
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end
  end

  describe 'GET /parts/new' do
    context 'when 200 (authenticated as mechanic)' do
      before do
        sign_in mechanic
        get '/parts/new'
      end

      it 'returns ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when redirected (authenticated as customer)' do
      before do
        sign_in customer
        get '/parts/new'
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end
  end

  describe 'POST /parts' do
    context 'when 302 (created for mechanic)' do
      before do
        sign_in mechanic
        post '/parts', params: {
          part: {
            name: 'Oil Filter',
            price: 15.0,
            stock: 50
          }
        }
      end

      it 'redirects to parts index with notice' do
        expect(response).to redirect_to(parts_path)
        expect(flash[:notice]).to eq('Part added successfully.')
      end
    end

    context 'when redirected (authenticated as customer)' do
      before do
        sign_in customer
        post '/parts', params: {
          part: {
            name: 'Oil Filter',
            price: 15.0,
            stock: 50
          }
        }
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end
  end

  describe 'GET /parts/:id/edit' do
    context 'when 200 (authenticated as mechanic)' do
      before do
        sign_in mechanic
        get "/parts/#{part.id}/edit"
      end

      it 'returns ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when redirected (authenticated as customer)' do
      before do
        sign_in customer
        get "/parts/#{part.id}/edit"
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end
  end

  describe 'PATCH /parts/:id' do
    context 'when redirect (updated for mechanic)' do
      before do
        sign_in mechanic
        patch "/parts/#{part.id}", params: {
          part: {
            stock: 80
          }
        }
      end

      it 'redirects to parts index with notice' do
        expect(response).to redirect_to(parts_path)
        expect(flash[:notice]).to eq('Part updated successfully.')
      end
    end

    context 'when redirected (authenticated as customer)' do
      before do
        sign_in customer
        patch "/parts/#{part.id}", params: {
          part: {
            stock: 80
          }
        }
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end
  end
end

