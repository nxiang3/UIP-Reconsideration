*Set globals and paths

* date_version
global date = "v1 v2 v3 v4"
global version = "r1 r2 r3 r4"

* Currencies
global currencies = "AUD CAD CHF DEM FRF GBP ITL JPY NOK NZD SEK"


*Global
global data "$uip/data"
global raw "$uip/raw"
global inter "$uip/temp"
global results "$uip/results"
global output "$uip/output"
global figures "$output/figures"
global tables "$output/tables"

cap mkdir "$data"
cap mkdir "$raw"
cap mkdir "$raw"
cap mkdir "$inter"
cap mkdir "$results"
cap mkdir "$output"
cap mkdir "$figures"
cap mkdir "$tables"
