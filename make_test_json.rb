require 'rubygems'
require 'net/ldap'
require 'openssl'
require 'json'

host = "ldap.puppetlabs.com"
port = 636
base = "dc=puppetlabs,dc=com"
username = "tom.kishel"
password = "94=WRZCzXhU*voZ"

puppeteers = []

auth = { :method => :simple, :username => "uid=#{username},ou=users,#{base}", :password => password }
ldap = Net::LDAP.new(:host => host, :port => port, :base => base, :encryption => :simple_tls, :auth => auth)
ldap.bind

attrs = ["uid", "givenname", "sn", "ou", "title", "personaltitle", "physicaldeliveryofficename", "mobile", "objectclass"]
# attrs = []
filter = Net::LDAP::Filter.eq( "objectclass", "puppetPerson" )
ldap.search(:base => "dc=puppetlabs,dc=com", :attributes => attrs, :filter => filter, :return_result => true) do |entry|
    #puts entry.uid
    #puts entry.objectclass
    #puts
    puppeteer = {}
    puppeteer['first_name'] = entry['givenname'][0]
    puppeteer['last_name'] = entry['sn'][0]
    puppeteer['ou'] = entry['ou'][0]
    puppeteer['job_title'] = entry['title'][0]
    puppeteer['personaltitle'] = entry['personaltitle'][0]
    puppeteer['photo_path'] = "#{entry['uid'][0]}.jpg".downcase
    puppeteer['office'] = entry['physicaldeliveryofficename'][0] == 'Headquarters' ? 'Portland' : ''
    puppeteer['floor'] = 5
    puppeteer['location_x'] = 256
    puppeteer['location_y'] = 512
    puppeteer['mobile'] = entry['mobile'][0]

    next unless (puppeteer['first_name'])
    next unless (puppeteer['last_name'])
    puppeteers.push(puppeteer)
end

puts '{"puppeteeers":' + puppeteers.to_json + '}'
