require 'spec_helper'
RSpec.configure do |config|
    config.include ControllerHelpers
    # render jbuilder templates
    config.render_views
end

RSpec.describe SampleController, :type => :controller do
    before do
        # setup: log in, configure defaults etc
        user = create :user, name: "The Equalizer"
        sign_in user
        create :account, id: 1234, name: "Expenses"
    end

    after do
        # teardown
        User.all.delete_all
        Account.all.delete_all
    end

    describe "#account" do
        context "success" do
            it "outputs status code" do
                get :account, params: { id: 1234 }
                expect(response).to have_http_status :ok
            end

            it "renders account template" do
                get :account, params: { id: 1234 }
                expect(subject).to render_template :account
            end

            it "outputs account information" do
                get :account, params: { id: 1234 }
                output = JSON.parse(response.body)
                expect(output["name"]).to eq "Expenses"
            end
        end # /success

        context "failure" do
            context "server error" do
                it "outputs 500" do
                    get :account, params: { id: "asdf" }
                    expect(response).to have_http_status 500
                end
            end

            context "not found" do
                it "outputs 404" do
                    get :account, params: { id: 69696969 }
                    expect(response).to have_http_status 404
                end

                it "outputs a descriptive error message" do
                    # ...so that the developer won't have to look at the status codes
                    get :account, params: { id: 69696969 }
                    output = JSON.parse(response.body, symbolize_names: true)
                    expect(output[:error]).to eq "Account not found!"
                end
            end
        end # /failure
    end
end
