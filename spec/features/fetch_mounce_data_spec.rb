# spec/features/fetch_mounce_data_spec.rb

RSpec.describe "Fetch Mounce Data", type: :feature do
  it "Can load the page" do
    visit 'https://www.billmounce.com/greek-dictionary/hebraios'

    expect(page).to have_content 'Hebraios'
    expect(page).to have_content 'Ἑβραῖος'
    expect(page).to have_content 'Ἑβραῖος, ου, ὁ'
  end

  it "Loads letter pages" do
    urls = {
      "α": "https://www.billmounce.com/greek-dictionary/a",
      "Ἀαρών": "https://www.billmounce.com/greek-dictionary/aaron",
      "Ἀβαδδών": "https://www.billmounce.com/greek-dictionary/abaddon",
      "ἀβαρής": "https://www.billmounce.com/greek-dictionary/abares",
      "ἀββά": "https://www.billmounce.com/greek-dictionary/abba"
    }

    urls.each do |key, value|
      visit value

      expect(page).to have_content key.to_s

      content = find("div.node-content").text
      puts content

      expect(page).to have_content key.to_s
      sleep(0.5)
    end
  end
end
