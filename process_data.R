library(tidyverse)
library(magrittr)


###### Define Columns to Keep

keep_cols <- c(
  "LIBNAME",
  "Period_ID",
  "VISITS",
  "POPU_LSA",
  "PHMATCIR",
  "ELMATCIR",
  "TOT_PHYS",
  "ELECCOLL",
  "PITUSR",
  "WIFISESS",
  "TOTATTEN",
  "LOCEXP",
  "TOTEXP",
  "TOTEXPCO",
  "TOTSTAFF",
  "TOTPRO"
)

# From the Combine PLS Data.R file
df <- read.csv(
  "data/PLS_ALL_YEARS.csv"
) %>%
  select(LIBNAME, Period_ID, all_of(keep_cols))

unique(df$Period_ID) # make sure all of the years are in there!

df[df == "-1"] <- NA
df[df == "-3"] <- NA

df_sm <- df %>%
  filter(
    Period_ID %in%
      c(max(as.numeric(Period_ID)):(max(as.numeric(Period_ID)) - 9)),
    !str_detect(
      LIBNAME,
      "BOOKMOBILE|STANSBURY|Stansbury|Kaysville|Garfield County|GARDEN|Cache|CACHE COUNTY|Alpine Library|EXAMPLE|FAIRVIEW"
    )
  ) %>%
  mutate(
    LIBNAME = ifelse(LIBNAME == "HYRUM CITY LIBRARY", "HYRUM LIBRARY", LIBNAME),
    LIBNAME = ifelse(
      LIBNAME == "DUCHESNE COUNTY LIBRARY",
      "DUCHESNE COUNTY LIBRARY SYSTEM",
      LIBNAME
    ),
    LIBNAME = str_to_title(LIBNAME)
  ) %>%
  mutate(across(c(VISITS:TOTPRO), ~ as.numeric(.))) %>%
  group_by(LIBNAME, Period_ID) %>%
  summarise(
    POPU_LSA,
    b1_visits_per_cap = VISITS / POPU_LSA,
    b2_physmatcir_per_cap = PHMATCIR / POPU_LSA,
    b3_elmatcir_per_cap = ELMATCIR / POPU_LSA,
    b4_physmat_turnover_NOT_per_cap = PHMATCIR / TOT_PHYS, ## Doing "NOT" because this is not actually per capita
    b5_elmat_turnover_NOT_per_cap = ELMATCIR / ELECCOLL,
    b6_internet_term_per_cap = PITUSR / POPU_LSA,
    b7_wifi_per_cap = WIFISESS / POPU_LSA,
    b8_attend_per_cap = TOTATTEN / POPU_LSA,
    b9_loc_op_exp_per_cap = LOCEXP / POPU_LSA,
    b10_pct_budget_coll_NOT_per_cap = (TOTEXPCO / TOTEXP) * 100,
    b11_FTE_per_cap = TOTSTAFF / POPU_LSA,
    b12_n_program_per_cap = TOTPRO / POPU_LSA,

    b1_act_n = VISITS,
    b2_act_n = PHMATCIR,
    b3_act_n = ELMATCIR,
    b4_act_n = round(PHMATCIR / TOT_PHYS, 2),
    b5_act_n = round(ELMATCIR / ELECCOLL, 2),
    b6_act_n = PITUSR,
    b7_act_n = WIFISESS,
    b8_act_n = TOTATTEN,
    b9_act_n = LOCEXP,
    b10_act_n = round((TOTEXPCO / TOTEXP) * 100, 2),
    b11_act_n = TOTSTAFF,
    b12_act_n = TOTPRO,

    b1_act_viz = format(VISITS, big.mark = ","),
    b2_act_viz = format(PHMATCIR, big.mark = ","),
    b3_act_viz = format(ELMATCIR, big.mark = ","),
    b4_act_viz = format(round(PHMATCIR / TOT_PHYS, 2), big.mark = ","),
    b5_act_viz = format(round(ELMATCIR / ELECCOLL, 2), big.mark = ","),
    b6_act_viz = format(PITUSR, big.mark = ","),
    b7_act_viz = format(WIFISESS, big.mark = ","),
    b8_act_viz = format(TOTATTEN, big.mark = ","),
    b9_act_viz = paste0("$", format(LOCEXP, big.mark = ",")),
    b10_act_viz = paste0(round((TOTEXPCO / TOTEXP) * 100, 2), "%"),
    b11_act_viz = format(TOTSTAFF, big.mark = ","),
    b12_act_viz = format(TOTPRO, big.mark = ","),

    b1_visits_pc_viz = format(round(VISITS / POPU_LSA, 2), big.mark = ","),
    b2_physmatcir_pc_viz = format(
      round(PHMATCIR / POPU_LSA, 2),
      big.mark = ","
    ),
    b3_elmatcir_pc_viz = format(round(ELMATCIR / POPU_LSA, 2), big.mark = ","),
    b4_physmat_turnover_NOT_pc_viz = format(
      round(PHMATCIR / TOT_PHYS, 2),
      big.mark = ","
    ), ## Doing "NOT" because this is not actually per capita
    b5_elmat_turnover_NOT_pc_viz = format(
      round(ELMATCIR / ELECCOLL, 2),
      big.mark = ","
    ),
    b6_internet_term_pc_viz = format(
      round(PITUSR / POPU_LSA, 2),
      big.mark = ","
    ),
    b7_wifi_pc_viz = format(round(WIFISESS / POPU_LSA, 2), big.mark = ","),
    b8_attend_pc_viz = format(round(TOTATTEN / POPU_LSA, 2), big.mark = ","),
    b9_loc_op_exp_pc_viz = paste0(
      "$",
      format(round(LOCEXP / POPU_LSA, 2), big.mark = ",")
    ),
    b10_pct_budget_coll_NOT_pc_viz = paste0(
      round((TOTEXPCO / TOTEXP) * 100, 2),
      "%"
    ),
    b11_FTE_pc_viz = format(round(TOTSTAFF / POPU_LSA, 6), big.mark = ","),
    b12_n_program_pc_viz = format(round(TOTPRO / POPU_LSA, 4), big.mark = ",")
  )

df_pctl <- df_sm %>%
  group_by(Period_ID) %>%
  mutate(
    LIBNAME,
    POPU_LSA = format(POPU_LSA, big.mark = ","),
    b1_pctl = percent_rank(b1_visits_per_cap),
    b2_pctl = percent_rank(b2_physmatcir_per_cap),
    b3_pctl = percent_rank(b3_elmatcir_per_cap),
    b4_pctl = percent_rank(b4_physmat_turnover_NOT_per_cap),
    b5_pctl = percent_rank(b5_elmat_turnover_NOT_per_cap),
    b6_pctl = percent_rank(b6_internet_term_per_cap),
    b7_pctl = percent_rank(b7_wifi_per_cap),
    b8_pctl = percent_rank(b8_attend_per_cap),
    b9_pctl = percent_rank(b9_loc_op_exp_per_cap),
    b10_pctl = percent_rank(b10_pct_budget_coll_NOT_per_cap),
    b11_pctl = percent_rank(b11_FTE_per_cap),
    b12_pctl = percent_rank(b12_n_program_per_cap)
  )

write.csv(df_pctl, "data/df_pctl.csv", row.names = FALSE)
