# Authors: Djok_39
# License: Apache 2.0
require "./macro_orm"
require "./models/*"
require "socket"
require "digest/sha1.cr"

Process.new("mosquitto_pub", args: {"-t", "error/aggregator", "-m", "0"})
Orm.db.exec "SET search_path TO #{Schema};"

Time::Location.load_local

def handle_client(socket)
  r = Random.new
  socket.each_line do |message|
    json = JSON.parse(message)
    pp json
    if wave = json["wave"].as_f? || json["wave"].as_i?
      hash = Elon.new
      row = Microwave.new(json["strength"].as_i.to_i16, json["bounces"].as_i.to_i16)
      row.length = wave.to_f
      wave_ms = json["wave_ms"].as_f? || json["wave_ms"].as_i
      row.length_ms = wave_ms.to_f
      # row.digest = Sha1.new(json["digest"].as_s)
      if ts = json["timestamp"]?
        seconds = ts.as_f 
        nanoseconds = ((seconds - seconds.floor).round(6) * 1000000).round(0).to_i
        nanoseconds *= 1000
        utc_epoch_sec = 62135596800_i64 + seconds.floor.to_i64
        setTime = Time.new(seconds: utc_epoch_sec, nanoseconds: nanoseconds, location: Time::Location.local) #
        row.timestamp = setTime
      end
      if digest2 = json["data_digest"]?
        #str2 = a.as_a.map{  |x| x["elapsed"].as_i.to_s  }.join("_")
        #calculated = Digest::SHA1.hexdigest(str2)
        #is_same = (calculated.to_s == digest2.as_s)
        # puts "data_digest: #{ (is_same) ? "ok" : "broken" }"
        # row.data_digest = Sha1.new(digest2.as_s) #  if is_same
      end
      wave_id = row.insert
      str = "%.6f%i%.6f%i%.6f" % [json["timestamp"].as_f, json["strength"].as_i, wave_ms, json["bounces"].as_i, wave]
      hash.digest = Hptapod.new `echo -n "#{str}" | sha512sum`.split(' ').first
      hash.id = wave_id
      is_broken = Digest::SHA1.hexdigest(str)!=json["digest"].as_s
      puts "sha1: #{ (!is_broken) ? "ok" : "broken" } id=#{wave_id}"
      if is_broken
        Process.new("mosquitto_pub", args: {"-t", "error/aggregator", "-m", "262146"})
      end
      socket << "OK\n"
      if a = json["data"]?
        data = a.as_a.sort{  |a,b| a["elapsed"].as_i <=> b["elapsed"].as_i  }
        data.each do |json|
          sub = Impuls.new(wave_id, json["logic"].as_bool, json["strength"].as_i.to_i16, json["edge"].as_i, json["elapsed"].as_i)
          sub.save!
        end
        `echo -n "#{ data.map{  |t| t["elapsed"].as_i.to_s  }.join("_") }" | sha512sum`.split(' ').first
        hash.data_digest = Hptapod.new `echo -n "#{ "%08x%.6f" % [r.rand(0x00100000), Time.utc.to_unix_f] }" | sha512sum`.split(' ').first
      elsif (fall = json["fall"]?) || (cold = json["raise"]?)
        raise_time = cold ? cold.as_i : 0_i32
        fall_time = fall ? fall.as_i : 0_i32
        Impuls.new(wave_id, true, row.strength, raise_time, 0).save!
        Impuls.new(wave_id, false, 0_i16, fall_time, (row.length_ms * 10000.0).ceil.to_i).save!
        if digest2
          str2 = "0_#{ (row.length_ms * 10000.0).ceil.to_i }"
          calculated = Digest::SHA1.hexdigest(str2)
          is_same = (calculated.to_s == digest2.as_s)
          puts "#{ str2 }_digest: #{ (is_same) ? "ok" : "broken" }"
        end
      end
      hash.insert_with_id
    else
      socket << "protocol break\n"
      Process.new("mosquitto_pub", args: {"-t", "error/aggregator", "-m", "262147"})
    end
  end
  socket.close
rescue ex
  # puts "connection reset by peer: #{ex}"
  socket.close
end

server = TCPServer.new("192.168.2.12", 490)
while client = server.accept
  spawn handle_client(client)
end
puts "TCPServer stopped"
