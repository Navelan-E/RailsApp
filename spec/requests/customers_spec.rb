require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Customers", type: :request do
  let!(:mechanic) do
    Mechanic.create!(
      name: 'test',
      email: 'test@test.com',
      experience: '1',
      password: '12345678'
    )
  end

  let!(:customer) do
    Customer.create!(
      name: 'test',
      email: 'test@test.com',
      phone: '1234567890',
      password: '12345678'
    )
  end

  describe 'GET /customers' do
    context 'when mechanic' do
      before do
        sign_in mechanic
        get '/customers'
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when customer (redirect)' do
      before do
        sign_in customer
        get '/customers'
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end
  end

  describe 'GET /customers/:id' do
    context 'when mechanic' do
      before do
        sign_in mechanic
        get "/customers/#{customer.id}"
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when customer (redirect)' do
      before do
        sign_in customer
        get "/customers/#{customer.id}"
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end

    context 'when mechanic and customer not found' do
      before do
        sign_in mechanic
        get '/customers/120'
      end

      it 'redirects with alert' do
        expect(response).to redirect_to(customers_path)
        expect(flash[:alert]).to eq('Customer not found.')
      end
    end
  end

  describe 'PATCH /customers/:id' do
    context 'when mechanic (redirect)' do
      before do
        sign_in mechanic
        patch "/customers/#{customer.id}", params: {
          customer: { name: 'Demo' }
        }
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end

    context 'when customer (success)' do
      before do
        sign_in customer
        patch "/customers/#{customer.id}", params: {
          customer: { name: 'Demo' }
        }
      end

      it 'redirects to root with notice' do
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('Customer updated successfully.')
      end
    end

    context 'when customer and customer not found' do
      before do
        sign_in customer
        patch '/customers/120'
      end

      it 'redirects to root' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /customers/:id/disable' do
    context 'when mechanic (redirect)' do
      before do
        sign_in mechanic
        patch "/customers/#{customer.id}/disable"
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end

    context 'when customer (success)' do
      before do
        sign_in customer
        patch "/customers/#{customer.id}/disable"
      end

      it 'redirects to root with notice' do
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('Customer disabled successfully.')
      end
    end

    context 'when customer and invalid id' do
      before do
        sign_in customer
        patch '/customers/120/disable'
      end

      it 'redirects to root' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /customers/:id/unlock' do
    context 'when customer (success)' do
      before do
        sign_in customer
        customer.lock_access!
        patch "/customers/#{customer.id}/unlock"
      end

      it 'redirects to new_customer_session_path' do
        expect(response).to redirect_to(new_customer_session_path)
      end
    end

    context 'when customer and invalid id' do
      before do
        sign_in customer
        patch '/customers/120/unlock'
      end

      it 'redirects with alert' do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

