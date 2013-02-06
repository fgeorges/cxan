<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:http="http://expath.org/ns/http-client"
                xmlns:crypto="http://expath.org/ns/crypto"
                xmlns:twit="http://cxan.org/ns/website/twitter"
                version="2.0">

   <xsl:import href="http://expath.org/ns/http-client.xsl"/>
   <xsl:import href="http://expath.org/ns/crypto.xsl"/>

   <!-- the status to tweet -->
   <xsl:param name="status"          as="xs:string"/>
   <!-- the config param (the user token & secret, and the consumer key & secret) -->
   <xsl:param name="user-token"      as="xs:string"/>
   <xsl:param name="user-secret"     as="xs:string"/>
   <xsl:param name="consumer-key"    as="xs:string"/>
   <xsl:param name="consumer-secret" as="xs:string"/>

   <!--
       https://dev.twitter.com/docs/api/1/post/statuses/update
       https://dev.twitter.com/docs/auth/authorizing-request
       https://dev.twitter.com/docs/auth/creating-signature
   -->

   <xsl:variable name="uri"        select="'https://api.twitter.com/1/statuses/update'"/>
   <xsl:variable name="method"     select="'POST'"/>
   <xsl:variable name="trim-user"  select="'true'"/>
   <xsl:variable name="nonce"      select="twit:nonce()"/>
   <xsl:variable name="sig-method" select="'HMAC-SHA1'"/>
   <xsl:variable name="timestamp"  select="twit:current-timestamp()"/>
   <xsl:variable name="version"    select="'1.0'"/>

   <xsl:template name="twit:tweet">
      <xsl:variable name="auth-str" select="twit:encode-oauth()"/>
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="{ $method }" href="{ $uri }">
            <http:header name="User-Agent"    value="EXPath HTTP Client"/>
            <http:header name="Accept"        value="application/xml"/>
            <http:header name="Authorization" value="{ $auth-str }"/>
            <http:body media-type="application/x-www-form-urlencoded">
               <xsl:variable name="params" as="element()">
                  <params>
                     <param name="status"    value="{ $status }"/>
                     <param name="trim_user" value="{ $trim-user }"/>
                  </params>
               </xsl:variable>
               <xsl:value-of select="twit:format-params($params, '&amp;')"/>
            </http:body>
         </http:request>
      </xsl:variable>
      <xsl:variable name="resp" select="http:send-request($request)"/>
      <xsl:choose>
         <xsl:when test="$resp[1]/@status/xs:integer(.) eq 200">
            <success>
               <xsl:text>Tweet succesfully created at </xsl:text>
               <xsl:value-of select="$resp[2]/status/created_at"/>
               <xsl:text> (</xsl:text>
               <xsl:value-of select="$status"/>
               <xsl:text>).</xsl:text>
            </success>
         </xsl:when>
         <xsl:otherwise>
            <error>
               <xsl:text>Error tweeting "</xsl:text>
               <xsl:value-of select="$status"/>
               <xsl:text>": HTTP status is </xsl:text>
               <xsl:value-of select="$resp[1]/@status"/>
               <xsl:text>, HTTP message is </xsl:text>
               <xsl:value-of select="$resp[1]/@message"/>
               <xsl:text>, and error is "</xsl:text>
               <xsl:value-of select="$resp[2]/*/error"/>
               <xsl:text>".</xsl:text>
            </error>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:function name="twit:format-params" as="xs:string">
      <xsl:param name="params"    as="element(params)"/>
      <xsl:param name="separator" as="xs:string"/>
      <xsl:sequence select="
          string-join(
            $params/*/concat(encode-for-uri(@name), '=', encode-for-uri(@value)),
            $separator)"/>
   </xsl:function>

   <xsl:function name="twit:encode-oauth" as="xs:string">
      <xsl:variable name="auth" as="element()">
         <params>
            <param name="oauth_consumer_key"     value='"{ $consumer-key }"'/>
            <param name="oauth_nonce"            value='"{ $nonce }"'/>
            <param name="oauth_signature"        value='"{ twit:signature() }"'/>
            <param name="oauth_signature_method" value='"{ $sig-method }"'/>
            <param name="oauth_timestamp"        value='"{ $timestamp }"'/>
            <param name="oauth_token"            value='"{ $user-token }"'/>
            <param name="oauth_version"          value='"{ $version }"'/>
         </params>
      </xsl:variable>
      <xsl:sequence select="concat('OAuth ', twit:format-params($auth, ', '))"/>
   </xsl:function>

   <!-- TODO: To be improved, but good enough for a start... -->
   <xsl:function name="twit:nonce" as="xs:string">
      <xsl:variable name="now"  select="current-dateTime()"/>
      <xsl:variable name="secs" select="seconds-from-dateTime($now)"/>
      <xsl:sequence select="concat($timestamp, translate(string($secs), '.', ''))"/>
   </xsl:function>

   <xsl:function name="twit:signature" as="xs:string">
      <xsl:variable name="params" as="element()">
         <params>
            <param name="oauth_consumer_key"     value="{ $consumer-key }"/>
            <param name="oauth_nonce"            value="{ $nonce }"/>
            <param name="oauth_signature_method" value="{ $sig-method }"/>
            <param name="oauth_timestamp"        value="{ $timestamp }"/>
            <param name="oauth_token"            value="{ $user-token }"/>
            <param name="oauth_version"          value="{ $version }"/>
            <param name="status"                 value="{ $status }"/>
            <param name="trim_user"              value="{ $trim-user }"/>
         </params>
      </xsl:variable>
      <xsl:variable name="param-string" select="twit:format-params($params, '&amp;')"/>
      <xsl:variable name="base-string"  select="
          string-join(
            ( upper-case($method), encode-for-uri($uri), encode-for-uri($param-string) ),
            '&amp;')"/>
      <xsl:variable name="signing-key" select="
          string-join(
            ( encode-for-uri($consumer-secret), encode-for-uri($user-secret) ),
            '&amp;')"/>
      <xsl:sequence select="xs:string(crypto:hmac-sha1($base-string, $signing-key))"/>
   </xsl:function>

   <xsl:function name="twit:current-timestamp" as="xs:string">
      <!-- the UNIX epoch -->
      <xsl:variable name="epoch" select="xs:dateTime('1970-01-01T00:00:00Z')"/>
      <!-- now -->
      <xsl:variable name="now"   select="current-dateTime()"/>
      <!-- time since then -->
      <xsl:variable name="diff"  select="$now - $epoch"/>
      <!-- all components, in seconds... -->
      <xsl:variable name="days"  select="days-from-duration($diff) * (24*60*60)"/>
      <xsl:variable name="hours" select="hours-from-duration($diff) * (60*60)"/>
      <xsl:variable name="mins"  select="minutes-from-duration($diff) * 60"/>
      <xsl:variable name="secs"  select="floor(seconds-from-duration($diff))"/>
      <!-- sum each of them -->
      <xsl:sequence select="xs:string($days + $hours + $mins + $secs)"/>
   </xsl:function>

</xsl:stylesheet>
