# Description:
#  Provides information about earthlings. 
#
# Commands:
#   :DDC: hubot Earthling Lookup: whois <ddcid> - Replace <ddcid> with an actual ddc user id or person's name
#
# Notes:
#   Hat tip to Steve Seremeth for LDAP info

ldap = require 'ldapjs'
fairmont = require 'fairmont'
util = require 'util'
Promise = require 'promise'
AWS = require 'aws-sdk'

delay = (time, fn, args...) ->
  setTimeout fn, time, args...

delayedPromise = (time) ->
  new Promise (fulfill) ->
    delay time, () ->
      console.log "I'm tired of waiting!"
      fulfill "timer"

ldap_settings =
  url: 'ldap://dc3.dealerdotcom.corp'
bindDn = 'OU=Earthlings,OU=People,DC=dealerdotcom,DC=corp'
thumbBase = if process.env.HUBOT_LOCAL_MODE then 'http://apps.local.dealer.ddc/thumb' else 'http://answers.dealer.ddc/thumb'
# s3Base    = 'http://dealerbot-thumbnails.s3-website-us-east-1.amazonaws.com'
s3Base = "https://#{process.env.HUBOT_AWS_S3_BUCKET ? "dealerbot-thumbnails"}.s3.amazonaws.com" # https://s3.amazonaws.com/dealerbot-thumbnails'
pendingPromises = []
ldap_image_str = null
hipchat_image_str = null
gravatar_image_str = null

AWS.config =
  apiVersions:
    s3: '2006-03-01'
  accessKeyId: process.env.AWS_ACCESS_KEY_ID
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  logger: process.stdout
  region: process.env.HUBOT_AWS_S3_REGION ? "us-east-1"


s3 = new AWS.S3

console.log "S3 : " + util.inspect(s3) + "\n"

module.exports = (robot) ->
  robot.respond /listBuckets/i, (msg) ->
    console.log "list all buckets"
    s3.listBuckets (err, data) ->
      if err
        console.log "error: " + util.inspect(err) + "\n"
      else
        console.log "listBuckets returned: " + util.inspect(data) + "\n"

  robot.respond /hash(.*)$/i, (msg) ->
    if msg.match[1]
      email = msg.match[1]
      email_hash = fairmont.md5(email.trim().toLowerCase())
      msg.send email_hash
    else
      msg.send "no argument provided.  (eg. hash email@address.com)"

  robot.respond /bucket(.*) listObjects$/i, (msg) ->
    bucket = if msg.match[1] then msg.match[1] else if  process.env.HUBOT_AWS_S3_BUCKET then process.env.HUBOT_AWS_S3_BUCKET else "dealerbot-thumbnails"
    bucket = bucket.trim()
    console.log "listing contents of bucket named '#{bucket}'"
    s3.listObjects { Bucket: bucket }, (err, data) ->
      if err
        console.log "error: " + util.inspect(err) + "\n"
      else
        console.log "returned: " + util.inspect(data) + "\n"

  robot.respond /bucket(.*) headObject(.*)$/i, (msg) ->
    bucket = if msg.match[1] then msg.match[1] else if  process.env.HUBOT_AWS_S3_BUCKET then process.env.HUBOT_AWS_S3_BUCKET else "dealerbot-thumbnails"
    bucket = bucket.trim()
    key = if msg.match[2] then msg.match[2] else "75a5159a523b9e553a70cdae8c449a46.jpg"
    key = key.trim()
    console.log "Checking in bucket '#{bucket}' for the META data for key '#{key}'"
    s3.headObject { Bucket: bucket, Key: key }, (err, data) ->
      if err
        console.log "error: " + util.inspect(err) + "\n"
      else
        console.log "returned: " + util.inspect(data) + "\n"

  robot.respond /bucket(.*) getObject(.*)$/i, (msg) ->
    bucket = if msg.match[1] then msg.match[1] else if  process.env.HUBOT_AWS_S3_BUCKET then process.env.HUBOT_AWS_S3_BUCKET else "dealerbot-thumbnails"
    bucket = bucket.trim()
    key = if msg.match[2] then msg.match[2] else "75a5159a523b9e553a70cdae8c449a46.jpg"
    key = key.trim()
    console.log "Checking in bucket '#{bucket}' for the key '#{key}'"
    s3.getObject { Bucket: bucket, Key: key }, (err, data) ->
      if err
        console.log "error: " + util.inspect(err) + "\n"
      else
        console.log "returned: " + util.inspect(data) + "\n"

  robot.respond /headBucket(.*)$/i, (msg) ->
    bucket = if msg.match[1] then msg.match[1] else if  process.env.HUBOT_AWS_S3_BUCKET then process.env.HUBOT_AWS_S3_BUCKET else "dealerbot-thumbnails"
    bucket = bucket.trim()
    console.log "checking for bucket named '#{bucket}'"
    s3.headBucket { Bucket: bucket }, (err, data) ->
      if err
        console.log "error: " + util.inspect(err) + "\n"
      else
        console.log "returned: " + util.inspect(data) + "\n"

  robot.respond /getBucketAcl(.*)$/i, (msg) ->
    bucket = if msg.match[1] then msg.match[1] else if  process.env.HUBOT_AWS_S3_BUCKET then process.env.HUBOT_AWS_S3_BUCKET else "dealerbot-thumbnails"
    bucket = bucket.trim()
    console.log "checking for bucket named '#{bucket}'"
    s3.getBucketAcl { Bucket: bucket }, (err, data) ->
      if err
        console.log "error: " + util.inspect(err) + "\n"
      else
        console.log "returned: " + util.inspect(data) + "\n"

  robot.respond /getBucketLocation(.*)$/i, (msg) ->
    bucket = if msg.match[1] then msg.match[1] else if  process.env.HUBOT_AWS_S3_BUCKET then process.env.HUBOT_AWS_S3_BUCKET else "dealerbot-thumbnails"
    bucket = bucket.trim()
    console.log "checking for bucket named '#{bucket}'"
    s3.getBucketLocation { Bucket: bucket }, (err, data) ->
      if err
        console.log "error: " + util.inspect(err) + "\n"
      else
        console.log "returned: " + util.inspect(data) + "\n"

  robot.respond /((who\'s|(who is)) your (daddy|creator))(.*)?$/i, (msg) ->
    msg.send "I was created by Jonah Schulte, Jamie Addessi and Chris Yager during a Hack-a-Thon in September 2013."

  robot.router.get '/thumb/:id.jpg', (req, res) ->
    # console.log "new web request for #{req.params.id}"
    thumb_data = robot.brain.get "thumb-#{req.params.id}"

    if thumb_data
      res.set('keep-alive', 'close')
      res.set('Content-Type', 'image/jpeg')
      res.send(new Buffer(thumb_data))
    else
      res.send(404)

  robot.respond /(whois|who is|who\'s|where's|where is|where does) (.*)$/i, (msg) ->
    userID = msg.match[2].replace('?', '').replace(' sit', '')

    if userID == 'your daddy' || userID == 'your creator'
      return

    emailCheck = userID.match '^.* <(.*@.*)>$'
    if emailCheck
      console.log "Sub Match: #{emailCheck[1]}"
      userID = emailCheck[1]

    client = ldap.createClient ldap_settings
    resp_str = ''

    console.log("Searching LDAP for #{userID}")

    client.bind bindDn, '', (err) ->
      # console.log 'Successful LDAP authentication for test'
      client.unbind

    if userID.match /ddc/
      chosenFilter = '(&(sAMAccountName=' + userID + ')(objectClass=user))'
    else if userID.match /@/
      chosenFilter = '(&(mail=*' + userID + '*)(objectClass=user))'
    else
      chosenFilter = '(&(name=*' + userID + '*)(objectClass=user))'

    searchOpts =
      filter: chosenFilter
      scope: 'sub'
      attributes: ['cn', 'title', 'department', 'mail', 'telephoneNumber', 'mobile', 'st', 'physicalDeliveryOfficeName', 'manager', 'directReports', 'sAMAccountName', 'thumbnailPhoto']

    resp_str = ''
    ldap_image_str = null
    hipchat_image_str = null
    gravatar_image_str = null

    client.search 'OU=Earthlings,OU=People,DC=dealerdotcom,DC=corp', searchOpts, (err, res) ->
      res.on 'searchEntry', (entry) ->
        resp_str += '\n'

        isDealerTrack = false
        department = ''
        email = ''
        state = null
        address = null

        for attrOrder in searchOpts.attributes

          # console.log("attrOrder: \"#{attrOrder}\"\n")

          for attr in entry.attributes

            if attr.type == 'cn' and attrOrder == 'cn'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              resp_str += 'Name: ' + attr.vals.join(',\n ') + '\n'

            else if attr.type == 'title' and attrOrder == 'title'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              resp_str += 'Title: ' + attr.vals.join(',\n ') + '\n'

            else if attr.type == 'department' and attrOrder == 'department'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              department = attr.vals.join(',\n ')
              if department == 'Dealertrack'
                isDealerTrack = true
                department = 'DealerTrack'

              resp_str += 'Department: ' + department + '\n'

            else if attr.type == 'mail' and attrOrder == 'mail'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              email = attr.vals.join(',\n ')

              if isDealerTrack
                email = email.replace /dealer\.com/, "dealertrack.com"

              resp_str += 'Email: ' + email + '\n'
              email_hash = fairmont.md5(email.trim().toLowerCase())

              gravatar_image_str = "http://www.gravatar.com/avatar/#{email_hash}.jpg?d=identicon"
              console.log "  GRAVATAR THUMBNAIL :: #{gravatar_image_str}"

              httprequest = msg.http("https://api.hipchat.com/v2/user/#{email}?auth_token=" + process.env.HUBOT_HIPCHAT_TOKEN)
              hipchat_promise = new Promise (resolve, reject) ->
                httprequest.get() (err, res, body) ->
                  if err
                    console.log "error: #{robot.adapter.errmsg(err)}"
                    reject robot.adapter.errmsg(err)
                  else
                    console.log "data: #{body}"
                    userInfo = JSON.parse(body)
                    if userInfo.photo_url and userInfo.photo_url isnt "https://www.hipchat.com/img/silhouette_125.png"
                      hipchat_image_str = userInfo.photo_url
                      console.log "  FOUND HIPCHAT THUMBNAIL:: #{hipchat_image_str}"
                    resolve "hipchat"
              pendingPromises.push hipchat_promise

            else if attr.type == 'thumbnailPhoto' and attrOrder == 'thumbnailPhoto'
              console.log "attr: thumbnailPhoto\n"
              console.log "hash: #{email_hash}"
              if process.env.HUBOT_INCLUDE_LDAP_IMAGE isnt "false"
                if process.env.HUBOT_LOCAL_THUMBNAILS isnt "false"
                  robot.brain.set "thumb-#{email_hash}", attr.buffers[0]
                  ldap_image_str = thumbBase + "/#{email_hash}.jpg"
                  console.log "  ROBOT LDAP :: #{ldap_image_str}"
                else
                  console.log "Looking for LDAP thumbnail"
                  ldap_promise = new Promise (resolve1) ->
                    check_params =
                      Bucket: process.env.HUBOT_AWS_S3_BUCKET ? "dealerbot-thumbnails"
                      Key: "#{email_hash}.jpg"
                    s3.headObject check_params, (headCheckError, headCheckResult) ->
                      if headCheckError
                        console.log "Unable to find #{email_hash}.jpg"
                        resolve1 null
                      else
                        console.log 'HeadCheck returned, ' + util.inspect(headCheckResult) + "\n"
                        console.log "Found #{email_hash}.jpg"
                        ldap_image_str = s3Base + "/#{email_hash}.jpg"
                        console.log "  EXISTING S3 LDAP :: #{ldap_image_str}"
                        resolve1 'found ldap'

                  .then (s3GetResolution) ->
                    new Promise (resolve2, reject2) ->
                      if s3GetResolution isnt null
                        console.log "Using found thumbnail"
                        resolve2 'found ldap'
                      else
                        console.log "Saving new thumbnail to S3"
                        buffer = new Buffer attr.buffers[0]
                        upload_params =
                          ACL: 'public-read'
                          ContentEncoding: 'image/jpeg'
                          Bucket: process.env.HUBOT_AWS_S3_BUCKET ? "dealerbot-thumbnails"
                          Key: "#{email_hash}.jpg"
                          Body: buffer
                        s3.upload upload_params, (uploadError, uploadResult) ->
                          if uploadError
                            console.log 'Failed to upload thumbnail to Amazon S3, ' + util.inspect(uploadError) + "\n"
                            reject2 'ldap upload failed'
                          else
                            console.log 'Uploaded thumbnail to Amazon S3, ' + util.inspect(uploadResult) + "\n"
                            ldap_image_str = uploadResult.Location
                            console.log "  UPLOADED S3 LDAP :: #{ldap_image_str}"
                            resolve2 'new ldap'
                  pendingPromises.push ldap_promise

            else if attr.type == 'telephoneNumber' and attrOrder == 'telephoneNumber'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              resp_str += 'Ext: ' + attr.vals.join(',\n ') + '\n'

            else if attr.type == 'mobile' and attrOrder == 'mobile'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              resp_str += 'Mobile: ' + attr.vals.join(',\n ') + '\n'

            else if attr.type == 'st' and attrOrder == 'st'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              state = 'State: ' + attr.vals.join(',\n ') + '\n'

            else if attr.type == 'physicalDeliveryOfficeName' and attrOrder == 'physicalDeliveryOfficeName'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              [ state, city, address ] = attr.vals.join(',\n ').split(" > ")
              address = "Location: #{address}, #{city}  #{state}\n"

              resp_str += address or state

            else if attr.type == 'manager' and attrOrder == 'manager'
              console.log "attr: " + JSON.stringify(attr) + "\n"
              resp_str += 'Manager: ' + attr.vals.join(',\n ').replace('CN=', '').replace(',OU=Earthlings,OU=People,DC=dealerdotcom,DC=corp', '') + '\n'

            else if attr.type == 'directReports' and attrOrder == 'directReports'
              console.log "attr: " + JSON.stringify(attr) + "\n"

            else if attr.type == 'sAMAccountName' and attrOrder == 'sAMAccountName' and isDealerTrack == false
              console.log "attr: " + JSON.stringify(attr) + "\n"
              resp_str += 'Map: http://maps.dealer.ddc/maps/locate/' + attr.vals.join(',\n ') + '\n'


      res.on 'end', (result) ->
        if resp_str == ''
          msg.send "No employees were found based on your search, \"#{userID}\""
        else
          msg.send resp_str
          console.log "There should be a thumbnail."
          console.log "  LDAP :: #{ldap_image_str}"
          console.log "  HIPCHAT :: #{hipchat_image_str}"
          console.log "  GRAVATAR :: #{gravatar_image_str}"
          console.log "#{pendingPromises.length} pending promises"
          # pendingPromises.push delayedPromise(5000)

          Promise.all(pendingPromises).done () ->
            console.log "All pending promises satisfied"
            if process.env.HUBOT_IMAGE_PRIORITY is "hipchat"
              msg.send hipchat_image_str or ldap_image_str or gravatar_image_str
            else
              msg.send ldap_image_str or hipchat_image_str or gravatar_image_str


###
  robot.respond /ldap search (.*)$/i, (msg) ->
    console.log 'Expanded'
    userID = msg.match[1]
    client = ldap.createClient ldap_settings
    resp_str = ''

    if userID.match /ddc/
      chosenFilter = '(&(sAMAccountName=' + userID + ')(objectClass=user))'
    else if userID.match /@/
      chosenFilter = '(&(mail=*' + userID + '*)(objectClass=user))'
    else
      chosenFilter = '(&(name=*' + userID + '*)(objectClass=user))'

    client.bind bindDn, '', (err) ->
      console.log 'Successful LDAP authentication for test'
      client.unbind

    searchOpts =
      filter: chosenFilter
      scope: 'sub'
#      attributes: ['cn', 'title', 'department', 'mail', 'telephoneNumber', 'st', 'manager', 'sAMAccountName','thumbnailPhoto']

    client.search 'OU=Earthlings,OU=People,DC=dealerdotcom,DC=corp', searchOpts, (err, res) ->
      res.on 'searchEntry', (entry) ->
        resp_str = 'Information for earthling ' + userID + ':\n'

        console.log('entry: ' + JSON.stringify(entry.object));

        #for attr in entry.attributes
        #  resp_str += attr.type + ': ' + attr.vals.join(',\n ') + '\n'
        #resp_str += attr.vals.join(',\n ')+'\n'

        msg.send resp_str

      res.on 'end', (result) ->
        if resp_str == ''
          msg.send 'No earthlings were found based on your search.'
###

