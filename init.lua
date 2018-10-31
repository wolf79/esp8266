wifi.setmode(wifi.STATION)
wifi.sta.config("Marion001-Attacker","chiyeuminhem")
print(wifi.sta.getip())
led1 = 3
led2 = 4
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
		buf = buf.."<head><title>Wifi iot Vu Tuyen</title></head>";
        buf = buf.."<center><h1>Wifi Server V&#361; Tuy&#7875;n</h1></center>";
        buf = buf.."<center><p>Thi&#7871;t B&#7883; 1: <a href=\"?pin=ON1\"><button>B&#7853;t</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>T&#7855;t</button></a></p></center>";
        buf = buf.."<center><p>Thi&#7871;t B&#7883; 2:  <a href=\"?pin=ON2\"><button>B&#7853;t</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>T&#7855;t</button></a></p></center>";
		buf = buf.."<center><br/>&#272;i&#7873;u Khi&#7875;n Thi&#7871;t B&#7883; &#272;i&#7879;n Qua Wifi, Facebook: <a href='https://fb.com/100008756118319' target='_bank'>V&#361; Tuy&#7875;n</a></center>";
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              gpio.write(led1, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
              gpio.write(led1, gpio.LOW);
        elseif(_GET.pin == "ON2")then
              gpio.write(led2, gpio.HIGH);
        elseif(_GET.pin == "OFF2")then
              gpio.write(led2, gpio.LOW);
        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
