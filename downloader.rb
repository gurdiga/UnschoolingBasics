require 'open-uri'
require 'json'
require 'pp'

def main
    previous_topic_id = get_json('https://groups.yahoo.com/api/v1/groups/UnschoolingBasics/topics')["ygData"]["lastTopic"]

    while previous_topic_id != 0 do
        topic_url = "https://groups.yahoo.com/api/v1/groups/UnschoolingBasics/topics/#{previous_topic_id}"

        filename = "topic-#{previous_topic_id}.json"
        previous_topic_id = get_json(topic_url, filename)["ygData"]["prevTopicId"]
    end
end

def get_json(url, filename = nil)
    headers = {
        'Cookie' => 'T=z=qAlzdBkvy6dB9cK8DOTKHm6NDUzNwY2NjNPMzYwTjYyMTYzND&a=QAE&sk=DAALM2tjoijvgn&ks=EAAUljh0fc4fY9xe7JMgIIy5g--~G&kt=EAAH9fYmMYGcfdFOX8UvtJPWw--~I&ku=FAAWLbfX8ep.L9V.jsdrVimB806XgutiWb6fRm1.XvKGinXfeLJSSX9FRN1OnXVs25QxHkZnOUpQQos53fQWqSMnNDppWUBcAf1QXrNAns5ZDGuwYP7ov7IISyPABYF5PIraNsdBU_S0kE73.7ugy3uwPEN9hkgsVVyJWAb9f6jo_s-~A&d=bnMBeWFob28BZwE3NllSTkkzTEdaUFdXU0I3N1FCQkJVT0RPRQFzbAFNekkwTUFFeE1UUTROREUzT1RFMU5qRTBNemM0TVRFLQFhAVFBRQFhYwFBQ0tOZURPVgFsYXQBd2wud2RCAWNzAQFhbAFndXJkaWdhQGdtYWlsLmNvbQFzYwFkZXNrdG9wX3dlYgFmcwFsTFFSMjU1ZHFXVDIBenoBd2wud2RCZ3NI&af=JnRzPTE1NzM4MDIwMjYmcHM9M2ZhU0hGOFpmU3FVV0xsYjM0Zmtrdy0t; Y=v=1&n=2fqphm0q00cav&l=6kh3860/o&p=m2fvvmd00000000&iz=2062&r=rs&intl=us;'
    }

    basename = filename || "#{File.basename(url)}.json"
    path = "cache/#{basename}"

    if path != "cache/topics.json" && File.exist?(path) then
        puts "Found cached response for #{url}"
        cached_json = IO.read(path)
        parsed_cached_json = JSON.parse(cached_json)

        unless parsed_cached_json['ygData']['messages'] then
            pp path
            pp parsed_cached_json['ygData']
        end

        post_timestamp = parsed_cached_json['ygData']['messages'].first['postDate'].to_i
        file_timestamp = File.mtime(path).to_i

        return parsed_cached_json if post_timestamp < file_timestamp
    end

    puts "Fetching #{url}"
    fetched_json = open(url, headers).read
    IO.write(path, fetched_json)
    JSON.parse(fetched_json)
end

main
