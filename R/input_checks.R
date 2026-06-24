# Internal validation helpers — not exported.
# Each function throws an informative error or returns invisibly.

#' @noRd
check_model <- function(model) {
  if (
    !is.numeric(model) ||
      length(model) != 1 ||
      model != as.integer(model) ||
      !(model %in% 1:4)
  ) {
    stop("`model` must be a single integer between 1 and 4.", call. = FALSE)
  }
  invisible(NULL)
}

#' @noRd
check_n.boots <- function(n.boots) {
  if (
    !is.numeric(n.boots) ||
      length(n.boots) != 1 ||
      n.boots != as.integer(n.boots) ||
      n.boots < 100
  ) {
    stop(
      "`n.boots` must be an integer larger than or equal to 100.",
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' @noRd
check_reg_par <- function(reg_par) {
  reg_par <- as.matrix(reg_par)

  if (!is.numeric(reg_par) || !all(is.finite(reg_par))) {
    stop("`reg_par` must contain finite numeric values.", call. = FALSE)
  }

  if (nrow(reg_par) != 1 || ncol(reg_par) != 5) {
    stop("`reg_par` must have exactly 1 row and 5 columns.", call. = FALSE)
  }

  as.numeric(reg_par) # return coerced value for assignment
}

#' @noRd
check_site_par <- function(site_par) {
  site_par <- as.matrix(site_par)

  if (!is.numeric(site_par)) {
    stop("`site_par` must be numeric.", call. = FALSE)
  }

  if (nrow(site_par) != 1 || ncol(site_par) != 5) {
    stop("`site_par` must have exactly 1 row and 5 columns.", call. = FALSE)
  }

  if (!all(is.finite(site_par))) {
    stop("`site_par` cannot contain missing or infinite values.", call. = FALSE)
  }

  as.numeric(site_par)
}

#' @noRd
check_atsite_temp <- function(atsite_temp) {
  data_site <- as.matrix(atsite_temp)

  if (!is.numeric(data_site)) {
    stop("`atsite_temp` must be numeric.", call. = FALSE)
  }

  if (ncol(data_site) != 1) {
    stop(
      "`atsite_temp` must be a vector or single-column matrix.",
      call. = FALSE
    )
  }

  if (all(is.na(data_site))) {
    stop("`atsite_temp` contains only missing values.", call. = FALSE)
  }

  if (sum(!is.na(data_site)) < 10) {
    stop("Site must have at least 10 years of records.", call. = FALSE)
  }

  na.omit(as.numeric(data_site)) # return cleaned vector for assignment
}

#' @noRd
check_add_data <- function(add_data) {
  if (!is.numeric(add_data)) {
    stop("`add_data` must be numeric.", call. = FALSE)
  }

  add_data <- as.matrix(add_data)

  if (length(add_data) == 0) {
    stop("`add_data` cannot be empty.", call. = FALSE)
  }

  if (ncol(add_data) < 3) {
    stop("The number of sites must be larger than 2.", call. = FALSE)
  }

  if (nrow(add_data) < 10) {
    stop("`add_data` must contain at least 10 observations.", call. = FALSE)
  }

  if (min(colSums(!is.na(add_data))) < 10) {
    stop("All sites must have at least 10 years of records.", call. = FALSE)
  }

  add_data # return coerced matrix for assignment
}

#' @noRd
check_scale_positive <- function(par.temporal) {
  if (any(par.temporal[, 2] <= 0)) {
    stop("The scale parameter becomes non-positive over time.", call. = FALSE)
  }
  invisible(NULL)
}
