class Lastfm
  module MethodCategory
    class Album < Base
      write_method :add_tags, :required => [:artist, :album, :tags]

      write_method :remove_tag, :required => [:artist, :album, :tag]

      write_method(
        :share,
        :required => [:artist, :album, :recipient],
        :optional => [
          [:public, nil],
          [:message, nil]
        ]
      )

      regular_method(
        :get_buylinks,
        :required => any_params([:artist, :album, :country], [:mbid, :country]),
        :optional => [
          [:autocorrect, nil]
        ]
      ) do |response|
        response.xml['affiliations']
      end

      regular_method(
        :get_info,
        :required => any_params([:artist, :album], :mbid)
      ) do |response|
        result = response.xml['album']

        result['releasedate'].lstrip! unless result['releasedate'].nil? || result['releasedate'].empty?
        result
      end

      regular_method(
        :get_shouts,
        :required => any_params([:artist, :album], :mbid),
        :optional => [
          [:limit, nil],
          [:autocorrect, nil],
          [:page, nil]
        ]
      ) do |response|
        response.xml['shouts']['shout'] = Util.force_array(response.xml['shouts']['shout'])
      end

      regular_method(
        :get_top_tags,
        :required => [:artist, :album],
        :optional => [
          [:autocorrect, nil]
        ]
      ) do |response|
        response.xml['toptags']['tag'] = Util.force_array(response.xml['toptags']['tag'])
      end

      regular_method(
        :search,
        return_body: true,
        required: [:album],
        optional: [
          [:limit, nil],
          [:page, nil]
        ]
      ) do |response|
        doc = Nokogiri::XML(response)
        albums = doc.xpath("//albummatches/album")
        albums.map do |a|
          {
            name: a.xpath('name').text,
            artist: a.xpath('artist').text,
            id: a.xpath('id').text,
            url: a.xpath('url').text,
            streamable: a.xpath('streamable').text,
            images: a.xpath('image').map { |image|
              { size: image['size'], url:  image.text }
            }
          }
        end
      end

      method_with_authentication(
        :get_tags,
        :required => any_params([:artist, :album], :mbid),
        :optional => [
          [:autocorrect, nil],
        ]
      ) do |response|
        response.xml['tags']['tag'] = Util.force_array(response.xml['tags']['tag'])
      end
    end
  end
end
