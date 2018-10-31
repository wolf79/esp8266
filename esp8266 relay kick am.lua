wifi.setmode(wifi.STATION)
wifi.sta.config("Marion001-Attacker","chiyeuminhem")
print(wifi.sta.getip())
buff_led1="load"
buff_led2="load"
buff_led1_on=" Tr&#7841;ng Th&#225;i: <font color='red'><b>&#272;ang T&#7855;t</b></font>"
buff_led1_of=" Tr&#7841;ng Th&#225;i: <font color='Green2'><b>&#272;ang B&#7853;t</b></font>"
buff_led2_on=" Tr&#7841;ng Th&#225;i: <font color='red'><b>&#272;ang T&#7855;t</b></font>"
buff_led2_of=" Tr&#7841;ng Th&#225;i: <font color='Green2'><b>&#272;ang B&#7853;t</b></font>"
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
        if(gpio.read(3)==1)then
            buff_led1=buff_led1_on
        elseif(gpio.read(3)==0)then
            buff_led1=buff_led1_of
        end
        if(gpio.read(4)==1)then
            buff_led2=buff_led2_on
        elseif(gpio.read(4)==0)then
            buff_led2=buff_led2_of
        end
        buf = buf.."<head><title>Wifi iot V&#361; Tuy&#7875;n</title></head>";
		buf = buf.."<h1 align=\"center\"><p>Wifi Server V&#361; Tuy&#7875;n</p></h1>";
        buf = buf.."<h1 align=\"center\"><a href='./'>Trang Ch&#7911;</a></h1>";
        buf = buf.."<p align=\"center\">Thi&#7871;t B&#7883; 1: ";--//
        buf = buf.."<a href=\"?pin=ON1\"><button>T&#7855;t</button></a>";--//
        buf = buf.."&nbsp;<a href=\"?pin=OFF1\"><button>B&#7853;t</button></a>";
        buf = buf..(buff_led1);
        buf = buf.."</p>";
        buf = buf.."<p align=\"center\">Thi&#7871;t B&#7883; 2: ";
        buf = buf.."<a href=\"?pin=ON2\"><button>T&#7855;t</button></a>";
        buf = buf.."&nbsp;<a href=\"?pin=OFF2\"><button>B&#7853;t</button></a>";
        buf = buf..(buff_led2);
        buf = buf.."</p>";
        buf = buf.."<h1 align=\"center\">";
        buf = buf.."&#272;i&#7873;u Khi&#7875;n Thi&#7871;t B&#7883; &#272;i&#7879;n Qua Wifi, Facebook: <a href='https://fb.com/100008756118319' target='_bank'>V&#361; Tuy&#7875;n</a></h1>";
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
