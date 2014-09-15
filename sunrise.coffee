#!/usr/bin/env jjs -scripting

fixangle = (x, mod) ->
    return (x - mod * (Math.floor(x / mod)))


computeSunrise = (day, sunrise) ->
 
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

    # San Francisco:
    var latitude = 37.76834106;
    var longitude = -122.41825867;

    var zenith = 90.83333333333333;

    var D2R = Math.PI / 180;
    var R2D = 180 / Math.PI;
 
    # convert the longitude to hour value and calculate an approximate time
    var lnHour = longitude / 15;
    print("  lnHour: ${lnHour}.");

    var t;
    if (sunrise) {
        t = day + ((6 - lnHour) / 24);
        var temp1 = 6 - lnHour;
        var temp2 = (6 - lnHour) / 24;
        print(" sunrise: ${temp1}, ${temp2}.");
    } else {
        t = day + ((18 - lnHour) / 24);
        var temp1 = 18 - lnHour;
        var temp2 = (18 - lnHour) / 24;
        print(" sunset: ${temp1}, ${temp2}.");
    };
    print("  t: ${t}.");
 
    # calculate the Sun's mean anomaly
    M = (0.9856 * t) - 3.289;
    print("  M: ${M}.");
 
    # calculate the Sun's true longitude
    L = M + (1.916 * Math.sin(M * D2R)) + (0.020 * Math.sin(2 * M * D2R)) + 282.634;
    L = fixangle(L, 360);
    print("  L: ${L}.");

 
    # calculate the Sun's right ascension
    RA = R2D * Math.atan(0.91764 * Math.tan(L * D2R));
    RA = fixangle(RA, 360);
    print("  RA: ${RA}.");
 
    # right ascension value needs to be in the same qua
    Lquadrant = (Math.floor(L / (90))) * 90;
    RAquadrant = (Math.floor(RA / 90)) * 90;
    RA = RA + (Lquadrant - RAquadrant);
    print("  RA (quadrant adjustment): ${RA}.");
 
    # right ascension value needs to be converted into hours
    RA = RA / 15;
    print("  RA (hours): ${RA}.");
 
    # calculate the Sun's declination
    sinDec = 0.39782 * Math.sin(L * D2R);
    cosDec = Math.cos(Math.asin(sinDec));
    print("  sinDec: ${sinDec}.");
    print("  cosDec: ${cosDec}.");
 
    # calculate the Sun's local hour angle
    cosH = (Math.cos(zenith * D2R) - (sinDec * Math.sin(latitude * D2R))) / (cosDec * Math.cos(latitude * D2R));
    print("  cosH: ${cosH}.");

    var H;
    if (sunrise) {
        H = 360 - R2D * Math.acos(cosH)
    } else {
        H = R2D * Math.acos(cosH)
    };
    H = H / 15;
    print("  H: ${H}.");
 
    # calculate local mean time of rising/setting
    T = H + RA - (0.06571 * t) - 6.622;
    print("  T: ${T}.");
 
    # adjust back to UTC
    UT = T - lnHour;
    UT = fixangle(UT, 24);
    print("  UT: ${UT}.");
 
    # convert UT value to local time zone of latitude/longitude
    localT = UT - 7;
    localT = fixangle(localT, 24);
    print("  localT: ${localT}.");
 
    # convert to Milliseconds
    return localT * 3600 * 1000;
}

function dayOfYear() {
    var yearFirstDay = Math.floor(new Date().setFullYear(new Date().getFullYear(), 0, 1) / 86400000),
        today = Math.ceil((new Date().getTime()) / 86400000),
        doy = today - yearFirstDay;
    return doy;
}

function hhmmss(millis) {
    var seconds = Math.floor(millis / 1000);
    var minutes = Math.floor(millis / (1000 * 60));
    var hours   = Math.floor(millis / (1000 * 60 * 60));
    minutes = fixangle(minutes, 60);
    seconds = fixangle(seconds, 60);
    if (seconds < 10) {
        seconds = "0" + seconds;
    }
    if (minutes < 10) {
        minutes = "0" + minutes;
    }
    if (hours < 10) {
        hours = "0" + hours;
    }

    return "${hours}:${minutes}:${seconds}";
}

function fixangle(x, mod) {
    return (x - mod * (Math.floor(x / mod)));
}

print("Today the sun will rise at " + hhmmss(computeSunrise(dayOfYear(),true)) + ".");
print("Today the sun will set at "  + hhmmss(computeSunrise(dayOfYear(),false)) + ".");

