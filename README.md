
<!-- README.md is generated from README.Rmd. Please edit that file -->

# romato

Interact Zomato with R

## Installation

You can install the development version of romato from
[Github](https://github.com/earowang/romato) with:

``` r
devtools::install_github("earowang/romato")
```

## Usage

First of all, you need an API key to access Zomato, which you can sign
up [here](https://developers.zomato.com/api).

``` r
library(romato)
zmt <- zomato$new(api_key = "your-api-key")
zmt
#> <Zomato API> 
#>  ▶ Restaurants: 
#>  ✔ dailymenu(res_id)
#>  ✔ restaurant(res_id)
#>  ✔ reviews(res_id)
#>  ✔ search(
#>       query, lat = NULL, lon = NULL, radius = NULL, cuisines = NULL, 
#>       establishment_type = NULL, collection_id = NULL, category = NULL, 
#>       sort = NULL, order = NULL
#>     )
#>  ▶ Location: 
#>  ✔ locations(query, lat = NULL, lon = NULL)
#>  ✔ location_details(entity_id, entity_type)
#>  ▶ Common: 
#>  ✔ categories()
#>  ✔ cities(query, lat = NULL, lon = NULL, city_ids = NULL)
#>  ✔ collections(city_id = NULL, lat = NULL, lon = NULL)
#>  ✔ cuisines(city_id = NULL, lat = NULL, lon = NULL)
#>  ✔ establishments(city_id = NULL, lat = NULL, lon = NULL)
#>  ✔ geocode(lat, lon)
```

``` r
bbb <- zmt$search(query = "Brother Budan Baba Melbourne")
zmt$reviews(res_id = bbb$id[1])
zmt$restaurant(res_id = bbb$id[1])
zmt$dailymenu(res_id = 16507624)

zmt$locations(query = "Melbourne")
zmt$locations(query = "Melbourne", -37.8136, 144.9631)
zmt$location_details(93747, "zone")

zmt$categories()
zmt$cities(query = "Melbourne")
zmt$collections(259)
zmt$cuisines(259)
zmt$establishments(259)
zmt$geocode(-37.8136, 144.9631)
```
