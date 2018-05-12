# passed to httr::modify_url()
add_path <- function(path) {
  paste0("/api/v2.1/", path)
}

# if api key or query is valid
handle_error <- function(x, msg) {
  if (httr::http_error(x)) {
    stop(
      sprintf(
        "Zomato API request failed [%s]\n%s",
        httr::status_code(x),
        msg
      ),
      call. = FALSE
    )
  }
}

# if api key is provided
is_key_null <- function(x = NULL) {
  if (is.null(x)) {
    stop("\nPlease provide an API key.\nYou can request it here\nhttps://developers.zomato.com/api")
  }
}
