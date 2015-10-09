class Lastfm
  module MethodCategory
    class Track < Base
      write_method :add_tags, :required => [:artist, :track, :tags]

      write_method :remove_tag, :required => [:artist, :track, :tag]

      write_method :ban, :required => [:artist, :track]

      write_method :love, :required => [:artist, :track]

      write_method :share, :required => [:artist, :track, :recipient], :optional => [[:message, nil]]

      write_method(
        :scrobble,
        :required => [:artist, :track],
        :optional => [
          [:timestamp, Proc.new { Time.now.utc.to_i }],
          [:album, nil],
          [:trackNumber, nil],
          [:mbid, nil],
          [:duration, nil],
          [:albumArtist, nil]
        ]
      )

      write_method(
        :update_now_playing,
        :required => [:artist, :track],
        :optional => [
          [:album, nil],
          [:trackNumber, nil],
          [:mbid, nil],
          [:duration, nil],
          [:albumArtist, nil]
        ]
      )

      write_method :unlove, :required => [:artist, :track]

      regular_method(
        :get_info,
        :required => any_params([:artist, :track], :mbid),
        :optional => [
          [:username, nil]
        ]
      ) do |response|
        response.xml['track']
      end

      regular_method(
        :get_correction,
        :required => [:artist, :track]
      ) do |response|
        response.xml['corrections']['correction']
      end

      regular_method(
        :get_top_fans,
        :required => [:artist, :track]
      ) do |response|
        response.xml['topfans']['user']
      end

      regular_method(
        :get_top_tags,
        :required => [:artist, :track]
      ) do |response|
        response.xml['toptags']['tag']
      end

      regular_method(
        :get_similar,
        :required => [:artist, :track],
        :optional => [
          [:limit, nil]
        ]
      ) do |response|
        response.xml['similartracks']['track'][1 .. -1]
      end

      regular_method(
        :search,
        :return_body => true,
        :required => [:track],
        :optional => [
          [:artist, nil],
          [:limit, nil],
          [:page, nil]
        ]
      ) do |response|
        doc = Nokogiri::XML(response)
        tracks = doc.xpath("//trackmatches/track")
        tracks.map { |t|
          {
            :name => t.xpath("name").text,
            :artist => t.xpath("artist").text,
            :url => t.xpath("url").text,
            :streamable => t.xpath("streamable").text,
            :listeners => t.xpath("listeners").text,
            :images => t.xpath("image").map { |image|
              { :size => image["size"], :url =>  image.text }
            }
          }
        }
      end

      method_with_authentication(
        :get_tags,
        :required => [:artist, :track]
      ) do |response|
        response.xml['tags']['tag']
      end
    end
  end
end
