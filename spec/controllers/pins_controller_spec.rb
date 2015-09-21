require 'rails_helper'

describe PinsController do
  let!(:user){ FactoryGirl.create(:user) }
  let!(:pin){ FactoryGirl.create(:pin, :user => user) }
  let(:json){ JSON.parse(response.body) }

  describe 'GET /pins' do

    before do
      get :index, format: :json
    end

    it 'should return a collection including all pins' do
      expect(json.map{|item| item["id"] }).to include(pin.id)
    end

  end

  describe 'SHOW /pins/:id' do

    before do
      get :show, format: :json, id: 1
    end

    it 'should return the correct item name' do
      expect(json["item_name"]).to eq(pin.item_name)
    end

    it 'should return the correct buy/sell state' do
      expect(json["buy_sell"]).to eq(pin.buy_sell)
    end

    it 'should return the correct description' do
      expect(json["description"]).to eq(pin.description)
    end

  end

  describe 'POST /pins/' do
    # let(:new_pin) { FactoryGirl.create(:pin) }

    it 'should not increment the count of pins if not logged in' do
      expect{
        post :create, format: :json, pin: pin.attributes
      }.to change(Pin, :count).by(0)
    end

    it 'should increment the count of pins by 1 if logged in' do
      sign_in(user)
      expect{
        post :create, format: :json, pin: pin.attributes
      }.to change(Pin, :count).by(1)
    end

  end

  describe 'PUT /pins/id/edit' do

    it 'should not edit the pin properly if not logged in' do
      old_text = pin.item_name
      new_pin = FactoryGirl.build(:pin)
      new_pin.item_name = "Abc123"
      new_pin.buy_sell = false
      new_pin.description = "ablsdlkj"
      new_pin.user_id = pin.user_id
      new_pin.id = pin.id

      put :update, format: :json, id: pin.id, pin: new_pin.attributes
      pin.reload
      expect(pin.item_name).to eq(old_text)
    end

    it 'should edit the pin properly if logged in' do
      sign_in(user)
      new_pin = FactoryGirl.build(:pin)
      new_pin.item_name = "Abc123"
      new_pin.buy_sell = false
      new_pin.description = "ablsdlkj"
      new_pin.user_id = pin.user_id
      new_pin.id = pin.id

      put :update, format: :json, id: pin.id, pin: new_pin.attributes
      pin.reload
      expect(pin.item_name).to eq("Abc123")
    end
  end

  describe 'Delete /pins/id' do

    it 'should delete pins properly' do
      sign_in(user)
      expect{ delete :destroy, format: :json, id: pin.id }.to change(Pin, :count).by(-1)
    end

    it 'should not be able to delete other users pins' do
      sign_in(user)
      pin2 = FactoryGirl.create(:pin)
      expect{ delete :destroy, format: :json, id: pin2.id }.to change(Pin, :count).by(0)
    end
  end
end
