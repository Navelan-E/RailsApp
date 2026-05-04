require 'rails_helper'

RSpec.describe "Mechanics", type: :request do
  describe "GET /mechanics" do
    it "works! (now write some real specs)" do
      get mechanics_path
      expect(response).to have_http_status(200)
    end
  end
end
