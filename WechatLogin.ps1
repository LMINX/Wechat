$global:WebSession=$null
$global:UserAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' 
$global:WxCore=[pscustomobject]@{}
$global:WxContracts=@()
function Get-WebResponse
{
param(
    [Parameter(Position=0,mandatory=$false)]
    $BaseUrl="https://web.wechat.com",
    [Parameter(Position=1,mandatory=$false)]
    $SubUrl,
    $UserAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
    [hashtable]$GetParameter,
    $AllowRedirect=$True,
    $session=$global:WebSession,
    $ContentType,
    $Body,
    $Method,
    $Timeout
)
$FullUrl = $Baseurl+$SubUrl
$Request = [System.UriBuilder]($FullUrl)
$HttpValueCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    if ($GetParameter -ne $null)
    {
        foreach ($item in $GetParameter.GetEnumerator()) {
            $HttpValueCollection.Add($Item.Key, $Item.Value)
        }
        $Request.Query = $HttpValueCollection.ToString()
    }
    #write-host  $Request.Uri 
    if ($global:WebSession -ne $null)
    {
        if($AllowRedirect){
            if($ContentType -ne $null -and $Body -ne $null -and $method -ne $null)
            {
              #  "Type 1"
                if($Timeout -ne $null)
                {
                    $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -WebSession $global:WebSession -ContentType $ContentType -Body $Body -Method $Method -TimeoutSec $Timeout
                }
                else{
                    $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -WebSession $global:WebSession -ContentType $ContentType -Body $Body -Method $Method
                }
                
            }
            else{
              #  "Type 2"
              if($Timeout -ne $null)
              {
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -WebSession $global:WebSession -TimeoutSec $Timeout
              }
              else {
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -WebSession $global:WebSession
              }
                
            }
            
        }
        else{
            if($ContentType -ne $null -and $Body -ne $null -and $method -ne $null)
            {
               # "Type 3"
               if($Timeout -ne $null){
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -WebSession $global:WebSession -MaximumRedirection 0 -ContentType $ContentType -Body $Body -Method $Method -TimeoutSec $Timeout
               }
               else{
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -WebSession $global:WebSession -MaximumRedirection 0 -ContentType $ContentType -Body $Body -Method $Method
               }
                
            }
            else{
              #  "Type 4"
                "not allow redirect"
                if($Timeout -ne $null){
                    $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -WebSession $global:WebSession  -MaximumRedirection 0  -TimeoutSec $Timeout #-SessionVariable 'session'
                }
                else {
                    $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -WebSession $global:WebSession  -MaximumRedirection 0 #-SessionVariable 'session'
                }
                 
            }
        }

    }
    else
    {
        if($AllowRedirect){
            if($ContentType -ne $null -and $Body -ne $null -and $method -ne $null)
            {
              #  "Type 5"
              if($Timeout -ne $null){
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -SessionVariable WebSession -ContentType $ContentType -Body $Body -method $Method -TimeoutSec $Timeout
              }
              else{
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -SessionVariable WebSession -ContentType $ContentType -Body $Body -method $Method
              }
                
            }
            else{
              #  "Type 6"
              if($Timeout -ne $null)
              {
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent  -SessionVariable WebSession -TimeoutSec $Timeout
              }
              else {
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent  -SessionVariable WebSession             
              }

            }
            $global:WebSession=$WebSession
        }
        else{
            if($ContentType -ne $null -and $Body -ne $null -and $method -ne $null)
            {
              #  "Type 7"
              if($Timeout -ne $null){
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -SessionVariable WebSession -MaximumRedirection 0 -ContentType $ContentType -Body $Body -method $Method -TimeoutSec $Timeout
              }
              else{
                $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent -SessionVariable WebSession -MaximumRedirection 0 -ContentType $ContentType -Body $Body -method $Method                  
              }

            }
            else{
              #  "Type 8"
                "not allow redirect"
                if($Timeout -ne $null){
                    $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent  -SessionVariable WebSession -MaximumRedirection 0  -TimeoutSec $Timeout #-SessionVariable 'session' 
                }
                else {
                    $Response= Invoke-WebRequest -Uri $Request.Uri -UserAgent $UserAgent  -SessionVariable WebSession -MaximumRedirection 0 #-SessionVariable 'session'
                }
                
            }
            $global:WebSession=$WebSession
        }

    }
return $Response
}

function CoventTo-CookiesObj
{
    param 
    (
        $StringCookies,
        $regex='[\w]+=[\w\+/=-]+'
    )
    $CookiesObj=[pscustomobject]@{}
    $reg=[regex]::new($regex)
    $matches=$reg.Matches($StringCookies)
    if($matches.Count -gt 0){
        #get wxid
        foreach($m in $matches)
        {
            $item=$m.groups.value
            $EqualPosition=$item.indexof("=")
            $key=$item.substring(0,$EqualPosition)
            $Value=$item.substring($EqualPosition+1)
            $CookiesObj|Add-Member -NotePropertyName $key -NotePropertyValue $Value
        }      
        return  $CookiesObj
    }
    else {
        "throw unmatched exception"
    }
}

function Get-WxContract
{
    param($seq)
#   $WechatMsgID=$CustomerWebwxStatusNotifyResponse.MsgID
    $WebwxGetContactSubUrl='/webwxgetcontact'
    $UserAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' 
    $global:WxCore.WxAPIBaseUrl
    $WebwxGetContactGetParameter=[ordered]@{
    'pass_ticket'=$RedirectGetParameter.pass_ticket
    'r'=[int]((get-date -UFormat %s)/1579*(-1))
    'seq'=$seq
    'skey'=$global:WxCore.skey
    }   
    $WebwxGetContactResponse=Get-WebResponse -BaseUrl $global:WxCore.WxAPIBaseUrl -SubUrl $WebwxGetContactSubUrl -GetParameter $WebwxGetContactGetParameter -UserAgent $global:UserAgent -AllowRedirect $True
    $WebwxGetContactResponseUTF8Encoding=[system.Text.Encoding]::UTF8.GetString($WebwxGetContactResponse.RawContentStream.ToArray())
    $JsonWebwxGetContactResponseUTF8Encoding=$WebwxGetContactResponseUTF8Encoding|ConvertFrom-Json
    return $JsonWebwxGetContactResponseUTF8Encoding
}


#1.Get UUID ,can find in $global:websession ,need test on 6/6
if($global:WebSession -ne $null)
{
    $WxCookiesWebUri="https://wx.qq.com"
    $WxCookies=$global:WebSession.Cookies.GetCookieHeader($WxCookiesWebUri)
    $WxCookiesObj=CoventTo-CookiesObj -StringCookies $WxCookies
    if ($WxCookiesObj.wxuin){
        $PushLoginBaseUrl="https://login.weixin.qq.com/cgi-bin/mmwebwx-bin"
        $PushLoginSubUrl="/webwxpushloginurl"
        $PushLoginFullUrl=$PushLoginBaseUrl+$PushLoginSubUrl
        $PushLoginRequest = [System.UriBuilder]($PushLoginFullUrl)
        $HttpValueCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $PushLoginGetParameter=[ordered]@{
            'uin'=$WxCookiesObj.wxuin
        }
        if ($PushLoginGetParamete -ne $null)
        {
            foreach ($item in $PushLoginGetParameter.GetEnumerator()) {
                $HttpValueCollection.Add($Item.Key, $Item.Value)
            }
            $InitRequest.Query = $HttpValueCollection.ToString()
        }
        $PushLoginResponse=Get-WebResponse -BaseUrl $PushLoginBaseUrl -SubUrl $PushLoginSubUrl -UserAgent $global:UserAgent
        $JsonPushLoginResponse=$PushLoginResponse|ConvertFrom-Json
        if($JsonPushLoginResponse.ret -eq 0 ){
            $uuid=$JsonPushLoginResponse.uuid
        }
        else {
            "throw exception not able to get uuid from push login"
        }
    }
}
else{
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
        "throw exception not able to get uuid from push login"
    }
    "uuid is {0}" -f $uuid
}

#2.downlaod QRcode by uuid for scan 
$BaseQrCodePicUri = "https://login.weixin.qq.com/qrcode/"
$QrCodePicUri = $BaseQrCodePicUri + $uuid
#$QrCodePicUri="https://login.weixin.qq.com/qrcode/AbtUISmjlQ=="
#check web is connected or not 
Invoke-WebRequest  -Uri $QrCodePicUri -OutFile Qrcode.jpeg 

<#Scan the Qrcode on Mobile.
if you dont scan windows.code will be 400,ask the user to scan immediately
the window.code = 201 after you press scan before press confirm.
at the meantime ,the web will load the user icon
after you confirm you will get redirect the url for login 
window.userAvatar = 'data:img/jpg;base64,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';
#>
$time = [int](get-date -UFormat %s)
$time1 = [int]( $time / 1579)*(-1)
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
        $RedirectUrl=$matches[1]
        $RedirectUrl=$RedirectUrl.Substring(1, $RedirectUrl.Length - 2)
        $RedirectResponse=Get-WebResponse -BaseUrl $RedirectUrl -UserAgent $global:UserAgent -AllowRedirect $False 
        #$RedirectResponse=Invoke-WebRequest -Uri $RedirectUrl -UserAgent $headers -SessionVariable ws -MaximumRedirection 0     
        # <error><ret>0</ret><message></message><skey>@crypt_c8003a0e_60a091e9354b02ab0744821fe31eca0a</skey><wxsid>ULQ+YXHhZWZowUPE</wxsid><wxuin>417851615</wxuin><pass_ticket>mv8lxL%2BvzTrL7uL7sjsPLytX9IqIogN..           
        $RedirectGetParameter=@{}
        $XMlRedirectResponse=[xml]$RedirectResponse.Content
        $ret =$XMlRedirectResponse.error.ret
            if ($ret -eq 0)
            {  
                #$XMLNodesName=4$XMlRedirectResponse.error|gm -MemberType property | select Name
                $XMLNodesElements=$XMlRedirectResponse.error.ChildNodes
                #.ChildNodes| % { $_.GetType().GetProperty("Name").GetValue($_, $null); }
                foreach ($node in  $XMLNodesElements)
                {
                    #$XMlRedirectResponse.error.
                    $name=$node.GetType().GetProperty("Name").GetValue($node)
                    $value=$node.'#text'
                   $RedirectGetParameter.add($name,$value)

                }
                $global:WxCore|Add-Member -NotePropertyName 'skey'-NotePropertyValue ($RedirectGetParameter.skey)
                $global:WxCore|Add-Member -NotePropertyName 'pass_ticket'-NotePropertyValue ($RedirectGetParameter.pass_ticket)
                $global:WxCore|Add-Member -NotePropertyName 'sid'-NotePropertyValue ($RedirectGetParameter.wxsid)
                $global:WxCore|Add-Member -NotePropertyName 'uin'-NotePropertyValue ($RedirectGetParameter.wxuin)
                $global:WxCore|Add-Member -NotePropertyName 'logontime'-NotePropertyValue (([int]((get-date -UFormat %s))*1e3))
                $InitSubUrl='/webwxinit'
                $UserAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' 
                $regx=[regex]::new('https?://')
                $InitBaseUrlPrefix=$regx.Matches($RedirectUrl).groups[0].Value
                $InitBaseUrlWithoutPrefix=($RedirectUrl.Substring($InitBaseUrlPrefix.Length,$RedirectUrl.Length-$InitBaseUrlPrefix.Length))
                $WxAPIBaseUrl=$InitBaseUrlPrefix+$InitBaseUrlWithoutPrefix.Substring(0,$InitBaseUrlWithoutPrefix.IndexOf('/'))+'/cgi-bin/mmwebwx-bin'
                $global:WxCore|Add-Member -NotePropertyName 'WxAPIBaseUrl' -NotePropertyValue  $WxAPIBaseUrl
                
                $InitBaseUrl= $InitBaseUrlPrefix+$InitBaseUrlWithoutPrefix.Substring(0,$InitBaseUrlWithoutPrefix.IndexOf('/'))+'/cgi-bin/mmwebwx-bin'
                $InitGetParameter=[ordered]@{
                'r'=[int]((get-date -UFormat %s)/1579*(-1))
                'lang'='en_'
                'pass_ticket'=$RedirectGetParameter.pass_ticket
                }
                $InitFullUrl = $InitBaseurl+$InitSubUrl
                $InitRequest = [System.UriBuilder]($InitFullUrl)
                $HttpValueCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                if ($InitGetParameter -ne $null)
                {
                    foreach ($item in $InitGetParameter.GetEnumerator()) {
                        $HttpValueCollection.Add($Item.Key, $Item.Value)
                    }
                    $InitRequest.Query = $HttpValueCollection.ToString()
                }
                $Deviceid='e'+(get-random -Maximum 1.0).tostring().substring(2,15)
                $global:WxCore|Add-Member -NotePropertyName 'DeviceID' -NotePropertyValue $Deviceid
                $InitPostParameter=[pscustomobject][ordered]@{
                    Uin=$RedirectGetParameter.Item('wxuin')
                    Sid=$RedirectGetParameter.Item('wxsid')
                    Skey=$RedirectGetParameter.Item('skey')
                    DeviceID=$Deviceid
                }
                
                $InitPostPayload=@{
                    BaseRequest=$InitPostParameter
                }
                $JasonInitPostPayload=ConvertTo-Json $InitPostPayload -Compress
                $global:WxCore|Add-Member -NotePropertyName 'BaseRequest' -NotePropertyValue $InitPostParameter
                #$InitResponse=invoke-webrequest -uri  $Request.Uri -Method Post -ContentType 'application/json;charset=UTF-8' -Body  $JasonInitPostPayload  -TimeoutSec 10  -UserAgent $UserAgent -TransferEncoding 'gzip'  -Verbose
                #outfile  will not have messy code  by invoke-webrequest 
                #invoke-webrequest -uri  $Request.Uri -Method Post -ContentType 'application/json;charset=UTF-8' -Body  $JasonInitPostPayload  -TimeoutSec 10  -UserAgent $UserAgent  -OutFile .\initResponse.txt -Verbose
                #fix the bug of ps decode issue for utf8 (it will auto use iso)

                $InitPostPayloadUTF8Encoding=[system.Text.Encoding]::UTF8.GetString((Get-WebResponse -BaseUrl $InitRequest.Uri.ToString() -Method 'post' -ContentType 'application/json;charset=UTF-8' -Body  $JasonInitPostPayload -UserAgent $global:UserAgent).RawContentStream.ToArray())
                #$InitPostPayloadUTF8Encoding=[system.Text.Encoding]::UTF8.GetString((invoke-webrequest -uri  $InitRequest.Uri -Method Post -ContentType 'application/json;charset=UTF-8' -Body  $JasonInitPostPayload  -TimeoutSec 10  -UserAgent $UserAgent).RawContentStream.ToArray())
                $CustomerInitPostPayloadUTF8Encoding=$InitPostPayloadUTF8Encoding|ConvertFrom-Json 
                if ($CustomerInitPostPayloadUTF8Encoding.BaseResponse.Ret -eq 0)
                {
                #need to filter the emojo in respponse
                $WechatAccountNickName=$CustomerInitPostPayloadUTF8Encoding.User.NickName
                #$InviteStartCount=$CustomerInitPostPayloadUTF8Encoding.InviteStartCount
                $WechatAccountUserName=$CustomerInitPostPayloadUTF8Encoding.User.UserName
                $global:WxCore|add-member  -NotePropertyName 'UserName'-NotePropertyValue $WechatAccountUserName
                $global:WxCore|add-member  -NotePropertyName 'NickName' -NotePropertyValue $WechatAccountNickName
                $SyncKeyList=$CustomerInitPostPayloadUTF8Encoding.SyncKey.list
                $int=0
                $SyncKey=""
                foreach($s in $SyncKeyList){
                    if($int -eq 0)
                    {
                        $SyncKey+="$($s.key)"+"_"+"$($s.val)"
                    }
                    else {
                        $SyncKey+="|"+"$($s.key)"+"_"+"$($s.val)"
                    }
                $int++
                }
                $global:WxCore|Add-Member -NotePropertyName 'synckey' -NotePropertyValue $SyncKey
                $global:WxCore|Add-Member -NotePropertyName 'alive' -NotePropertyValue $True
                $global:WxCore|Add-Member -NotePropertyName 'synckeyList' -NotePropertyValue($CustomerInitPostPayloadUTF8Encoding.SyncKey)

                $Contract=$CustomerInitPostPayloadUTF8Encoding.ContactList
                $global:WeChatContract=@()
                foreach ($c in $Contract)
                    {
                        if($c.UserName -match "@@+")
                        {
                            $c|Add-Member -NotePropertyName "WxContractType" -NotePropertyValue "GroupChat"
                        }
                        elseif ($c.UserName -match "@+") {
                            $c|Add-Member -NotePropertyName "WxContractType" -NotePropertyValue "Friend"
                        }
                        else {
                            $c|Add-Member -NotePropertyName "WxContractType" -NotePropertyValue "WechatInternal"
                        }
                        $global:WeChatContract+=$c
                    }              
                $global:WeChatContract|ft username,nickname,WxContractType 

                }
                elseif($CustomerInitPostPayloadUTF8Encoding.BaseResponse.Ret -eq 1101)
                {

                    "Login Expried ,restart the process"
                }
                else {
                    "Other Reason for failing in wxinit,restart the process"
                }

                $WebwxStatusNotifySubUrl='/webwxstatusnotify'
                $UserAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' 
                $regx=[regex]::new('https?://')
                $WebwxStatusNotifyBaseUrlPrefix=$regx.Matches($RedirectUrl).groups[0].Value
                $WebwxStatusNotifyBaseUrlWithoutPrefix=($RedirectUrl.Substring($WebwxStatusNotifyBaseUrlPrefix.Length,$RedirectUrl.Length-$WebwxStatusNotifyBaseUrlPrefix.Length))
                $WebwxStatusNotifyBaseUrl= $WebwxStatusNotifyBaseUrlPrefix+$WebwxStatusNotifyBaseUrlWithoutPrefix.Substring(0,$WebwxStatusNotifyBaseUrlWithoutPrefix.IndexOf('/'))+'/cgi-bin/mmwebwx-bin'
                $JasonRequestHead=@{
                        ContentType='application/json; charset=UTF-8'
                }

                $WebwxStatusNotifyGetParameter=[ordered]@{
                'lang'='en_'
                'pass_ticket'=$RedirectGetParameter.pass_ticket}
                $WebwxStatusNotifyFullUrl = $WebwxStatusNotifyBaseUrl+$WebwxStatusNotifySubUrl
                $WebwxStatusNotifyRequest = [System.UriBuilder]($WebwxStatusNotifyFullUrl)
                $HttpValueCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                if ($WebwxStatusNotifyGetParameter -ne $null)
                {
                    foreach ($item in $WebwxStatusNotifyGetParameter.GetEnumerator()) {
                        $HttpValueCollection.Add($Item.Key, $Item.Value)
                    }
                    $WebwxStatusNotifyRequest.Query = $HttpValueCollection.ToString()
                }

                $WebwxStatusNotifyPostParameter=$InitPostParameter
                $WebwxStatusNotifyPostParameter.Uin=[int]$InitPostParameter.Uin
                $WebwxStatusNotifyPostPayload=[pscustomobject][ordered]@{
                    BaseRequest=$WebwxStatusNotifyPostParameter
                    #InitPostPayload
                    Code=3
                    FromUserName=$WechatAccountUserName
                    ToUserName=$WechatAccountUserName
                    ClientMsgId=[int](get-date -UFormat %s)                 
                }
                $JasonWebwxStatusNotifyPostPayload=ConvertTo-Json $WebwxStatusNotifyPostPayload -Compress 
                #invoke-webrequest -uri  $Request.Uri -Method Post -ContentType 'application/json;charset=UTF-8' -Body  $JasonWebwxStatusNotifyPostPayload -TimeoutSec 10  -UserAgent $UserAgent -OutFile initResponse.txt -Verbose
                #$WebwxStatusNotifyResponse=invoke-webrequest -uri  $Request.Uri -Method Post -ContentType 'application/json;charset=UTF-8' -Body  $JasonWebwxStatusNotifyPostPayload -TimeoutSec 10  -UserAgent $UserAgent -TransferEncoding 'gzip'-Verbose
                $WebwxStatusNotifyResponse=Get-WebResponse -BaseUrl $WebwxStatusNotifyRequest.uri.tostring() -Method 'post' -ContentType 'application/json;charset=UTF-8' -Body  $JasonWebwxStatusNotifyPostPayload -UserAgent $global:UserAgent -AllowRedirect $True
                $CustomerWebwxStatusNotifyResponse=$WebwxStatusNotifyResponse.Content|ConvertFrom-Json 
                if($CustomerWebwxStatusNotifyResponse.BaseResponse.Ret -eq 0){                   
                    $WechatMsgID=$CustomerWebwxStatusNotifyResponse.MsgID      
                    #get the Wechat Friends list             
             
                    $global:WxCore|Add-Member -NotePropertyName 'WxContractCount'-NotePropertyValue 0
                    do {
                        #first Seq = 0
                        if($seq -eq $null){$seq=0}
                        $JsonWebwxGetContactResponseUTF8Encoding=Get-WxContract -seq $seq
                        $seq=$JsonWebwxGetContactResponseUTF8Encoding.Seq
                        write-host -ForegroundColor Cyan "seq is $seq, count is $($JsonWebwxGetContactResponseUTF8Encoding.MemberCount)"
                        $global:WxCore.WxContractCount+=$JsonWebwxGetContactResponseUTF8Encoding.MemberCount
                        $global:WxContracts+=$JsonWebwxGetContactResponseUTF8Encoding.MemberList
                    }
                    while ($seq -ne 0)
   
                    <# send message test successed on  6/10 
                    $WebWxSendMsgSubUrl='/webwxsendmsg'
                    #$SyncCheckFullUrl = $global:WxCore.WxAPIBaseUrl+$SyncCheckSubUrl
                    #$SyncCheckRequest = [System.UriBuilder]($SyncCheckFullUrl)

                    $WebWxSendMsgPostParameter=[ordered]@{
                        'pass_ticket'=$global:WxCore.pass_ticket
                    }
                    
                    $msgType=1
                    $content='Hello Wechat By Powershell Script'
                    #need to search from contract list
                    $ToUserName='filehelper'
                    $Msg=[ordered]@{
                        #type 1 means text message
                        'Type'=$msgType
                        'Content'=$content
                        'FromUserName'=$global:WxCore.UserName
                        'ToUserName'=$ToUserName
                        'LocalID'= [int]((get-date -UFormat %s))*1e4
                        'ClientMsgId'=[int]((get-date -UFormat %s))*1e4
                        }
                    $WebWxSendMsgPostPayload=[ordered]@{
                        'BaseRequest'=$global:WxCore.BaseRequest
                        'Msg'=$Msg
                        'Scene'=0
                    }
                    $JsonWebWxSendMsgPostPayload=ConvertTo-Json $WebWxSendMsgPostPayload -Compress
                    $JsonWebWxSendResponse=Get-WebResponse -BaseUrl $global:WxCore.WxAPIBaseUrl -SubUrl  $WebWxSendMsgSubUrl -Getparameter $WebWxSendMsgPostParameter -Method 'post' -ContentType 'application/json;charset=UTF-8' -Body  $JsonWebWxSendMsgPostPayload -UserAgent $global:UserAgent
                    #>
                   
                    # receive message process, remove to test send message function.
                    $SyncCheckSubUrl='/synccheck'
                    $SyncCheckGetParameter=[ordered]@{
                        'r'=[int]((get-date -UFormat %s)/1579*(-1))
                        'skey'=$global:WxCore.skey
                        'sid'=$global:WxCore.sid
                        'uin'=$global:WxCore.uin
                        'deviceid'=$global:WxCore.deviceid
                        'synckey'=$global:WxCore.synckey
                        '_'=$global:WxCore.logontime
                    }
                    $global:WxCore.logontime+=1
                    
                    while ($global:WxCore.alive -eq $True)
                    {
                        $SyncCheckResponse=Get-WebResponse -BaseUrl $global:WxCore.WxAPIBaseUrl -SubUrl  $SyncCheckSubUrl -GetParameter  $SyncCheckGetParameter -UserAgent $global:UserAgent -AllowRedirect $True #-Timeout 60
                        #need to figure out how to know the synccheck has correct response
                        if ($SyncCheckResponse -ne $null)
                        {
                            $regex=[regex]::new('window.synccheck={retcode:"\d+",selector:"\d+"}')
                            $matches=$regex.Matches($SyncCheckResponse.Content)
                                if ($matches -ne $null)
                                {
                                    $JsonSyncCheckResponse=[ordered]@{
                                        WindowsSyncCheck=$SyncCheckResponse.Content.Split("=")[1]|ConvertFrom-Json
                                    }
                                    $retcode=$JsonSyncCheckResponse.item('WindowsSyncCheck').retcode
                                    $selector=$JsonSyncCheckResponse.item('WindowsSyncCheck').selector
                                    if($selector -eq 0){
                                        #keep loading...
                                    }
                                    else {
                                        #get new message to produce
                                        $WebSyncSubUrl='/webwxsync'
                                        $WebSyncGetParameter=[ordered]@{    
                                            'sid'=$global:WxCore.sid
                                            'skey'=$global:WxCore.skey
                                            'lang'='en_'
                                            'pass_ticket'=$global:WxCore.pass_ticket
                                        }
                                        $WebSyncPostPayload=[ordered]@{    
                                            'baserequest'=$global:WxCore.BaseRequest
                                            'synckey'=$global:WxCore.synckeyList
                                            'rr'=[int]((get-date -UFormat %s))*(-1)
                                        }
                                        $JsonWebSyncPostPayload=ConvertTo-Json $WebSyncPostPayload -Compress -Depth 3
                                        "WebSyncResponse"
                                        $WebSyncResponse=Get-WebResponse -BaseUrl $global:WxCore.WxAPIBaseUrl -Method 'post' -SubUrl  $WebSyncSubUrl -GetParameter  $WebSyncGetParameter -Body $JsonWebSyncPostPayload -UserAgent $global:UserAgent -AllowRedirect $True #-Timeout 60
                                        $WebSyncResponseUTF8Encoding=[system.Text.Encoding]::UTF8.GetString($WebSyncResponse.RawContentStream.ToArray())
                                        $JsonWebSyncResponseUTF8Encoding=$WebSyncResponseUTF8Encoding|ConvertFrom-Json
                                        $SyncCheckkey=$JsonWebSyncResponseUTF8Encoding.SyncCheckKey
                                        #keep working on testing on 6/11 SyncKey is null.
                                        break

                                    }
    
                                }
                                else {
                                    "throw unkonw response for SyncCheck"
                                    $global:WxCore.alive=$false
                                }
                        }
                        else 
                        {            
                            "throw exception not able to get SyncCheckResponse"
                            $global:WxCore.alive=$false
                        }      
                    }
                    
                }
                elseif($CustomerWebwxStatusNotifyResponse.BaseResponse.Ret -eq 1101){
                    "Login Expried ,restart the process"
                }
                else{
                    "Other Reason for failing in WebwxStatusNotify,restart the process"
                }
                #baseresponse for webwxstatus ,ret is 1 not 0  need to fix on 6/5--show mobile login
            }
            else {
                # ret is not 0  need to rerun the scrpit
                #failed to login need to restart the login process by ret code
            }


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
        write-host   "unkonw reason,the windows code is $($CheckLoginResponse.content)"
        }

        Start-Sleep 3
    }
}

<#
https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxbatchgetcontact?type=ex&r=1560144140316


#>