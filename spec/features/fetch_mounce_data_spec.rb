# spec/features/fetch_mounce_data_spec.rb

Entry = Struct.new(:lexical_form, :grk_translit, :simple_translit, :principal_parts, :strongs, :gk_number, :frequency, :mbg_tag, :gloss, :definition)
FORMAT = /Dictionary: \n(?<lexical_form>.+?)\nGreek transliteration: \n(?<grk_translit>.+?)\nSimplified transliteration: \n(?<simple_translit>.+?)\n(?:Principal Parts: \n(?<principal_parts>.+?)\n)?Numbers\nStrong's number: \n(?<strongs>\d+)\nGK Number: \n(?<gk_number>\d+)\n.+?\nFrequency in New Testament: \n(?<frequency>\d+)\nMorphology of Biblical Greek Tag: \n(?<mbg_tag>.+?)\nGloss: \n(?<gloss>.+?)\nDefinition: \n(?<definition>.+?)\z/

def parse_line(line)
  line.match(FORMAT) { |m| Entry.new(*m.captures) }
end

RSpec.describe "Fetch Mounce Data", type: :feature do
  it "Can load the page" do
    visit 'https://www.billmounce.com/greek-dictionary/hebraios'

    expect(page).to have_content 'Hebraios'
    expect(page).to have_content 'Ἑβραῖος'
    expect(page).to have_content 'Ἑβραῖος, ου, ὁ'
  end

  it "Loads letter pages" do
    urls = JSON.parse(File.read("spec/url_mappings.json"))
    # expect(urls.keys.length).to be(3)

    data = {}
    tabbed_data = []
    urls.each do |key, value|
      visit value

      expect(page).to have_content key.to_s

      content = find("div.node-content").text.gsub("\t"," ")
      item = parse_line(content).to_h
      data[key] = item
      tabbed_data.push(item.values.join("\t"))
    rescue
      puts "Unable to Parse #{key} on #{value} - Content:#{content}\n"
    ensure
      sleep(0.5) # don't want to slam the server
    end

    puts data

    File.write('dictionary.json', JSON.dump(data).gsub(" ", " "))
    File.write('dictionary.tsv', tabbed_data.join("\n").gsub(" ", " "))
  end
end
