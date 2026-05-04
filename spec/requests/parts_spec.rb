require 'rails_helper'

RSpec.describe "Parts", type: :request do
  describe "GET /parts" do
    it "works! (now write some real specs)" do
      get parts_path
      expect(response).to have_http_status(200)
    end
  end
end
