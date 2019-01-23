base_url <- "https://developers.zomato.com"
ua <- httr::user_agent("https://github.com/earowang/romato")

#' Query the Zomato API
#'
#' An API key is needed to bridge communication between R and Zomato. You can
#' sign up the key [here](https://developers.zomato.com/api).
#'
#' @section Methods:
#' **Restaurants:**
#' * `dailymenu(res_id)`
#'   - Get daily menu using Zomato restaurant ID.
#' * `restaurant(res_id)`
#'   - Get detailed restaurant information using Zomato restaurant ID.
#' * `reviews(res_id)`
#'   - Get restaurant reviews using the Zomato restaurant ID. Only 5 latest
#'     reviews are available under the Basic API plan.
#' * `search(
#'      query = NULL, lat = NULL, lon = NULL, radius = NULL, cuisines = NULL,
#'      establishment_type = NULL, collection_id = NULL, category = NULL,
#'      sort = NULL, order = NULL
#'    )`
#'   - The location input can be specified using Zomato location ID or coordinates.
#'     cuisine/establishment/ collection IDs can be obtained from respective
#'     api calls.
#'
#'
#' **Location:**
#' * `location_details(entity_id, entity_type)`
#'   - Get Foodie Index, Nightlife Index, Top Cuisines and Best rated
#'     restaurants in a given location
#' * `locations(query, lat = NULL, lon = NULL)`
#'   - Search for Zomato locations by keyword. Provide coordinates to get better
#'     search results.
#'
#' **Common:**
#' * `categories()`
#'   - Get a list of categories. List of all restaurants categorized under a
#'     particular restaurant type can be obtained using /search API with
#;     Category ID as inputs.
#' * `cities(query, lat = NULL, lon = NULL, city_ids = NULL)`
#'   - Find the Zomato ID and other details for a city.
#' * `collections(city_id = NULL, lat = NULL, lon = NULL)`
#'   - Returns Zomato Restaurant Collections in a city.
#' * `cuisines(city_id = NULL, lat = NULL, lon = NULL)`
#'   - Get a list of all cuisines of restaurants listed in a city.
#' * `establishments(city_id = NULL, lat = NULL, lon = NULL)`
#'   - Get a list of restaurant types in a city.
#' * `geocode(lat, lon)`
#'   - Get Foodie and Nightlife Index, list of popular cuisines and nearby
#'     restaurants around the given coordinates.
#'
#' @section Arguments:
#' * `res_id`, `entity_id`, `city_id`: identifiers in integer
#' * `query`: string that you search for
#' * `lat`, `lon`: geo coordinates in double
#' * `entity_type`: string
#' * `sort`: `NULL`, "cost", "rating", "real_distance"
#' * `order`: `NULL`, "asc", "desc"
#' * Parameters without defaults are required to specify.
#'
#' @references <https://developers.zomato.com/documentation>
#'
#' @name zomato
#' @examples
#' \dontrun{
#' zmt <- zomato$new("your-api-key")
#' zmt
#' mugen <- zmt$search(query = "Mugen Ramen & Bar", lat = -37.81, lon = 144.96)
#' zmt$reviews(res_id = mugen$id[1])
#' zmt$restaurant(res_id = mugen$id[1])
#'
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

    search = function(
      query = NULL, entity_id = NULL, entity_type = NULL, lat = NULL, lon = NULL,
      radius = NULL, cuisines = NULL, establishment_type = NULL,
      collection_id = NULL, category = NULL, sort = NULL, order = NULL
    ) {
      lst_df <- lapply(seq(0, 80, by = 20), function(x) {
        resp <- httr::GET(
          url = base_url,
          path = add_path("search"),
          config = httr::add_headers("user-key" = private$api_key),
          query = list(
            q = query, entity_id = entity_id, entity_type = entity_type,
            start = x, count = 20, lat = lat, lon = lon, radius = radius,
            cuisines = cuisines, establishment_type = establishment_type,
            category = category, collection_id = collection_id, sort = sort,
            order = order
          ),
          ua
        )
        parsed <- parse_json(resp)
        handle_error(resp, parsed$message)
        rm_col(parsed$restaurants)
      })
      vec_names <- lapply(lst_df, names)
      null_lst <- vapply(vec_names, is.null, logical(1))
      has_names <- vec_names[!null_lst]
      common_col <- Reduce(intersect, has_names)
      if (is.null(common_col)) {
        stop("No results were found.", call. = FALSE)
      }
      lst_df <- lapply(lst_df[!null_lst], function(x) x[, common_col, drop = FALSE])
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
      triangle <- crayon::make_style("darkgrey")("\u25B6")
      bullet <- crayon::green(crayon::bold("\u2022"))
      search <- "search(
     query = NULL, entity_id = NULL, entity_type = NULL, lat = NULL, lon = NULL,
     radius = NULL, cuisines = NULL, establishment_type = NULL,
     collection_id = NULL, category = NULL, sort = NULL, order = NULL
   )\n"
      cat(
        crayon::red(crayon::bold("<Zomato API>")), "\n",
        triangle, crayon::bold("Restaurants:"), "\n",
        bullet, "dailymenu(res_id)\n",
        bullet, "restaurant(res_id)\n",
        bullet, "reviews(res_id)\n",
        bullet, search,
        triangle, crayon::bold("Location:"), "\n",
        bullet, "location_details(entity_id, entity_type)\n",
        bullet, "locations(query, lat = NULL, lon = NULL)\n",
        triangle, crayon::bold("Common:"), "\n",
        bullet, "categories()\n",
        bullet, "cities(query, lat = NULL, lon = NULL, city_ids = NULL)\n",
        bullet, "collections(city_id = NULL, lat = NULL, lon = NULL)\n",
        bullet, "cuisines(city_id = NULL, lat = NULL, lon = NULL)\n",
        bullet, "establishments(city_id = NULL, lat = NULL, lon = NULL)\n",
        bullet, "geocode(lat, lon)"
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
