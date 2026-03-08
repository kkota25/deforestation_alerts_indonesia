# scripts/30_regprep/31_scale_units.R
# --------------------------------------------------
# Add scaled-unit variables for interpretability and save *_scaled.parquet
#  - does NOT overwrite original parquet files
#  - appends new columns only if source columns exist (robust across dplyr versions)
# --------------------------------------------------

suppressPackageStartupMessages({
  library(arrow)
  library(dplyr)
  library(rprojroot)
})

# ---------- project paths ----------
proj_root <- rprojroot::find_rstudio_root_file()
dir_proc  <- file.path(proj_root, "data", "processed")

# utilities (write_parquet_safely)
source(file.path(proj_root, "R", "utils_io.R"))

# --------------------------------------------------
# helper: add scaled columns if source columns exist
# --------------------------------------------------
add_scaled_vars <- function(df) {
  # dependent variable scaling
  if ("defor_rate" %in% names(df)) {
    df$defor_rate_pp <- 100 * df$defor_rate
  }
  if ("defor_rate_l1" %in% names(df)) {
    df$defor_rate_l1_pp <- 100 * df$defor_rate_l1
  }
  
  # instrument scaling (cloud share: 10pp units)
  if ("cloud_share" %in% names(df)) {
    df$cloud_share_10pp <- 10 * df$cloud_share
  }
  if ("cloud_share_l1" %in% names(df)) {
    df$cloud_share_l1_10pp <- 10 * df$cloud_share_l1
  }
  
  # controls scaling
  if ("chirps_mm" %in% names(df)) {
    df$chirps_100mm <- df$chirps_mm / 100
  }
  if ("chirps_rainy_mm" %in% names(df)) {
    df$chirps_rainy_100mm <- df$chirps_rainy_mm / 100
  }
  if ("burned_ha" %in% names(df)) {
    df$burned_kha <- df$burned_ha / 1000
  }
  if ("loss_ha" %in% names(df)) {
    df$loss_kha <- df$loss_ha / 1000
  }
  
  df
}

# --------------------------------------------------
# target parquet list (produced by 30_perp_data_reg.R)
# --------------------------------------------------
targets <- c(
  "adm2_reg_2019_2024.parquet",
  "reg_dyn.parquet",
  "reg_dyn_nz.parquet",
  "reg_lag.parquet",
  "reg_dyn_main_islands.parquet",
  "reg_dyn_forest02.parquet",
  "reg_dyn_forest_median.parquet",
  "reg_dyn_frontier_loose.parquet",
  "reg_dyn_frontier_strict.parquet",
  "reg_dyn_frontier_loose_med.parquet",
  "reg_dyn_frontier_strict_med.parquet",
  "dyn_frontier_stats.parquet"
)

paths_in <- file.path(dir_proc, targets)
paths_in <- paths_in[file.exists(paths_in)]

if (length(paths_in) == 0) {
  stop("No target parquet files found in data/processed. Run scripts/30_regprep/30_perp_data_reg.R first.")
}

# --------------------------------------------------
# main loop: read -> scale -> write *_scaled.parquet
# --------------------------------------------------
for (p in paths_in) {
  df <- arrow::read_parquet(p)
  df2 <- add_scaled_vars(df)
  
  out_name <- sub("\\.parquet$", "_scaled.parquet", basename(p))
  out_path <- file.path(dir_proc, out_name)
  
  write_parquet_safely(df2, out_path)
  message("Saved: ", out_path, "  (n=", nrow(df2), ", p=", ncol(df2), ")")
}

message("=== 31_scale_units.R completed successfully ===")