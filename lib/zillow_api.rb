class ZillowAPI
  require 'open-uri'
  require 'nokogiri'

  ZILLOW_API_URL      = "http://www.zillow.com/webservice/GetSearchResults.htm?rentzestimate=true"
  ZILLOW_DEMO_URL     = "http://www.zillow.com/webservice/GetDemographics.htm?"
  ZILLOW_API_ZPID_URL = "http://www.zillow.com/webservice/GetZestimate.htm?rentzestimate=true"

  def initialize(api_key)
    @api_key = api_key
  end

  def get_zpid(address_num:, address_street:, address_street_type:nil, address_city:nil, address_state:nil, address_zip:nil)
    if address_zip && address_street_type
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_num)}%20#{CGI::escape(address_street)}%20#{CGI::escape(address_street_type)}&citystatezip=#{CGI::escape(address_zip)}"))
    elsif address_zip && address_street_type.nil?
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_num)}%20#{CGI::escape(address_street)}&citystatezip=#{CGI::escape(address_zip)}"))
    elsif address_zip.nil? && (address_city && address_state && address_street_type)
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_num)}%20#{CGI::escape(address_street)}%20#{CGI::escape(address_street_type)}&citystatezip=#{CGI::escape(address_city)}%20#{CGI::escape(address_state)}"))
    elsif address_zip.nil? && (address_city && address_state && address_street_type.nil?)
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_num)}%20#{CGI::escape(address_street)}&citystatezip=#{CGI::escape(address_city)}%20#{CGI::escape(address_state)}"))
    else
      return "SOMETHING WITH THE ADDRESS ISNT RIGHT"
    end

    if property.css("zpid")[0] && (property.css("zpid")[0].text.to_i.to_s == property.css("zpid")[0].text)
      return { zpid: property.css("zpid")[0].text }
    else
      return {zillow_error_code: property.css('message').children[1].text, zillow_error_code_text: property.css('message').children[0].text}
    end
  end

  def get_property_by_address(address_num:nil, address_street:, address_street_type:nil,address_city:nil,address_state:nil,address_zip:nil)
    if address_num.nil? && (address_street && address_zip)
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_street)}&citystatezip=#{CGI::escape(address_zip)}"))
    elsif address_zip && address_street_type
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_num)}%20#{CGI::escape(address_street)}%20#{CGI::escape(address_street_type)}&citystatezip=#{CGI::escape(address_zip)}"))
    elsif address_zip && address_street_type.nil?
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_num)}%20#{CGI::escape(address_street)}&citystatezip=#{CGI::escape(address_zip)}"))
    elsif address_zip.nil? && (address_city && address_state && address_street_type)
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_num)}%20#{CGI::escape(address_street)}%20#{CGI::escape(address_street_type)}&citystatezip=#{CGI::escape(address_city)}%20#{CGI::escape(address_state)}"))
    elsif address_zip.nil? && (address_city && address_state && address_street_type.nil?)
      property = Nokogiri::HTML(open("#{ZILLOW_API_URL}&zws-id=#{@api_key}&address=#{CGI::escape(address_num)}%20#{CGI::escape(address_street)}&citystatezip=#{CGI::escape(address_city)}%20#{CGI::escape(address_state)}"))
    else
      return "SOMETHING WITH THE ADDRESS ISNT RIGHT"
    end

    if property.css("zpid")[0].text.to_i.to_s == property.css("zpid")[0].text
      property_data = {}
      property_data = { zpid:             property.css("zpid")[0].text,
        street:           property.css("address")[1].children[0].text,
        zip_code:         property.css("address")[1].children[1].text,
        city:             property.css("address")[1].children[2].text.downcase,
        state:            property.css("address")[1].children[3].text.downcase,
        latitude:         property.css("address")[1].children[4].text,
        longitude:        property.css("address")[1].children[5].text,
        zestimate:        property.css("zestimate")[0].children[0].text,
        rent_zestimate:   property.css("rentzestimate")[0].children[0].text,
        neighborhood_id:  property.css("localrealestate")[0].children.css("region").first["id"],
        neighborhood_name: property.css("localrealestate")[0].children.css("region").first["name"],
        neighborhood_type: property.css("localrealestate")[0].children.css("region").first["type"]
      }
      return property_data
    else
      return {zillow_error_code: property.css('message').children[1].text, zillow_error_code_text: property.css('message').children[0].text}
    end
  end

  def get_property_by_zpid(zpid:)
    property = Nokogiri::HTML(open("#{ZILLOW_API_ZPID_URL}&zws-id=#{@api_key}&zpid=#{zpid}"))

    if property.css("zpid")[0].text.to_i.to_s == property.css("zpid")[0].text
      property_data = {}
      property_data = { zpid:           property.css("zpid")[0].text,
        street:         property.css("address").children[0].text,
        zip_code:       property.css("address").children[1].text,
        city:           property.css("address").children[2].text.downcase,
        state:          property.css("address").children[3].text.downcase,
        latitude:       property.css("address").children[4].text,
        longitude:      property.css("address").children[5].text,
        zestimate:      property.css("amount").children[0].text,
        rent_zestimate: property.css("rentzestimate")[0].children[0].text
      }
      return property_data
    else
      return { zillow_error_code: property.css('message').children[1].text, zillow_error_code_text: property.css('message').children[0].text }
    end
  end

  def get_demographics_by_id(regionid)
    demo_stats = Nokogiri::HTML(open("#{ZILLOW_DEMO_URL}&zws-id=#{@api_key}&regionid=#{CGI::escape(regionid)}"))
    if demo_stats.css("regionid").text.to_i.to_s == demo_stats.css("regionid").text
      demo_data = {}
      neighborhood_data = {}
      nation_data = {}
      city_data = {}

      #get city data
      demo_stats.css("attribute").each do |att|
        city_data[att.css("name").text.downcase] = att.css("city").text.downcase
      end

      #get neighborhood data
      demo_stats.css("attribute").each do |att|
        neighborhood_data[att.css("name").text.downcase] = att.css("neighborhood").text.downcase
      end

      #get nation data
      demo_stats.css("attribute").each do |att|
        nation_data[att.css("name").text.downcase] = att.css("nation").text.downcase
      end

      demo_data = {     id:                 demo_stats.css("region").children[0].text,
                        state:              demo_stats.css("region").children[1].text.downcase,
                        city:               demo_stats.css("region").children[2].text.downcase,
                        neighborhood:       demo_stats.css("region").children[3].text.downcase,
                        latitude:           demo_stats.css("region").children[4].text,
                        longitude:          demo_stats.css("region").children[5].text,
                        neighborhood_data:  neighborhood_data,
                        city_data:          city_data,
                        nation_data:        nation_data
      }
      return demo_data
    else
      return {zillow_error_code: demo_stats.css('message').children[1].text, zillow_error_code_text: demo_stats.css('message').children[0].text}
    end
  end
end
