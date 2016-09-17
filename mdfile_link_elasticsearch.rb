require 'elasticsearch'
require 'open-uri'

esc = Elasticsearch::Client.new

data = File.read('./readme_test.dat')
matched = data.scan(/\[.+?\].*?\((.+?)\)/)
matched.each do |url|
  body = open(url.first, &:read)
  esc.create index: 'readme', type: 'article', body:{url: url.first, html_content: body}
  break
end
p esc.search index: 'readme', type: 'article', q: 'html'
exit

p c.info
