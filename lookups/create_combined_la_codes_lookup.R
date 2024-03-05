Hackney_CoL <- c("E09000012", "E09000001")
Hackney_CoL_name <- "Hackney and City of London"
Cornwall_Scilly <- c("E06000052", "E06000053")
Cornwall_Scilly_name <- "Cornwall and Isles of Scilly"

lookup <- data.frame(gss_code = c(Hackney_CoL,
                                  Cornwall_Scilly),
                 combined_gss = c(rep(paste(Hackney_CoL, collapse = ", "), 2),
                                  rep(paste(Cornwall_Scilly, collapse = ", "), 2)),
                combined_name = c(rep(Hackney_CoL_name, 2),
                                  rep(Cornwall_Scilly_name, 2))
)

saveRDS(lookup, file = "lookups/combined_la_codes_lookup.rds")
