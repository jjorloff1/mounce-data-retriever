# This is not meant to be run without human interaction.
# WARNING: Mounce's Copyright page asks that his content not be shared.
# For that reason, the only data file I include is a mapping of greek words to their
# definition page.  These scripts will turn that list into data, but you must not
# distribute that data, or you will be in violation of his terms and conditions.

Entry = Struct.new(:lexical_form, :grk_translit, :simple_translit, :principal_parts, :strongs, :gk_number, :frequency, :mbg_tag, :gloss, :definition)
DATA_FORMAT = /Dictionary: \n(?<lexical_form>.+?)\nGreek transliteration: \n(?<grk_translit>.+?)\nSimplified transliteration: \n(?<simple_translit>.+?)\n(?:Principal Parts: \n((?<principal_parts>.+?)\n)?)?Numbers\nStrong's number: \n(?<strongs>\d+)\nGK Number: \n(?<gk_number>\d+)\n.+?\nFrequency in New Testament: \n(?<frequency>\d+)\nMorphology of Biblical Greek Tag: \n(?<mbg_tag>.+?)\nGloss: \n(?<gloss>.+?)\nDefinition: \n?(?<definition>.+)?/

def parse_line(line)
  line.match(DATA_FORMAT) { |m| Entry.new(*m.captures) }
end

RSpec.describe "Fetch Mounce Data", type: :feature do
  # "Can load the page" is just a test to make sure the framework is working
  xit "Can load the page" do
    visit 'https://www.billmounce.com/greek-dictionary/hebraios'

    expect(page).to have_content 'Hebraios'
    expect(page).to have_content 'Ἑβραῖος'
    expect(page).to have_content 'Ἑβραῖος, ου, ὁ'
  end

  # Copy the words you want to fetch from the spec/mounce_url_masterlist.json file to
  # spec/url_mappings.json then run from the command line and use "rspec | tee -a 'logfilename.log'"
  # Then you can take the output of that file and build a word_data.json file which you
  # can feed into the next test.
  it "Fetch word data and log to console" do
    urls = JSON.parse(File.read("spec/url_mappings.json"))

    urls.each do |key, value|
      visit value

      unless page.has_content?("Dictionary") and page.has_content?(key.to_s) then
        puts "Unable to Parse #{key} on #{value} - Content:#{content}\n"
        next
      end

      content = find("div.node-content").text.gsub("\t"," ")
      item = parse_line(content).to_h

      if item.empty? then
        puts "Unable to Parse #{key} on #{value} - Content:#{content}\n"
        next
      end

      item[:key] = key
      item[:url] = value
      puts item.to_json
    rescue
      puts "Unable to Parse #{key} on #{value} - Content: #{content}\n"
    ensure
      sleep(0.5) # don't want to slam the server
    end
  end

  # Takes a word_data.json file (which you built manually after running the previous test)
  # and creates a json file keyed on the word, and a tsv file.
  # You can copy the dictionary.json file to spec and use it to check for errors with the
  # next test.
  xit "Converts word data to usable file formats" do
    words = JSON.parse(File.read("spec/word_data.json"))

    data = {}
    tabbed_data = []
    words.each do |word|
      data[word[:key]] = word
      tabbed_data.push(word.values.join("\t"))
    end

    # File.write('errors_3.json', JSON.dump(errors))
    File.write('dictionary.json', JSON.dump(data).gsub(" ", " "))
    File.write('dictionary.tsv', tabbed_data.join("\n").gsub(" ", " "))
  end

  # Compares a dictionary.json with the url_masterlist to see which words did not
  # get retrieved.  It will produce an errors.json which can then feed back into
  # step one once you have resolved the errors.
  xit "Generates list of errors" do
    all_words = JSON.parse(File.read("spec/mounce_url_masterlist.json"))
    completed_words = JSON.parse(File.read("spec/dictionary.json"))

    errors = {}
    all_words.each do |key, value|
      next if completed_words.has_key? key

      errors[key] = value
    end

    File.write('errors.json', JSON.dump(errors))
  end
end
