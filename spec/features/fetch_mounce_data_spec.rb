# spec/features/fetch_mounce_data_spec.rb

RSpec.describe "Fetch Mounce Data", type: :feature do
  it "Can load the page" do
    visit 'https://www.billmounce.com/greek-dictionary/hebraios'

    expect(page).to have_content 'Hebraios'
    expect(page).to have_content 'Ἑβραῖος'
    expect(page).to have_content 'Ἑβραῖος, ου, ὁ'
  end
end
