
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

First of all, you need an API key to access Zomato, which you can sign up [here](https://developers.zomato.com/api).

``` r
library(romato)
zmt <- zomato$new(api_key = "your-api-key")
zmt
#> <Zomato API> 
#>  Restaurants: 
#>  1. dailymenu(res_id)
#>  2. restaurant(res_id)
#>  3. reviews(res_id)
#>  4. search(query, lat = NULL, lon = NULL, sort = NULL, order = NULL)
#>  Location: 
#>  1. location_details(query, lat = NULL, lon = NULL)
#>  2. locations(entity_id, entity_type)
#>  Common: 
#>  1. categories()
#>  2. cities(query, lat = NULL, lon = NULL, city_ids = NULL)
#>  3. collections(city_id = NULL, lat = NULL, lon = NULL)
#>  4. cuisines(city_id = NULL, lat = NULL, lon = NULL)
#>  5. establishments(city_id = NULL, lat = NULL, lon = NULL)
#>  6. geocode(lat, lon)
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
