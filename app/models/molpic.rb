class Molpic
  
  attr_reader :cas
  
  def initialize(cas)
    raise "cas invalid" unless Molpic.cas_valid?(cas)
    @cas = cas.strip
  end
  
  def fetch
    download! unless cached?
    raise "molpic.fetch :: unsuccessful :: #{local_path} " unless cached?
    File.read(local_path)
  end
  
  def cached?
    File.exist? local_path
  end
  
  def local_path
    Rails.root.join *%w(public molecules), "#{@cas}.jpg"
  end
  
  def path
    "/molecules/#{@cas}.jpg"
  end
  
  def download!
    http = Net::HTTP::new remote_server, 80
    response = http.get remote_path, {"Referer" => remote_referer}
    if response.code.to_i == 200
      init_directory
      f = File.open(local_path, "w:ASCII-8BIT")
      f.write response.body
      f.close
    else
      raise "Molpic.download! failed :: #{response.inspect}"
    end
  end

  def self.fetch(cas)
    m = Molpic.new(cas)
    m.fetch
  end
  
  def self.cas_valid?(cas)
    return nil unless cas
    splitted = cas.strip.split("-")
    return false if splitted.size != 3
    return false if splitted[0].size < 2 || splitted[0].size > 7 || splitted[1].size != 2 || splitted[2].size != 1
    cnrs = cas.gsub(/[^\d]/,'')
    cd = cnrs[cnrs.size - 1,1].to_i
    csum = 0
    (cnrs.size - 1).times do |n|
      csum += cnrs[cnrs.size - 2 - n,1].to_i * (n + 1)
    end
    csum % 10 == cd
  end
  
  
  protected
  
  def init_directory
    dir = local_path.to_s.gsub(/\/[^\/]+\z/,'')
    Dir.mkdir dir unless File.exist? dir
  end
  
  def remote_server
    "www.thegoodscentscompany.com"
  end
  
  def remote_path
    "/picmol/#{@cas}.jpg"
  end
  
  def remote_referer
    "http://www.thegoodscentscompany.com/data/rw106#{rand(9)}#{rand(9)}#{rand(9)}#{rand(9)}.html"
  end
  
  
  
  
end
