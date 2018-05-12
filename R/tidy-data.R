globalVariables("timestamp")

# remove some columns (e.g. links to zomato review)
rm_col <- function(data) {
  cn <- names(data)
  rm_col <- "apikey|url|link|thumb|featured_image|zomato_events|R.res_id|custom|profile_image"
  data[!grepl(rm_col, cn)]
}

tidy_search <- function(data) {
  names(data) <- gsub("restaurant.|location.|user_rating.", "", names(data))
  data
}

tidy_reviews <- function(data) {
  names(data) <- gsub("user.|review.", "", names(data))
  transform(data, timestamp = as.POSIXct(timestamp, origin = "1970-01-01"))
}

tidy_dailymenu <- function(data) {
  names(data) <- gsub("daily_menu.", "", names(data))
  data
}

tidy_collections <- function(data) {
  names(data) <- gsub("collection.", "", names(data))
  data
}

tidy_cuisines <- function(data) {
  names(data) <- gsub("cuisine.", "", names(data))
  data
}
