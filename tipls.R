estimate_TIPLS <- function(y, blocks) {
  k <- length(blocks)
  
  # Combine all blocks for full model
  X_full <- do.call(cbind, blocks)
  
  # Step 1: Full model OLS for intercept and total SE
  full_model <- lm(y ~ X_full)
  alpha_hat <- coef(full_model)[1]
  alpha_se  <- summary(full_model)$coefficients[1, 2]
  
  # Step 2: Initialize residuals to y
  y_res <- y
  
  # Storage for results
  beta_hats <- list()
  beta_ses  <- list()
  residuals_list <- list()
  t_stats <- list()
  beta_r2s <- list()
  
  for (b in 1:k) {
    # Step 3: Regress current residuals on current block
    block_model <- lm(y_res ~ blocks[[b]])
    beta_hat <- coef(block_model)[-1]  # exclude intercept
    beta_se  <- summary(block_model)$coefficients[-1, 2]  # exclude intercept SE
    eps_hat  <- residuals(block_model)
    tstats <- summary(block_model)$coefficients[,3][-1]
    beta_r2 <- 1 - var(eps_hat)/var(y)
    
    # Store estimates
    beta_hats[[b]] <- beta_hat
    beta_ses[[b]]  <- beta_se
    residuals_list[[b]] <- eps_hat
    t_stats[[b]] <- tstats
    beta_r2s[[b]] <- beta_r2
    
    # Pass residuals to next block
    y_res <- eps_hat
  }
  # Optional: Final R² (variance explained)
  R2 <- 1 - (var(y_res) / var(y))
  r2_delta <- unlist(beta_r2s)
  r2_out <- c(r2_delta[1], diff(r2_delta))
  # Return results
  return(list(
    alpha_hat = alpha_hat,
    alpha_se  = alpha_se,
    beta_hats = beta_hats,
    beta_ses  = beta_ses,
    final_residuals = y_res,
    tstat_out = t_stats,
    r2 = r2_out,
    R2 = R2
  ))
}