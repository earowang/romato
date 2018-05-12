base_url <- "https://developers.zomato.com"
ua <- httr::user_agent("https://github.com/earowang/romato")

#' Zomato API
#' 
#' An API key is needed to bridge communication between R and Zomato. You can
#' sign up the key [here](https://developers.zomato.com/api).
#'
#' @section Methods:
#' **Restaurants:**
#' 1. dailymenu(res_id)
#' 2. restaurant(res_id)
#' 3. reviews(res_id)
#' 4. search(query, lat = NULL, lon = NULL, sort = NULL, order = NULL)
#'
#' **Location:**
#' 1. location_details(query, lat = NULL, lon = NULL)
#' 2. locations(entity_id, entity_type)
#'
#' **Common:**
#' 1. categories()
#' 2. cities(query, lat = NULL, lon = NULL, city_ids = NULL)
#' 3. collections(city_id = NULL, lat = NULL, lon = NULL)
#' 4. cuisines(city_id = NULL, lat = NULL, lon = NULL)
#' 5. establishments(city_id = NULL, lat = NULL, lon = NULL)
#' 6. geocode(lat, lon)
#'
#' @name zomato
#' @examples
#' \dontrun{
#' zmt <- zomato$new("your-api-key")
#' zmt
#' bbb <- zmt$search(query = "Brother Budan Baba Melbourne")
#' zmt$reviews(res_id = bbb$id[1])
#' zmt$restaurant(res_id = bbb$id[1])
#' zmt$dailymenu(res_id = 16507624)
#' 
#' zmt$locations(query = "Melbourne")
#' zmt$locations(query = "Melbourne", -37.8136, 144.9631)
#' zmt$location_details(93747, "zone")
#' 
#' zmt$categories()
#' zmt$cities(query = "Melbourne")
#' zmt$collections(259)
#' zmt$cuisines(259)
#' zmt$establishments(259)
#' zmt$geocode(-37.8136, 144.9631)
#' }
NULL

#' @export
zomato <- R6::R6Class(
  "Zomato",
  private = list(
    api_key = NULL
  ),

  public = list(
    initialize = function(api_key = NULL) {
      is_key_null(api_key)
      private$api_key <- api_key
    },

    search = function(query, lat = NULL, lon = NULL, sort = NULL, order = NULL) {
      lst_df <- lapply(seq(0, 80, by = 20), function(x) {
        resp <- httr::GET(
          url = base_url,
          path = add_path("search"),
          config = httr::add_headers("user-key" = private$api_key),
          query = list(
            q = query, start = x, count = 20,
            lat = lat, lon = lon,
            sort = sort, order = order
          ),
          ua
        )
        parsed <- parse_json(resp)
        handle_error(resp, parsed$message)
        rm_col(parsed$restaurants)
      })
      df <- do.call("rbind", lst_df)
      tidy_search(df)
    },

    reviews = function(res_id) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("reviews"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(res_id = res_id),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      tidy_reviews(rm_col(parsed$user_reviews))
    },

    restaurant = function(res_id) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("restaurant"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(res_id = res_id),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      as.data.frame(tidy_search(rm_col(unlist(parsed, recursive = FALSE))))
    },

    dailymenu = function(res_id) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("dailymenu"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(res_id = res_id),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      tidy_dailymenu(parsed$daily_menus)
    },

    locations = function(query, lat = NULL, lon = NULL) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("locations"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(q = query, lat = lat, lon = lon),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      parsed$location_suggestions
    },

    location_details = function(entity_id, entity_type) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("location_details"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(entity_id = entity_id, entity_type = entity_type),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      tidy_search(rm_col(parsed$best_rated_restaurant))
    },

    categories = function() {
      resp <- httr::GET(
        url = base_url,
        path = add_path("categories"),
        config = httr::add_headers("user-key" = private$api_key),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      parsed$categories
    },

    cities = function(query, lat = NULL, lon = NULL, city_ids = NULL) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("cities"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(q = query, lat = lat, lon = lon, city_ids = city_ids),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      rm_col(parsed$location_suggestions)
    },

    collections = function(city_id = NULL, lat = NULL, lon = NULL) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("collections"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(city_id = city_id, lat = lat, lon = lon),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      tidy_collections(rm_col(parsed$collections))
    },

    cuisines = function(city_id = NULL, lat = NULL, lon = NULL) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("cuisines"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(city_id = city_id, lat = lat, lon = lon),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      tidy_cuisines(parsed$cuisines)
    },

    establishments = function(city_id = NULL, lat = NULL, lon = NULL) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("establishments"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(city_id = city_id, lat = lat, lon = lon),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      parsed$establishments
    },

    geocode = function(lat, lon) {
      resp <- httr::GET(
        url = base_url,
        path = add_path("geocode"),
        config = httr::add_headers("user-key" = private$api_key),
        query = list(lat = lat, lon = lon),
        ua
      )
      parsed <- parse_json(resp)
      handle_error(resp, parsed$message)
      list(
        location = as.data.frame(parsed$location),
        popularity = parsed$popularity,
        nearby_restaurants = tidy_search(rm_col(parsed$nearby_restaurants))
      )
    },

    print = function(...) {
      cat(
        crayon::red("<Zomato API>"), "\n",
        crayon::bold("Restaurants:"), "\n",
        "1. dailymenu(res_id)\n",
        "2. restaurant(res_id)\n",
        "3. reviews(res_id)\n",
        "4. search(query, lat = NULL, lon = NULL, sort = NULL, order = NULL)\n",
        crayon::bold("Location:"), "\n",
        "1. location_details(query, lat = NULL, lon = NULL)\n",
        "2. locations(entity_id, entity_type)\n",
        crayon::bold("Common:"), "\n",
        "1. categories()\n",
        "2. cities(query, lat = NULL, lon = NULL, city_ids = NULL)\n",
        "3. collections(city_id = NULL, lat = NULL, lon = NULL)\n",
        "4. cuisines(city_id = NULL, lat = NULL, lon = NULL)\n",
        "5. establishments(city_id = NULL, lat = NULL, lon = NULL)\n",
        "6. geocode(lat, lon)"
      )
    }
  )
)

parse_json <- function(response) {
  jsonlite::fromJSON(
    httr::content(
      response, as = "text", type = "application/json", encoding = "UTF-8"
    ),
    flatten = TRUE
  )
}
