(ns sunrise.core
  (:import (org.joda.time DateTime DateTimeZone)
            (org.joda.time.base BaseDateTime)) )

(require '[clj-time.core :as t])

(defn fixangle [a] (mod a 360))

(defn torad [n] (* n (/ Math/PI 180.0)))
(defn todeg [n] (* n (/ 180.0 Math/PI)))

(defn dsin [d]
  (Math/sin (torad d)))

(defn dcos [d]
  (Math/cos (torad d)))

(defn dtan [d]
  (Math/tan (torad d)))


(defn dasin [n]
  (todeg (Math/asin n)))

(defn dacos [n]
  (todeg (Math/acos n)))

(defn datan [n]
  (todeg (Math/atan n)))


(defn compute-sunrise [ latitude longitude day zenith ]
  (let [longitude-hour (/ longitude 15)
        N (.getDayOfYear day)
        t (+ N (/ (- 6 longitude-hour) 24))
        M (- (* 0.9856 t) 3.289)
        L (fixangle (+ M (* 1.916 (dsin M)) (* 0.020 (dsin (* 2 M))) 282.634))
        RA (fixangle (datan (* 0.91764 (dtan L))))
        LQ (* (Math/floor (/ L 90)) 90)
        RAQ (* (Math/floor (/ RA 90)) 90)
        RA-hours (/ (+ RA (- LQ RAQ)) 15)
        sin-dec (* 0.39782 (dsin L))
        cos-dec (dcos (dasin sin-dec))
        cosH (/ (- (dcos zenith) (* sin-dec (dsin latitude))) (* cos-dec (dcos latitude)))
        H (/ (- 360 (dacos cosH)) 15)
        rising-time (+ H RA-hours (* -0.06571 t) -6.622)
        UTC-rising-millis (* (mod (- rising-time longitude-hour) 24) 3600000)
        local-rising-millis (+ UTC-rising-millis (.getOffset (.getZone day) day))
        ]
    (if (> cosH 1.0)
      nil
      (.plusMillis (.toDateTime (.toDateMidnight now)) local-rising-millis))
    ))

(defn compute-sunset [ latitude longitude day zenith ]
  (let [longitude-hour (/ longitude 15)
        N (.getDayOfYear day)
        t (+ N (/ (- 18 longitude-hour) 24))
        M (- (* 0.9856 t) 3.289)
        L (fixangle (+ M (* 1.916 (dsin M)) (* 0.020 (dsin (* 2 M))) 282.634))
        RA (fixangle (datan (* 0.91764 (dtan L))))
        LQ (* (Math/floor (/ L 90)) 90)
        RAQ (* (Math/floor (/ RA 90)) 90)
        RA-hours (/ (+ RA (- LQ RAQ)) 15)
        sin-dec (* 0.39782 (dsin L))
        cos-dec (dcos (dasin sin-dec))
        cosH (/ (- (dcos zenith) (* sin-dec (dsin latitude))) (* cos-dec (dcos latitude)))
        H (/ (dacos cosH) 15)
        setting-time (+ H RA-hours (* -0.06571 t) -6.622)
        UTC-setting-millis (* (mod (- setting-time longitude-hour) 24) 3600000)
        local-setting-millis (+ UTC-setting-millis (.getOffset (.getZone day) day))
        ]
    (if (< cosH -1.0)
      nil
      (.plusMillis (.toDateTime (.toDateMidnight now)) local-setting-millis))
    ))



; (deg2rad 360)
; (rad2deg (/ (* 2 Math/PI) 3) )

; Inputs:
; 	day, month, year:      date of sunrise/sunset
(def now (DateTime. (DateTimeZone/getDefault)))

(def N (.getDayOfYear now))

now




;; 1. first calculate the day of the year
;;    N1 = floor(275 * month / 9)
;(def N1 (Math/floor (/ (* 275 month) 9)))
;;	   N2 = floor((month + 9) / 12)
;(def N2 (Math/floor (/ (+ month 9) 12)))
;;	   N3 = (1 + floor((year - 4 * floor(year / 4) + 2) / 3))
;(def N3 (+ 1 (Math/floor (/ (+ year 2 (* -4 (Math/floor (/ year 4)))) 3))))
;;	   N = N1 - (N2 * N3) + day - 30
;(def N (+ N1 (* -1 N2 N3) day -30))

N

; 	latitude, longitude:   location for sunrise/sunset
; San Francisco
;    "lat": "37.76834106
;    "lon": "-122.41825867"
(def latitude 37.76834106)
(def longitude -122.41825867)

; 	zenith:     Sun's zenith for sunrise/sunset
; 	  offical      = 90 degrees 50'
; 	  civil        = 96 degrees
; 	  nautical     = 102 degrees
; 	  astronomical = 108 degrees
(def zenith 90.83333333333333)


; 2. convert the longitude to hour value and calculate an approximate time
;
;	  lngHour = longitude / 15
;
;	  if rising time is desired:
;	    t = N + ((6 - lngHour) / 24)
;	  if setting time is desired:
;  	  t = N + ((18 - lngHour) / 24)
;
(def longitude-hour (/ longitude 15))
; longitude-hour


(def t (+ N (/ (- 6 longitude-hour) 24)))

; t


; 3. calculate the Sun's mean anomaly
;
; 	M = (0.9856 * t) - 3.289
(def M (- (* 0.9856 t) 3.289))

; M

; 4. calculate the Sun's true longitude
;
; 	L = M + (1.916 * sin(M)) + (0.020 * sin(2 * M)) + 282.634
; 	NOTE: L potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
(def L (fixangle (+ M (* 1.916 (dsin M)) (* 0.020 (dsin (* 2 M))) 282.634)))

; L

; 5a. calculate the Sun's right ascension
;
; 	RA = atan(0.91764 * tan(L))
; 	NOTE: RA potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
(def RA (fixangle (datan (* 0.91764 (dtan L)))))

; RA

;
; 5b. right ascension value needs to be in the same quadrant as L
;
; 	Lquadrant  = (floor( L/90)) * 90
; 	RAquadrant = (floor(RA/90)) * 90
; 	RA = RA + (Lquadrant - RAquadrant)
(def LQ (* (Math/floor (/ L 90)) 90))
(def RAQ (* (Math/floor (/ RA 90)) 90))
(def new-RA (+ RA (- LQ RAQ)))

; LQ
; RAQ
; new-RA

; 5c. right ascension value needs to be converted into hours
;
; 	RA = RA / 15
(def RA-hours (/ new-RA 15))

; RA-hours

;
; 6. calculate the Sun's declination
;
; 	sinDec = 0.39782 * sin(L)
; 	cosDec = cos(asin(sinDec))

(def sin-dec (* 0.39782 (dsin L)))
(def cos-dec (dcos (dasin sin-dec)))

; sin-dec
; cos-dec

; 7a. calculate the Sun's local hour angle
;
; 	cosH = (cos(zenith) - (sinDec * sin(latitude))) / (cosDec * cos(latitude))
;
; 	if (cosH >  1)
; 	  the sun never rises on this location (on the specified date)
; 	if (cosH < -1)
; 	  the sun never sets on this location (on the specified date)

(def cosH (/ (- (dcos zenith) (* sin-dec (dsin latitude))) (* cos-dec (dcos latitude))))

; cosH

(if (> cosH 1) (println "the sun never rises"))


;
; 7b. finish calculating H and convert into hours
;
; 	if if rising time is desired:
; 	  H = 360 - acos(cosH)
; 	if setting time is desired:
; 	  H = acos(cosH)
;
; 	H = H / 15
(def H (/ (- 360 (dacos cosH)) 15))

; H


;
; 8. calculate local mean time of rising/setting
;
; 	T = H + RA - (0.06571 * t) - 6.622
(def rising-time (+ H RA-hours (* -0.06571 t) -6.622))

; rising-time

;
; 9. adjust back to UTC
;
; 	UT = T - longitude-hour
; 	NOTE: UT potentially needs to be adjusted into the range [0,24) by adding/subtracting 24
(def rising-UT (mod (- rising-time longitude-hour) 24))

; rising-UT

;
; 10. convert UT value to local time zone of latitude/longitude
;
; 	localT = UT + localOffset
(def local-rising-time (+ rising-UT -7))
; local-rising-time
(def local-rising-millis (long (* local-rising-time 3600000)))
; local-rising-millis



(def sunrise (.plusMillis (.toDateTime (.toDateMidnight now)) local-rising-millis))


(format "the sun rises at %s" sunrise)


(def now (DateTime. (DateTimeZone/getDefault)))

(def sfo-latitude 37.76834106)
(def sfo-longitude -122.41825867)

(def mb-latitude 33.897)
(def mb-longitude -118.418)


(def official-zenith 90.83333333333333)


(compute-sunrise mb-latitude mb-longitude now official-zenith)
(compute-sunset mb-latitude mb-longitude now official-zenith)
