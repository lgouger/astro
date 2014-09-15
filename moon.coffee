# Description
#   Display the moon's current phase
#
# Commands:
#   To get the current phase of the moon:
#       Hubot> The moon is waxing crescent, 10.5% illuminated, Age of moon: 3 days, 2 hours, 31 minutes.
#     hubot moon
#     hubot phase
#     hubot phase of the moon
#     hubot moon phase
#     hubot what is the current phase of the moon
#
#  To get the dates of all phases of the moon:
#       Hubot> Last new moon:  Sat, 05 Oct 2013 00:34:10 GMT
#       Hubot> First quarter:  Fri, 11 Oct 2013 23:03:54 GMT
#       Hubot> Full moon:      Fri, 18 Oct 2013 23:37:36 GMT
#       Hubot> Last quarter:   Sat, 26 Oct 2013 23:42:04 GMT
#       Hubot> Next new moon:  Sun, 03 Nov 2013 12:49:32 GMT
#    hubot phases
#    hubot moon phases
#    hubot phases of the moon
#    hubot when is the next full moon
#
#  To get the current julian date:
#       Hubot> The current julian date is 2456573.4948289003
#    hubot julian date
#    hubot julian day
#
# Author:
#   lgouger
#
# Thanks to
#   John Walker, based on moontool (http://www.fourmilab.ch/)
#   Kevin Turner <acapnotic@twistedmatrix.com> python port of moontool
#
# This program is in the public domain: "Do what thou wilt shall be
# the whole of the law".
#   

DEBUG_VERBOSITY = no

# Precision used when describing the moon's phase in textual format,
# in phase_string().
PRECISION = 0.05
NEW =   0 / 4.0
FIRST = 1 / 4.0
FULL = 2 / 4.0
LAST = 3 / 4.0
NEXTNEW = 4 / 4.0

c = 
  # JDN stands for Julian Day Number
  # Angles here are in degrees
  
  # 1980 January 0.0 in JDN
  # XXX: DateTime(1980).jdn yields 2444239.5 -- which one is right?
  epoch: 2444238.5
  
  # Ecliptic longitude of the Sun at epoch 1980.0
  ecliptic_longitude_epoch: 278.833540
  
  # Ecliptic longitude of the Sun at perigee
  ecliptic_longitude_perigee: 282.596403
  
  # Eccentricity of Earth's orbit
  eccentricity: 0.016718
  
  # Semi-major axis of Earth's orbit, in kilometers
  sun_smaxis: 1.49585e8
  
  # Sun's angular size, in degrees, at semi-major axis distance
  sun_angular_size_smaxis: 0.533128
  
  ## Elements of the Moon's orbit, epoch 1980.0

  # Moon's mean longitude at the epoch
  moon_mean_longitude_epoch: 64.975464

  # Mean longitude of the perigee at the epoch
  moon_mean_perigee_epoch: 349.383063
  
  # Mean longitude of the node at the epoch
  node_mean_longitude_epoch: 151.950429
  
  # Inclination of the Moon's orbit
  moon_inclination: 5.145396
  
  # Eccentricity of the Moon's orbit
  moon_eccentricity: 0.054900
  
  # Moon's angular size at distance a from Earth
  moon_angular_size: 0.5181
  
  # Semi-mojor axis of the Moon's orbit, in kilometers
  moon_smaxis: 384401.0

  # Parallax at a distance a from Earth
  moon_parallax: 0.9507
  
  # Synodic month (new Moon to new Moon), in days
  synodic_month: 29.53058868
  
  # Base date for E. W. Brown's numbered series of lunations (1923 January 16)
  lunations_base: 2423436.0
  
  ## Properties of the Earth
  earth_radius: 6378.16
  
  ## Julian day of J1900 epoch
  # J1900: 2415021.0  (1900,1,1)
  J1900: 2451545.0

  ## Julian day of J2000 epoch
  J2000: 2451545.0

  ## Days in Julian century
  JulianCentury: 36525.0




fixangle = (a) -> a - 360.0 * Math.floor(a/360.0)
torad = (d) -> d * Math.PI / 180.0
todeg = (r) -> r * 180.0 / Math.PI
dsin = (d) -> Math.sin(torad(d))
dcos = (d) -> Math.cos(torad(d))

# """Solve the equation of Kepler."""
kepler = (m, ecc) ->
  epsilon = 1e-6
  e = m = torad(m)
  delta = 1;
  while Math.abs(delta) >= epsilon
      delta = e - ecc * Math.sin(e) - m
      e = e - delta / (1.0 - ecc * Math.cos(e))
  e

phase_string = (p) ->
  switch 
   	when p <= (NEW + PRECISION )     then 'new'
    when p <= (FIRST - PRECISION )   then 'waxing crescent'
    when p <= (FIRST + PRECISION )   then 'first quarter'
    when p <= (FULL - PRECISION )    then 'waxing gibbous'
    when p <= (FULL + PRECISION )    then 'full'
    when p <= (LAST - PRECISION )    then 'waning gibbous'
    when p <= (LAST + PRECISION )    then 'last quarter'
    when p <= (NEXTNEW - PRECISION ) then 'waning crescent'
    when p <= (NEXTNEW + PRECISION ) then 'new'
    else 'error'


Date.prototype.Date2Julian = ->
  # (@ / 86400000.00) - (@.getTimezoneOffset()/1440) + 2440587.5
  (@ / 86400000) + 2440587.5

Number.prototype.Julian2Date = ->
  X = parseFloat(this) + 0.5
  Z = Math.floor(X) ## Get day without time
  F = X - Z  ## Get time
  Y = Math.floor((Z - 1867216.25) / 36524.25)
  A = Z + 1 + Y - Math.floor(Y / 4)
  B = A + 1524
  C = Math.floor((B - 122.1) / 365.25)
  D = Math.floor(365.25 * C)
  G = Math.floor((B - D) / 30.6001)
  ## must get number less than or equal to 12)
  month = if (G < 13.5) then (G - 1) else (G - 13)
  ## if Month is January or February, or the rest of year
  year = if (month < 2.5) then (C - 4715) else (C - 4716)
  month -= 1; ## Handle JavaScript month format
  UT = B - D - Math.floor(30.6001 * G) + F
  day = Math.floor(UT)
  ## Determine time
  UT -= Math.floor(UT)
  UT *= 24
  hour = Math.floor(UT)
  UT -= Math.floor(UT)
  UT *= 60
  minute = Math.floor(UT)
  UT -= Math.floor(UT)
  UT *= 60
  second = Math.floor(UT)
  UT -= Math.floor(UT)
  UT *= 1000

  new Date(Date.UTC(year, month, day, hour, minute, second, Math.round(UT)))


##
#
phase = (phase_date = new Date()) ->
  ##
  # """Calculate phase of moon as a fraction:
  # 
  # The argument is the time for which the phase is requested,
  # expressed in either a DateTime or by Julian Day Number.
  # 
  # Returns a dictionary containing the terminator phase angle as a
  # percentage of a full circle (i.e., 0 to 1), the illuminated
  # fraction of the Moon's disc, the Moon's age in days and fraction,
  # the distance of the Moon from the centre of the Earth, and the
  # angular diameter subtended by the Moon as seen by an observer at
  # the centre of the Earth."""
  #
  # Calculation of the Sun's position
  
  # date within the epoch
  if (phase_date instanceof Date)
    day = phase_date.Date2Julian() - c.epoch
  else
    day = phase_date - c.epoch
  
  # Mean a`maly of the Sun
  N = fixangle((360/365.2422) * day)
  # Convert from perigee coordinates to epoch 1980
  M = fixangle(N + c.ecliptic_longitude_epoch - c.ecliptic_longitude_perigee)

  # Solve Kepler's equation
  Ec = kepler(M, c.eccentricity)
  Ec = Math.sqrt((1 + c.eccentricity) / (1 - c.eccentricity)) * Math.tan(Ec/2.0)
  # True anomaly
  Ec = 2 * todeg(Math.atan(Ec))
  # Suns's geometric ecliptic longuitude
  lambda_sun = fixangle(Ec + c.ecliptic_longitude_perigee)
  
  # Orbital distance factor
  F = ((1 + c.eccentricity * Math.cos(torad(Ec))) / (1 - Math.pow(c.eccentricity, 2)))
  
  # Distance to Sun in km
  sun_dist = c.sun_smaxis / F
  sun_angular_diameter = F * c.sun_angular_size_smaxis
  
  ########
  #
  # Calculation of the Moon's position
  
  # Moon's mean longitude
  moon_longitude = fixangle(13.1763966 * day + c.moon_mean_longitude_epoch)
  
  # Moon's mean anomaly
  MM = fixangle(moon_longitude - 0.1114041 * day - c.moon_mean_perigee_epoch)
  
  # Moon's ascending node mean longitude
  # MN = fixangle(c.node_mean_longitude_epoch - 0.0529539 * day)
  
  evection = 1.2739 * Math.sin(torad(2*(moon_longitude - lambda_sun) - MM))
  
  # Annual equation
  annual_eq = 0.1858 * Math.sin(torad(M))
  
  # Correction term
  A3 = 0.37 * Math.sin(torad(M))
  
  MmP = MM + evection - annual_eq - A3
  
  # Correction for the equation of the centre
  mEc = 6.2886 * Math.sin(torad(MmP))
  
  # Another correction term
  A4 = 0.214 * Math.sin(torad(2 * MmP))
  
  # Corrected longitude
  lP = moon_longitude + evection + mEc - annual_eq + A4
  
  # Variation
  variation = 0.6583 * Math.sin(torad(2*(lP - lambda_sun)))
  
  # True longitude
  lPP = lP + variation
  
  #
  # Calculation of the Moon's inclination
  # unused for phase calculation.
  
  # Corrected longitude of the node
  # NP = MN - 0.16 * sin(torad(M))
  
  # Y inclination coordinate
  # y = sin(torad(lPP - NP)) * cos(torad(c.moon_inclination))
  
  # X inclination coordinate
  # x = cos(torad(lPP - NP))
  
  # Ecliptic longitude (unused?)
  # lambda_moon = todeg(atan2(y,x)) + NP
  
  # Ecliptic latitude (unused?)
  # BetaM = todeg(asin(sin(torad(lPP - NP)) * sin(torad(c.moon_inclination))))
  
  #######
  #
  # Calculation of the phase of the Moon
  
  # Age of the Moon, in degrees
  moon_age = lPP - lambda_sun
  
  # Phase of the Moon
  moon_phase = (1 - Math.cos(torad(moon_age))) / 2.0
  
  # Calculate distance of Moon from the centre of the Earth
  moon_dist = (c.moon_smaxis * (1 - Math.pow(c.moon_eccentricity, 2))) / (1 + c.moon_eccentricity * Math.cos(torad(MmP + mEc)))
  
  # Calculate Moon's angular diameter
  moon_diam_frac = moon_dist / c.moon_smaxis
  moon_angular_diameter = c.moon_angular_size / moon_diam_frac
  
  # Calculate Moon's parallax (unused?)
  # moon_parallax = c.moon_parallax / moon_diam_frac
  res_phase = fixangle(moon_age) / 360.0
  res_age = c.synodic_month * fixangle(moon_age) / 360.0 
  
  res = {
      phase: res_phase,
      illuminated: moon_phase,
      age: res_age,
      distance: moon_dist,
      angular_diameter: moon_angular_diameter,
      sun_distance: sun_dist,
      sun_angular_diameter: sun_angular_diameter
      }
# phase()

##
#
phase_hunt = (sdate = new Date()) ->
  # """Find time of phases of the moon which surround the current date.
  #
  # Five phases are found, starting and ending with the new moons
  # which bound the current lunation.
  # """

  if (sdate instanceof Date)
  	sdate = sdate.Date2Julian()

  #if not hasattr(sdate,'jdn'):
  #  sdate = DateTime.DateTimeFromJDN(sdate)
 
  ajdn = sdate - 45 # date minus 45 days
  adate = ajdn.Julian2Date()

  # adate = sdate + DateTime.RelativeDateTime(days=-45)
 
  k1 = Math.floor((adate.getUTCFullYear() + (adate.getUTCMonth()  * (1.0/12.0)) - 1900) * 12.3685)
 
  nt1 = meanphase(ajdn, k1)
  ajdn = nt1
 
  # sdate = sdate.jdn
 
  while true
    ajdn = ajdn + c.synodic_month
    k2 = k1 + 1
    nt2 = meanphase(ajdn, k2)
    if nt1 <= sdate < nt2
      break
    nt1 = nt2
    k1 = k2
 
  # phases = list(map(truephase,
  #               [k1,    k1,    k1,    k1,    k2],
  #               [0/4.0, 1/4.0, 2/4.0, 3/4.0, 0/4.0]))
  phase_last_new  = truephase(k1, 0/4.0)
  phase_first_qtr = truephase(k1, 1/4.0)
  phase_full      = truephase(k1, 2/4.0)
  phase_last_qtr  = truephase(k1, 3/4.0)
  phase_next_new  = truephase(k2, 0/4.0)

  [phase_last_new, phase_first_qtr, phase_full, phase_last_qtr, phase_next_new]
# phase_hunt()

##
#
meanphase = (sdate, k) ->
  # """Calculates time of the mean new Moon for a given base date.
  # 
  # This argument K to this function is the precomputed synodic month
  # index, given by:
  # 
  #                     K = (year - 1900) * 12.3685
  # 
  # where year is expressed as a year and fractional year.
  # """

  # Time in Julian centuries from 1900 January 0.5
  if (sdate instanceof Date)
    delta_t = sdate.Date2Julian() - c.J1900
  else
    delta_t = sdate - c.J1900

  t = delta_t / 36525
  
  # square for frequent use
  t2 = t * t
  # and cube for frequent use
  t3 = t2 * t
  
  nt1 = 2415020.75933 + c.synodic_month * k + 0.0001178 * t2 - 0.000000155 * t3 + 0.00033 * dsin(166.56 + 132.87 * t - 0.009173 * t2)
# meanphase()

##
#
truephase = (k, tphase) ->
  # """Given a K value used to determine the mean phase of the new moon, and a phase selector (0.0, 0.25, 0.5, 0.75), 
  #    obtain the true, corrected phase time."""

  apcor = false

  # add phase to new moon time
  k = k + tphase
  # Time in Julian centuries from 1900 January 0.5
  t = k / 1236.85
  t2 = t * t
  t3 = t2 * t


  # Mean time of phase
  pt = 2415020.75933 + c.synodic_month * k + 0.0001178 * t2 - 0.000000155 * t3 + 0.00033 * dsin(166.56 + 132.87 * t - 0.009173 * t2)

  # Sun's mean anomaly
  m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3

  # Moon's mean anomaly
  mprime = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3

  # Moon's argument of latitude
  f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3


  if (tphase < 0.01) or (Math.abs(tphase - 0.5) < 0.01)
    # Corrections for New and Full Moon
    pt = pt + 
        (0.1734 - 0.000393 * t) * dsin(m) +
        0.0021 * dsin(2 * m) -
        0.4068 * dsin(mprime) +
        0.0161 * dsin(2 * mprime) -
        0.0004 * dsin(3 * mprime) +
        0.0104 * dsin(2 * f) -
        0.0051 * dsin(m + mprime) -
        0.0074 * dsin(m - mprime) +
        0.0004 * dsin(2 * f + m) -
        0.0004 * dsin(2 * f - m) -
        0.0006 * dsin(2 * f + mprime) +
        0.0010 * dsin(2 * f - mprime) +
        0.0005 * dsin(m + 2 * mprime)
    apcor = true
  else if (Math.abs(tphase - 0.25) < 0.01) or (Math.abs(tphase - 0.75) < 0.01)
    pt = pt + 
        (0.1721 - 0.0004 * t) * dsin(m) +
        0.0021 * dsin(2 * m) -
        0.6280 * dsin(mprime) +
        0.0089 * dsin(2 * mprime) -
        0.0004 * dsin(3 * mprime) +
        0.0079 * dsin(2 * f) -
        0.0119 * dsin(m + mprime) -
        0.0047 * dsin(m - mprime) +
        0.0003 * dsin(2 * f + m) -
        0.0004 * dsin(2 * f - m) -
        0.0006 * dsin(2 * f + mprime) +
        0.0021 * dsin(2 * f - mprime) +
        0.0003 * dsin(m + 2 * mprime) +
        0.0004 * dsin(m - 2 * mprime) -
        0.0003 * dsin(2 * m + mprime)
    
    if (tphase < 0.5)
      #  First quarter correction
      pt = pt + 0.0028 - 0.0004 * dcos(m) + 0.0003 * dcos(mprime)
    else
      #  Last quarter correction
      pt = pt + -0.0028 + 0.0004 * dcos(m) - 0.0003 * dcos(mprime)
    apcor = true

  if not apcor
    null
  else
  	pt.Julian2Date()
# truephase()

##
#
prettyLocal = (d) ->
  year  = d.getFullYear()
  month = d.getMonth() + 1
  month = "0" + month if (month < 10)
  day   = d.getDate()
  day   = "0" + day if (day < 10)
  hour  = d.getHours()
  hour  = "0" + hour if (hour < 10)
  minut = d.getMinutes()
  minut = "0" + minut if (minut < 10)
  secon = d.getSeconds()
  secon = "0" + secon if (secon < 10)
  msecs = d.getMilliseconds()
  msecs = if (msecs < 10) then "00" + msecs else if (msecs < 100) then "0" + msecs else msecs
  "#{year}-#{month}-#{day} #{hour}:#{minut}:#{secon}.#{msecs}"

displayPhases = (phases) ->
  result = [ "Last new moon:  #{phases[0].toUTCString()}",
             "First quarter:  #{phases[1].toUTCString()}",
             "Full moon:      #{phases[2].toUTCString()}",
             "Last quarter:   #{phases[3].toUTCString()}",
             "Next new moon:  #{phases[4].toUTCString()}" ]



module.exports = (robot) ->
  robot.respond /(what is )?(the )?(julian (day|date)|jdn)/i, (msg) ->
    now = new Date()
    jdn = now.Date2Julian()
    if DEBUG_VERBOSITY
      console.log("Today: #{now.toString()} (#{now.getTime()})")
      console.log("  Local :: #{prettyLocal(now)}")
      console.log("    UTC :: #{now.toISOString()}")
      console.log("    JDN :: #{jdn}")
      console.log ""
      
      test_date = jdn.Julian2Date()
      console.log("   Date :: #{prettyLocal(test_date)}")
      console.log("        :: #{test_date.toISOString()}")
      console.log("        :: #{test_date}")
      console.log ""

    msg.send("The current julian date is #{jdn}")

  robot.respond /(what is )?(the )?(current )?(phase )?(of the )?moon$/i, (msg) ->
    res = phase()
    if DEBUG_VERBOSITY
      console.log("phase :: phase = #{res.phase} '#{phase_string(res.phase)}'")
      console.log("      :: illuminated = #{res.illuminated}")
      console.log("      :: age = #{res.age}")
      console.log("      :: distance = #{res.distance}")
      console.log("      :: angular_diameter = #{res.angular_diameter}")
      console.log("      :: sun_distance = #{res.sun_distance}")
      console.log("      :: sun_angular_diameter = #{res.sun_angular_diameter}")
      console.log("")
    
    moon_days = Math.floor(res.age)
    moon_hours = Math.floor((res.age - moon_days) * 24)
    moon_minutes = Math.floor((((res.age - moon_days) * 24) - moon_hours) * 60)
    msg.send "The moon is #{phase_string(res.phase)}, #{(res.illuminated * 100.0).toFixed(1)}% illuminated, Age of moon: #{moon_days} days, #{moon_hours} hours, #{moon_minutes} minutes."

  robot.respond /(what is )?(the )?(current )?(moon('s)? )?(current )?phase$/i, (msg) ->
    res = phase()
    moon_days = Math.floor(res.age)
    moon_hours = Math.floor((res.age - moon_days) * 24)
    moon_minutes = Math.floor((((res.age - moon_days) * 24) - moon_hours) * 60)
    msg.send "The moon is #{phase_string(res.phase)}, #{(res.illuminated * 100.0).toFixed(1)}% illuminated, Age of moon: #{moon_days} days, #{moon_hours} hours, #{moon_minutes} minutes."

  robot.respond /(what are )?(the )?moon('s)? phases$/i, (msg) ->
    msg.send displayPhases(phase_hunt()).join "\n"

  robot.respond /(what are )?(the )?phases( of the)?( moon)?$/i, (msg) ->
    msg.send displayPhases(phase_hunt()).join "\n"

  robot.respond /(when is )?(the )?(next )?(full|new) moon/i, (msg) ->
    msg.send displayPhases(phase_hunt()).join "\n"

