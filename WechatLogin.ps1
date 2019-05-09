function Get-WebResponse
{
param(
    [Parameter(Position=0,mandatory=$false)]
    $BaseUrl="https://web.wechat.com",
    [Parameter(Position=1,mandatory=$false)]
    $SubUrl,
    $headers='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
    [hashtable]$GetParameter,
    $session,
    $cookie
)
$FullUrl = $Baseurl+$SubUrl
$Request = [System.UriBuilder]($FullUrl)
$HttpValueCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
foreach ($item in $GetParameter.GetEnumerator()) {
    $HttpValueCollection.Add($Item.Key, $Item.Value)
}
$Request.Query = $HttpValueCollection.ToString()
write-host  $Request.Uri 
$Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $headers  #-SessionVariable 'session'
return $Response
}

# check if uuid can be found in cookie
$LoginGetParameter = @{'appid' = 'wx782c26e4c19acffb'; 'fun' = 'new' }
$LoginSubUrl="/jslogin"
$LoginResponse=Get-WebResponse  -SubUrl $LoginSubUrl -GetParameter $LoginGetParameter 
$regx = "window.QRLogin.code = (\d+); window.QRLogin.uuid = (\S+?);"
if($LoginResponse.Content -match $regx)
{
    if ($matches[1] -eq 200) {
        $uuidwithquotation = $matches[2] 
        $uuid=$uuidwithquotation.Substring(1, $uuidwithquotation.Length - 2)
    }
}
else {
    $uuid=$null
}
 "uuid is {0}" -f $uuid
#downlaod image by uuid
$BaseQrCodePicUri = "https://login.weixin.qq.com/qrcode/"
$QrCodePicUri = $BaseQrCodePicUri + $uuid
#$QrCodePicUri="https://login.weixin.qq.com/qrcode/AbtUISmjlQ=="
#check web is connected or not 
Invoke-WebRequest  -Uri $QrCodePicUri -OutFile Qrcode.jpeg #-SessionVariab  $session

<#Scan the Qrcode on Mobile.
if you dont scan windows.code will be 400,ask the user to scan immediately
the window.code = 201 after you press scan before press confirm.
at the meantime ,the web will load the user icon
after you confirm you will get redirect the url for login 
window.userAvatar = 'data:img/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAoHBwgHBgoICAgLCgoLDhgQDg0NDh0VFhEYIx8lJCIfIiEmKzcvJik0KSEiMEExNDk7Pj4+JS5ESUM8SDc9Pjv/2wBDAQoLCw4NDhwQEBw7KCIoOzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozv/wAARCACEAIQDASIAAhEBAxEB/8QAHAABAAIDAQEBAAAAAAAAAAAAAAMEAgUHAQYI/8QATBAAAQIDAwYGDQcMAwEAAAAAAQIDAAQRBRIhEzFBUWHRBhQicZGTFRYyUlNWc4GSobHS8AcXIzNCVYI0NTdUYmRyg5SywuIkdKLh/8QAGAEBAQEBAQAAAAAAAAAAAAAAAAECAwT/xAAnEQEAAQMDAQgDAAAAAAAAAAAAAQIRMQMTUSEEEjJBUoGRsTNxwf/aAAwDAQACEQMRAD8A5RDmhCPQhCEIBCEIBE7Eqp1BdU4hloGhccJpXUAKknmEQRtLkkpiXTNPLbQGgW7umpVeOY1N4U0YCAq8SS4kmWmG31JFSgApVQZyARj5jXZFWL7zcjLgOSM866+lYKPoijz8+aILQShFpTSWwAgPLCQMwFTAiFfmhCEA5oQhAIQhAIQhAOaEZZNWtPpCGTVrT6RgMYRlk1a0+kIZNWtPpCAxhGWTVrT6Qi1ZrDbloNJfulrEqxBwAJzA4wFOLDMygM5CYayrQNU0VdUg7DQ9BBi+65KPTjbMk3K3VmhU4kgJHfE4bTSmFNMZmUdDiWw1IKWUlRSkElJ5OB28oeuJE3i5HVR4xLyqgqVYWHaApccWFXKjOAAMdprFON6qz50qSOLSClHACtDpwxOoRVm0vSaUqdlJSi+5KRWuAOvaOmKNZCLr4S9IMvJZabWXVpN3k1ACCM52mKmTVrT6YgMYRlk1a0+kIZNWtPpCKMYRlk1a0+kIZNWtPpCAxhGWTVrT6YhAWVMyKFFKpiaSRnBlkgj/ANx5k7P/AFqZ/p0+/F82sSAOPqAGjiqcc+flYnGtTpirNOy029lXp10qpTBgYD0ogrTTCZd+4hZWkoSsKKbpopIVmqdcQxanZkOTALDiy2ltCASLpN1ABwrrEV8q536umAxiRh5Uu8l1IBKdCsxjFz61f8RiaQl0TU62yut1RNaKAOauc5oCTLA49i2afzPej3Kj7rZ6HPejdz0otNpZIqmAXgpzkTmCQM4pcr0CNW/NIl3lNLE9eT++f6RimumrEpExOEKnEg4WWzmGhzV/FHmWwp2LZpzOe9GfZFn9/wD6we5Dsiz+/wD9YPcjaoJl5xxlDfFUsNtqKgEBWJNAa1J1CK0bguJdsiZdQuZopBSpLr18YLaIIwHfGNPAIRmhSktqKSQajN54ZVzwiumKNgiyE9jmpx111KXUqUEoaCqgEg05QrSlThFdbEk2q64/NoOpUsB/nEqphl6WYQucfbU22UrSEVB5Sj32oiJzaKDUcdVdNSU8WFCSan7UZi/mKZakE4GZmRzyyffhEs08xOuhx+dcUoJu1EuBh6W2EUXuJThQpxD1nKbCroVkG8c9Ps4ZoqzSpiVRfvyDqb9zkS7Z/wAfisVOPueAluoTuhx9zwEt1Cd0BnaCEGaBBbQVNNqKUpuipQknACmaK1xPhU+vdHsw+uZeLrl29QJ5KQAAAAMBsAiOAlW4guKIaQQSaGp3RPZ60mcSA0kclWNT3p2xTjNh5cu8l1si8nNUAjoMBNLzSEvlybaM0Ll0BSzh54ncnLOWtSuxoF7QHSKZ81PN0RBx9zwMt1Cd0OPueAluoTugJ1Tdm3wUWYQkaC8onPEUw/JOMlLEmWl3q3soThU4esdEFzzgVgxLZgfqE6uaMePueBluoTugLsslXa/MOXCpAKwTQ0qVM0HqjWX0+CR698Zvzbkw2htaW0oQSoBDYTiaVzcwiGAkBStsjkINQdOOfmjy4nwifXujCEUfRS6ZTsQw0gS6H8mVKdcZQqpK1gUJ5qHA6IhErMVcTxqzLyAD9S3Q+e78UjWJnnUtNtltlaWxdTfaSSBUnPTWTDj7ngJbqE7ozEWSzaNyU64mqX7KFMDebaGPowjV8fc8BLdQndCKq+iVmZyZnEyqZUJYWRcLSK3akYYHMBriVVj2wFJRkZUqWK0CGqj1bR0jVhrJx11q0pkoWpByq60JBzmOg2V8ks7OSEtaDFthkvNhaaINU1GatYjFVcUzaXxsvZ1ozTCXWEyqyqhu5BApUmmJTTONB088epsu01LlWy3LIVMhRQFMowAANTycNEfcj5FZwJui3EAasmd8D8is4rPbiDztnfC8cpuRxPxL4cWTa6lBOQlRUVqptoa9YzjHmpGsM48FGqWKg+Ab3R0z5lp4kE26mo05M7o+M4QcE1WDwnYsRc2HlPXKuhFKXjTNWLHXCbtMZ+ml4673rHUI2bNkOOO96z1CN0dKHyJTP3y11R3w+ZGa++WuqO+JeOV3Y4n4lzYzzyjUpY6hG6PBOuj7LHUI3bI6V8yM198tdUd8PmSmvvlrqjvheOTcjifiXNeOO0pdZ6hG+HHXT9ljqEbdm2NzI8FVT3DFXB0TYSpLikZYowwGqsfY/MlM/fLXUnfFnplN2mcfTmvHXa1usdQjdDjjves9QjfHSvmSmfvlrqjuh8yUz98tdSd8S8LuRxPxLmvHXe9Y6hG7bDjrta3WOoRujo7/AMi8www48q2WyG0lRAZOgV1xzEihI1GKtNcVTaFibIJZVRIKmgTdAArjoEI8mgbsv5Ee0wg2T35wmfKq9pj9D2Y2lzgPIhailIl2zUJvUpTRX24a8I/PE9+cJnyqvaY/SPBttDvBSzkOIStJlkVSoVBwjNWHOfyR+p/jXoclCylTluTKXEk1VVYGjXXDT59VYmPFX5FLztpXboCS6pCqpN4qF0nEaQTpAzikZoatFTDaXLGlFKIvLKrtATnwHNXo80yhaPE0Us2WUo3so1gB3QugY0PJKvjCOTqisstzE20UWjMP5JJWlLiFAEYprU4HE+zbXmfyi/pRkv5H90dasxL1FrmJJuWXouAVodGBOz4Ecl+UX9KMl/I/vjpp5ebtPhj3+odcftWTlZoSz7txeTDmIwpWkauaXJzkzl2LVUxfAKsmlQUoUoKHn0c+nNdtEThfTkLPZmW7gxXSt6u05gK+cxG2zMqeWexEsykBRaUQkqBpyc2+Ob0xhAwqXZfTMotZ0sS+LyHCqlFA3cDzj1a42Mra8nOPqZZWoqTpKCAeY5tEUGhaSApHYmXAIqaBIqQKgZ8TXmz7Ilstc4uZOWspmVSDyligNaaNefPt2YlcqsD9Mzn/AGXPZHUJmQRJrW9MWmthhxRAQmoF5VduOvHVqwjl9g/pnc/7LntjrdpG0MqkS0ozMtBOKXCO6NRp2e2mnDrqeTy9nx7R9NbLvMKlZparRfdYbRX6ZKlE3SCcDgoZhQZ67RHikyhqXLadu3ipISFAJABwSM12h9UW5UWkC8FWXLtC4pTd273dAQDQ6xn2DNEeRnUqWlmx5cACiVqQgFQJxBAOFceiOT02SmSdalX5gTrr7CpNQCXFE1JGfHm9cfmpfdq54/Ty1PqsR/jDCGFhpYuINQBQ0j8wr7tXPHSjDlH5J/Uf1PNdzL+SHtMI8me5Y8kPaYRt0J/G0Zmta5ZWfnMfTN8LOFEggSaOELbSWPow2Ps0wp3MfMz/AOcJjR9Kr2nmizPSpen5h1uYlihx1SknLpFQSSNMGaqKasw3/bvwq8Zm/j8MO3fhV4zI6f8AWPmuIL8PLdenfDiC/Dy3Xp3wZ2tPh9L278KvGZHT/rGqnrQtC07SbtGctaXemmrt1xVaihqPsxmHWCyhDklIqKEpTeE0gVppO06deyPEvIQ+pxMrIALZLSkCYSAampVhpgRpUR5Nn278KvGZv4/BDt34VeMzfx+GNep6UUCDZ8iARTkzSBT1RC+WnWFtplZFtSgAFpmEcmhr/wDPNz1Gzp+mW27d+FXjM38fhh278KvGZv4/DFF6bafSS5I2blCrukvoAAvEkU21OPRSPXH5ItjJWfIpcNa1mGyBq5/jbUbOn6YVmZ6fl7XNrNWtLpnVKKi6K1qc57msbbt34VeMyPj8Ma/jLAWhSZCzklKrx+nRiNXs6NpjGTmTKMIaDEisoJJWZhNVVIJ9QAGqBOlpzmIbLt34VeMyPj8MO3fhV4zI+Pwx80ZFZJOXlsf3hG+HEF+HluvRugmzp+mX0iuGvChaChfCRtSVChB0j0Y+VmGVsPracIKknEg4GJuIL8PLdejfHloKSuedKFBSagVBqDhBqmimnwxZjN9zL+RHtMI9mhyZfyI9phBtk8/KPPLdVLvArUVEB4UxNe9jC/J+Af64bP2eeIIRRZbTLvKutSkytVK0S6D/AI80TPy6EDKKs+cSgAVKl0A/8c0YWSl1VoN5MEpBBcA0oqK669Bi7aTai24qXYmW0ADKKXVKCK6jnxpjhzCEZtaWJqm9mtC5PTLv9cPd54X5Sn1D1fLD3YghBtOVyeiXf64bf2eaAVJ1/J3+uHuxBG14LuSzXCWQcnFITLpdq4VmgpQ6YgpqVKXUf8d/AY/SjX/BGN+T/V3+uG39nmjpXCO1eDM3Yk61LGXyuSORuvkkqw0V545dGaKu9F4J6J78nX8nfp5Ye7C/J/q7/XDZ+zzxBCNiwgSzqghuVmFqOYJdBJPNdiSYTLNOlLkpMoVqU6Af7Iv8EZwSNth0vJaq0pN5RFDWmGMbzhtMSdpWcxNhaDMNOllIQ4CLgxJoBTE7Y1t1W70YeedeI1dq3u+PC5PTLv8AXDZ+zzwvylPqHq+WHuxBCMvQlmHUOqTk0FCUJugKUCekAQiKEAhCEAzQqdcIQQhCEVSEIRAhCEAhCEUIQhECEIQCEIQH/9k=';
#>
$time = [int](get-date -UFormat %s)
$time1 = [int] - $time / 1579
$time2 = $time
$CheckLoginSubUrl = '/cgi-bin/mmwebwx-bin/login'
$CheckLoginParameter = @{'location' = 'ture'; 'uuid' = $uuid; 'tip' = '1'; 'r' = $time1; 's' = $time2 }
#wait for the redirect url after press confirm on mobile
$islogging=$True
while ($islogging)
{
    $CheckLoginResponse=Get-WebResponse  -SubUrl $CheckLoginSubUrl -GetParameter $CheckLoginParameter
    $regx = "window.code=(\d+);"
    if ($CheckLoginResponse.content -match $regx)
    {
        if($matches[1] -eq 200)
        {
        $islogging=$False
        $regx = "window.redirect_uri=(\S+);"
        $CheckLoginResponse.content -match $regx
        write-host $matches[1]
        
        }
        elseif($matches[1] -eq 201)
        {
        write-host -ForegroundColor Yellow "Press confirm on the mobile"   
        }
        elseif($matches[1] -eq 408)
        {
        write-host -ForegroundColor Yellow "Press scan  on the mobile"
        }
        else {
        write-host   "unkonw reason,the windows code is $matches[1]"
        }

        Start-Sleep 3
    }
}





#$CheckLoginResponse=Get-WebResponse  -SubUrl $CheckLoginSubUrl -GetParameter $CheckLoginParameter
#$CheckLoginUrl=$BaseUrl+'/cgi-bin/mmwebwx-bin/login'

#https://login.wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid=YYZwaWlqGg==&tip=1&r=1675818805&_=1557397308599


#window.code=200;
#window.redirect_uri="https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxnewloginpage?ticket=AQNnO1W0Qy-CKlFPrnXeTSoQ@qrticket_0&uuid=oYKCPxJi3A==&lang=en_&scan=1557403466";