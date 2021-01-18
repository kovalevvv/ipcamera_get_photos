require 'net/http'
require 'fileutils'
require 'time'

class Tantos

  def initialize(path, user = 'admin', pass = '12345')
    @uri = URI(path)
    @user = user
    @pass = pass
    @request = Net::HTTP::Get.new(@uri)
    @dir = '/home/vladimir/cam'
  end

  def get
    begin
      @res = Net::HTTP.start(@uri.hostname, @uri.port) {|http| http.request(@request) }
    rescue StandardError
      @res = nil
    end
  end

  def write
    time = Time.new
    dir = '%s/%s/%s/%s/%s' % [@dir, @uri.hostname, time.year, time.month, time.day]
    FileUtils::mkdir_p dir
    count = Dir.glob(File.join(dir, '**', '*')).select { |file| File.file?(file) }.count
    filename = '%s/%.3d_%s.jpg' % [dir, count, time.strftime("%H-%M-%S")]
    File.open(filename, 'w') { |file| file.write(@res.body) }
    puts filename
    current(filename.gsub(/\/home\/vladimir/, ''))
  end

  def current(filename)
    File.open('%s/%s/current.txt' % [@dir, @uri.hostname], 'w') { |file| file.write(filename)}
  end



  def go
    get
    write if @res
  end

end

class Hikvision < Tantos
  
  def get
    auth
    super
  end

  def auth
      @request.basic_auth @user, @pass
  end

end

def delay(start_time: {c: 1, m: 0}, end_time: {c: 7, m: 0})
  t = Time.now
  early = Time.new(t.year, t.month, t.day, start_time[:c], start_time[:m], 0, t.utc_offset)
  late  = Time.new(t.year, t.month, t.day, end_time[:c], end_time[:m], 0, t.utc_offset)
  t.between?(early, late) ? 20 : 20
end

cams = [
  Hikvision.new('http://10.4.4.21/Streaming/channels/1/picture', 'admin', 'hbujylf1'),
  Hikvision.new('http://10.4.4.20/Streaming/channels/1/picture', 'admin', 'hbujylf1'),
  Hikvision.new('http://10.4.4.19/Streaming/channels/1/picture', 'admin', 'hbujylf1'),
  Hikvision.new('http://10.4.4.10/Streaming/channels/1/picture', 'admin', 'hbujylf1'),
  Hikvision.new('http://10.4.4.12/Streaming/channels/2/picture?snapShotImageType=JPEG'),
  Hikvision.new('http://10.4.4.11/Streaming/channels/2/picture?snapShotImageType=JPEG'),
  Hikvision.new('http://10.4.4.13/Streaming/channels/2/picture?snapShotImageType=JPEG'),
  Hikvision.new('http://10.4.4.14/Streaming/channels/2/picture?snapShotImageType=JPEG'),
  Hikvision.new('http://10.4.4.15/Streaming/channels/2/picture?snapShotImageType=JPEG'),
  Tantos.new('http://10.4.4.6:8090/onvif/snapshot/1/1')
]

loop do
  cams.each do |c|
    c.go
  end
  sleep(delay)
end





