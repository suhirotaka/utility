require 'elasticsearch'
require 'open-uri'
require 'securerandom'

class MdfileLinkElasticsearch
  def initialize
    @esc = Elasticsearch::Client.new
    
    # Set Elasticsearch index name
    @index_name = ''
    begin
      @index_name = "ruby-readme-#{SecureRandom.hex(8)}"
    end while @esc.indices.exists? index: @index_name

    # Set destructor
    #ObjectSpace.define_finalizer(self, self.cleanup_index)
  end
  
  def get_articles
    # Get articles from md file
    filename = './readme_test.dat'
    data = File.read(filename)
    matches = data.scan(/\[(.+?)\].*?\((.+?)\)/)
    matches.each do |match|
      title = match.first
      url = match.last
      begin
        body = open(url, &:read).encode('UTF-8')
      rescue Encoding::UndefinedConversionError => e
        p e
      end
      @esc.create index: @index_name, type: 'article', body: { title: title, url: url, html_content: body }
#break
    end
  end
  
  def send_query
    # Query to Elasticsearch
    query = ARGV[0]
    #res = @esc.search index: @index_name, type: 'article', q: query
    res = @esc.search index: @index_name, type: 'article', body: { query: { match: { html_content: query } } }
    res['hits']['hits'].each do |article|
      p "#{article['_source']['title']}(#{article['_source']['url']})"
    end
    cleanup_index
  end
  
  def cleanup_index
    # Cleanup the index
    p "Cleanup Elasticsearch index: #{@index_name}"
    @esc.indices.delete index: @index_name
  end
end

md_elastic = MdfileLinkElasticsearch.new
md_elastic.get_articles
sleep(10)
md_elastic.send_query
