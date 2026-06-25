#' @noRd
check_matrix_or_df <- function(x, arg_name) {
  if (!is.matrix(x) && !is.data.frame(x)) {
    stop(
      sprintf("Input '%s' must be a matrix or data frame.", arg_name),
      call. = FALSE
    )
  }
  as.matrix(x)
}

#' @noRd
check_min_site_records <- function(data, min_n = 10L) {
  if (min(colSums(!is.na(data))) < min_n) {
    stop("All sites must have at least 10 observations.", call. = FALSE)
  }
  invisible(NULL)
}

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
  as.numeric(reg_par)
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

  if (ncol(data_site) != 1) {
    stop(
      "`atsite_temp` must be a vector or single-column matrix.",
      call. = FALSE
    )
  }

  if (all(is.na(data_site))) {
    stop("`atsite_temp` contains only missing values.", call. = FALSE)
  }

  if (!is.numeric(data_site)) {
    stop("`atsite_temp` must be numeric.", call. = FALSE)
  }

  if (sum(!is.na(data_site)) < 10) {
    stop("Site must have at least 10 years of records.", call. = FALSE)
  }

  na.omit(as.numeric(data_site))
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
  check_min_site_records(add_data)
  add_data
}


#' @noRd
check_dataset <- function(dataset) {
  dataset <- check_matrix_or_df(dataset, "dataset")
  if (anyNA(dataset[, 1])) {
    stop("Column 'Years' cannot have missing data.", call. = FALSE)
  }
  data_sites <- dataset[, -1, drop = FALSE]
  if (ncol(data_sites) < 3L) {
    stop("The number of sites should be larger than 2.", call. = FALSE)
  }
  check_min_site_records(data_sites)
  data_sites
}


#' @noRd
check_best_model_df <- function(best_model) {
  if (!is.data.frame(best_model)) {
    stop("Input 'best_model' must be a data frame.", call. = FALSE)
  }

  required_cols <- c("mu0", "mu1", "sigma0", "sigma1", "shape", "size")

  if (!all(required_cols %in% names(best_model))) {
    stop(
      "Input 'best_model' must contain the columns: ",
      toString(required_cols),
      ".",
      call. = FALSE
    )
  }

  if (!all(vapply(best_model[required_cols], is.numeric, logical(1)))) {
    stop("All columns in 'best_model' must be numeric.", call. = FALSE)
  }

  if (!all(is.finite(best_model$size)) || any(best_model$size < 0)) {
    stop(
      "The 'size' column must contain finite non-negative values.",
      call. = FALSE
    )
  }

  if (sum(best_model$size) == 0) {
    stop(
      "The sum of the 'size' column must be greater than zero.",
      call. = FALSE
    )
  }

  invisible(NULL)
}


#' @noRd
check_quantiles <- function(quantiles) {
  if (!is.numeric(quantiles) || !all(is.finite(quantiles))) {
    stop(
      "`quantiles` must be a numeric vector with no missing values.",
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' @noRd
check_site_temp <- function(site_temp) {
  if (
    !is.numeric(site_temp) ||
      length(site_temp) == 0 ||
      !all(is.finite(site_temp))
  ) {
    stop(
      "`site_temp` must be a non-empty numeric vector or 1-column matrix.",
      call. = FALSE
    )
  }
  invisible(NULL)
}


#' @noRd
check_n.year <- function(n.year, site_temp) {
  if (!is.numeric(n.year) || length(n.year) != 1) {
    stop("`n.year` must be a single numeric value.", call. = FALSE)
  }

  if (n.year != as.integer(n.year)) {
    stop("`n.year` must be a whole number.", call. = FALSE)
  }

  if (n.year < 1 || n.year > length(site_temp)) {
    stop(
      "`n.year` must be between 1 and length(`site_temp`).",
      call. = FALSE
    )
  }

  invisible(NULL)
}


check_prob <- function(prob) {
  if (
    !is.numeric(prob) ||
      !all(is.finite(prob)) ||
      any(prob <= 0) ||
      any(prob >= 1)
  ) {
    stop(
      "`prob` must be a numeric vector with values strictly between 0 and 1
      and no missing data.",
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' @noRd
check_heterogeneity_data <- function(dataset.add) {
  if (!is.matrix(dataset.add) && !is.data.frame(dataset.add)) {
    stop("'dataset.add' must be a matrix or data frame.", call. = FALSE)
  }

  dataset.add <- as.matrix(dataset.add)

  if (ncol(dataset.add) < 3) {
    stop(
      "The number of sites should be equal to or larger than 3.",
      call. = FALSE
    )
  }

  check_min_site_records(dataset.add)

  dataset.add
}


check_rho <- function(rho) {
  if (!is.numeric(rho) || length(rho) != 1 || rho >= 1 || rho <= -1) {
    stop(
      "'rho' must be a single numeric value strictly between -1 and 1.",
      call. = FALSE
    )
  }
  invisible(NULL)
}

check_Ns <- function(Ns) {
  if (!is.numeric(Ns) || length(Ns) != 1 || Ns != as.integer(Ns) || Ns < 100) {
    stop("Ns should be larger than 99.", call. = FALSE)
  }
  invisible(NULL)
}
