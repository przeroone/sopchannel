require 'rubygems'
require 'mechanize'

link = 'http://livefootball.ws'

entities = []
agent = Mechanize.new
html = agent.get(link)
matches = html.search('.base.custom')
matches.each do |match|
  title = match.search('div:eq(1)').text
  time = match.search('div:eq(2)').text
  images = [nil, nil]
  match.search('img').each_with_index do |img, index|
    images[index] = img['src']
  end

  links = []
  if time == 'Online'
    sub_link = match.search('a').first
    sub_html = agent.get(sub_link['href'])

    sub_html.search('.binner.maincont table:eq(2) tr').each_with_index do |row, index|
      if index > 0
        bit_rate     = row.search('td:eq(4)').text
        ratio        = row.search('td:eq(7)').text
        sopcast_link = row.search('td:eq(8) a').first['href']
        links << {bit_rate: bit_rate, ratio: ratio, sopcast_link: sopcast_link}
      end
    end
  end

  entities << {title: title, time: time, image_1: images[0], image_2: images[1], links: links}
end

File.open('matches.json', 'w') { |file| file.write(entities.to_json) }
