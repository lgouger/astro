(defn fixangle [a]
  (mod a 360))

(mod 385 360)

(fixangle 385)

(defn torad [d]
  (* d (/ Math/PI 180.0)))

(defn todeg [r]
  (* r (/ 180.0 Math/PI)))


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

(def latitude-work 33.884665)
(def longitude-work -118.409299)


; Inputs:
;       day, month, year:      date of sunrise/sunset
(def day 29)
(def month 8)
(def year 2014)

;       latitude, longitude:   location for sunrise/sunset
; San Francisco
;    "lat": "37.76834106
;    "lon": "-122.41825867"
(def latitude 37.76834106)
(def longitude -122.41825867)

;       zenith:     Sun's zenith for sunrise/sunset
;         offical      = 90 degrees 50'
;         civil        = 96 degrees
;         nautical     = 102 degrees
;         astronomical = 108 degrees
(def zenith 96)
