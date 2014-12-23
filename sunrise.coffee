# Description
#   <description of the scripts functionality>
#
# Dependencies:
#   "<module name>": "<module version>"
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot <trigger> - <what the respond trigger does>
#   <trigger> - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   <github username of the original script author>

fixangle = (x, mod) -> x - mod * Math.floor(x / mod)


torad = (d) -> d * Math.PI / 180.0
todeg = (r) -> r * 180.0 / Math.PI

dsin = (d) -> Math.sin(torad(d))
dcos = (d) -> Math.cos(torad(d))
dtan = (d) -> Math.tan(torad(d))

dasin = (n) -> todeg(Math.asin(n))
dacos = (n) -> todeg(Math.acos(n))
datan = (n) -> todeg(Math.atan(n))


# San Francisco:
latitude = 37.76834106
longitude = -122.41825867

# MB
mb_latitude = 33.884645
mb_longitude = -118.409191

btv_latitude = 44.465492
btv_longitude = -73.214215

dal_latitude = 32.936004
dal_longitude = -96.819108

official_zenith     = 90.83333333333333
civil_zenith        = 96
nautical_zenith     = 102
astronomical_zenith = 108




computeSunrise = (latitude, longitude, zenith, day, sunrise) ->
  #  Sunrise/Sunset Algorithm taken from
  #    http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
  #    inputs:
  #        day = day of the year
  #        sunrise = true for sunrise, false for sunset
  #    output:
  #        time of sunrise/sunset in milliseconds

  #  lat, lon for Berlin, Germany
  #  var longitude = 13.408056;
  #  var latitude = 52.518611;


  # convert the longitude to hour value and calculate an approximate time
  lnHour = longitude / 15
#  console.log("  lnHour: #{lnHour}.")

  t = 0
  if (sunrise)
    t = day + ((6 - lnHour) / 24)
    temp1 = 6 - lnHour
    temp2 = (6 - lnHour) / 24
#    console.log(" sunrise: #{temp1}, #{temp2}.")
  else
    t = day + ((18 - lnHour) / 24);
    temp1 = 18 - lnHour;
    temp2 = (18 - lnHour) / 24;
#    console.log(" sunset: #{temp1}, #{temp2}.")

#  console.log("  t: #{t}.")

  # calculate the Sun's mean anomaly
  M = (0.9856 * t) - 3.289
#  console.log("  M: #{M}.")

  # calculate the Sun's true longitude
  L = fixangle(M + (1.916 * dsin(M)) + (0.020 * dsin(2 * M)) + 282.634, 360)
#  console.log("  L: #{L}.")

  # calculate the Sun's right ascension
  RA = fixangle(datan(0.91764 * dtan(L)), 360)
#  console.log("  RA: #{RA}.")

  # right ascension value needs to be in the same qua
  Lquadrant = (Math.floor(L / (90))) * 90
  RAquadrant = (Math.floor(RA / 90)) * 90
  RA = RA + (Lquadrant - RAquadrant)
#  console.log("  RA (quadrant adjustment): #{RA}.")

  # right ascension value needs to be converted into hours
  RA = RA / 15
#  console.log("  RA (hours): #{RA}.")

  # calculate the Sun's declination
  sinDec = 0.39782 * dsin(L)
  cosDec = dcos(dasin(sinDec))
#  console.log("  sinDec: #{sinDec}.")
#  console.log("  cosDec: #{cosDec}.")

  # calculate the Sun's local hour angle
  cosH = (dcos(zenith) - (sinDec * dsin(latitude))) / (cosDec * dcos(latitude))
#  console.log("  cosH: #{cosH}.")

  H = 0
  if (sunrise)
    H = 360 - dacos(cosH)
  else
    H = dacos(cosH)

  H = H / 15
#  console.log("  H: #{H}.")

  # calculate local mean time of rising/setting
  T = H + RA - (0.06571 * t) - 6.622
#  console.log("  T: #{T}.")

  # adjust back to UTC
  UT = T - lnHour
  UT = fixangle(UT, 24)
#  console.log("  UT: #{UT}.")
 
  # convert UT value to local time zone of latitude/longitude
  localT = UT - 7
  localT = fixangle(localT, 24)
#  console.log("  localT: #{localT}.")
 
  # convert to Milliseconds
  return localT * 3600000


dayOfYear = () ->
  yearFirstDay = Math.floor(new Date().setFullYear(new Date().getFullYear(), 0, 1) / 86400000)
  today = Math.ceil((new Date().getTime()) / 86400000)
  doy = today - yearFirstDay

  return doy


hhmmss = (millis) ->
    seconds = Math.floor(millis / 1000)
    minutes = Math.floor(millis / (1000 * 60))
    hours   = Math.floor(millis / (1000 * 60 * 60))
    minutes = fixangle(minutes, 60)
    seconds = fixangle(seconds, 60)
    if (seconds < 10)
        seconds = "0" + seconds

    if (minutes < 10)
        minutes = "0" + minutes

    if (hours < 10)
        hours = "0" + hours

    return "#{hours}:#{minutes}:#{seconds}"


#console.log("Today the sun will rise at #{hhmmss(computeSunrise(latitude, longitude, official_zenith, dayOfYear(),true))}.")
#console.log("Today the sun will set at #{hhmmss(computeSunrise(latitude, longitude, official_zenith, dayOfYear(),false))}.")

# possible questions
#   when is the sunrise | when will the sun rise
#   when is the sunset | when will the sun set
#   when is the astronomical sunrise
#   when is the civil sunrise
#   when is the nautical sunrise in (Burlingon|90266)
#

module.exports = (robot) ->
  robot.respond /(mb)?sunrise(?: me|for|in)?\s(.*)/i, (msg) ->
    location = msg.match[1]
    switch
      when location == 'mb'
        latitude = mb_latitude
        longitude = mb_longitude
        location_name = "Manhattan Beach"
      when location == 'btv'
        latitude = btv_latitude
        longitude = btv_longitude
        location_name = "Burlington"
      when location == 'dal'
        latitude = dal_latitude
        longitude = dal_longitude
        location_name = "Dallas"
      else
        msg.send "Unknown location.\n"

    now = new Date()
    if DEBUG_VERBOSITY
      console.log("Location: #{location})")
      console.log("Today: #{now.toString()} (#{now.getTime()})")
      console.log ""

    sunrise_time = computeSunrise(latitude, longitude, official_zenith, dayOfYear(), true)

    msg.send("Sunrise in #{location_name} is at #{hhmmss(sunrise_time)}")

  robot.respond /(mb)?sunset(?: me|for|in)?\s(.*)/i, (msg) ->
    location = msg.match[1]
    switch
      when location == 'mb'
        latitude = mb_latitude
        longitude = mb_longitude
        location_name = "Manhattan Beach"
      when location == 'btv'
        latitude = btv_latitude
        longitude = btv_longitude
        location_name = "Burlington"
      when location == 'dal'
        latitude = dal_latitude
        longitude = dal_longitude
        location_name = "Dallas"
      else
        msg.send "Unknown location.\n"

    now = new Date()
    if DEBUG_VERBOSITY
      console.log("Location: #{location}, #{location_name}")
      console.log("Today: #{now.toString()} (#{now.getTime()})")
      console.log ""

    sunrise_time = computeSunrise(latitude, longitude, official_zenith, dayOfYear(), false)

    msg.send("Sunset in #{location_name} is at #{hhmmss(sunrise_time)}")
