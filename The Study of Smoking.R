library("readr")
library("RColorBrewer")
library("ggplot2")
library("dplyr")
data <- read.csv("C:/Users/47103/OneDrive/桌面/UCLA_First_Year/100/bs100_final_data.csv")
options(digits = 6)

#Section 1B#
ggplot(data, aes(x = smoke)) +
  geom_histogram(binwidth = 1, fill = "blue", color = "black") +
  theme_minimal() +
  labs(title = "Histogram of Cigarette packs Consumed per year",
       x = "Number of Cigarette packs",
       y = "Frequency")

#Section 1D#
ggplot(data, aes(x = health_lit, y = smoke)) + 
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE) + 
  labs(x = "Health Literacy Score", y = "Number of Cigarette pack Consumed per year", 
       title = "Scatter Plot of Health Literacy vs. Smoking") +
  theme_minimal() 

#Section 1E#
data$high_health_lit = ifelse(data$health_lit >= 45, 1, 0)




#Section 2.2#

data$sex <- factor(data$sex, levels = c(0, 1), labels = c("Male", "Female"))
data$pol <- factor(data$pol, levels = c(0, 1), labels = c("Below Poverty Line", "Above Poverty Line"))
data$ins <- factor(data$ins, levels = c(0, 1, 2), labels = c("Public Insurance", "Private Insurance", "Uninsured"))
data$educ <- factor(data$educ, levels = c(0, 1, 2, 3, 4), labels = c("Elementary School", "High School Graduate", "Some College", "College Degree", "Graduate Degree"))


ggplot(data, aes(x = health_lit)) +
  geom_histogram(binwidth = 1, fill = "blue", color = "black") +
  theme_minimal() +
  labs(title = "Histogram of Health Literacy Score",
       x = "Health Literacy Score",
       y = "Frequency")

ggplot(data, aes(x = sex)) +
  geom_bar() +
  theme_minimal() +
  xlab("Sex") +
  ylab("Count") +
  ggtitle("Respondent's Gender Distribution in the Dataset") 


ggplot(data, aes(x = pol)) +
  geom_bar() +
  theme_minimal() +
  xlab("Category") +
  ylab("Count") +
  ggtitle("Respondent's Poverty Distribution in the Dataset")


ggplot(data, aes(x = daily_fol)) +
  geom_histogram(binwidth = 1, fill = "blue", color = "black") +
  theme_minimal() +
  labs(title = "Histogram of Daily Folate Intake",
       x = "Daily Folate Intake(mgs)",
       y = "Frequency")


ggplot(data, aes(x = ins)) +
  geom_bar() +
  theme_minimal() +
  xlab("Category") +
  ylab("Count") +
  ggtitle("Respondent's Insurance Status in the Dataset")


ggplot(data, aes(x = educ)) +
  geom_bar() +
  theme_minimal() +
  xlab("Category") +
  ylab("Count") +
  ggtitle("Respondent's Education Level in the Dataset")


#Section 2.3#

ggplot(data, aes(x = health_lit, y = smoke)) + 
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE) + 
  labs(x = "Health Literacy Score", y = "Number of Cigarette pack Consumed per year", 
       title = "Scatter Plot of Health Literacy vs. Smoking") +
  theme_minimal() 

ggplot(data, aes(x = sex, y = smoke, fill = sex)) +
  geom_boxplot() +
  theme_minimal() +
  xlab("Sex") +
  ylab("Cigarettes Smoked") +
  ggtitle("Comparison of Smoking Habits Between Genders") 


ggplot(data, aes(x = ins, y = smoke, fill = ins)) +
  geom_boxplot() +
  theme_minimal() +
  xlab("Insurance Status") +
  ylab("Cigarettes Smoked") +
  ggtitle("Comparison of Smoking Habits Based on Insurance Status")


ggplot(data, aes(x = daily_fol, y = smoke)) + 
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE) + 
  labs(x = "Daily Folate Intake", y = "Number of Cigarette pack Consumed per year", 
       title = "Scatter Plot of Daily Folate Intake vs. Smoking") +
  theme_minimal() 

ggplot(data, aes(x = ins, y = smoke, fill = ins)) +
  geom_boxplot() +
  theme_minimal() +
  xlab("Insurance Status") +
  ylab("Cigarettes Smoked") +
  ggtitle("Comparison of Smoking Habits Based on Insurance Status")

ggplot(data, aes(x = educ, y = smoke, fill = educ)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  
  xlab("Education Level") +
  ylab("Cigarettes Smoked") +
  ggtitle("Comparison of Smoking Habits Based on Education Level")
















# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


data <- read.csv("C:/Users/47103/OneDrive/桌面/UCLA_First_Year/100/bs100_final_data.csv")

data$high_hlth_lit <- ifelse(data$health_lit >= 45, 1, 0)
data$low_hlth_lit <- ifelse(data$health_lit < 45, 1, 0)



data$literacy_level <- cut(data$health_lit,
                           breaks = c(-Inf, 18.99, 44.99, 60.99, Inf),
                           labels = c("3rd grade and below", "4th to 6th grade", "7th to 8th grade", "High school"),
                           right = FALSE)

data$ins_level <- cut(data$ins,
                    breaks = c(-Inf, 0.5, 1.5, Inf),
                    labels = c("public insurance", "private insurance", "uninsured"),
                    right = FALSE)


data$educ_level <- cut(data$educ,
                     breaks = c(-Inf, 0.5, 1.5, 2.5, 3.5, Inf),
                     labels = c("Elementary school education", "High school graduate",  "Some college", "College degree", "Graduate degree"),
                     right = FALSE)

data$pol_level <- cut(data$pol,
                    breaks = c(-Inf, 0.5, Inf),
                    labels = c("No", "Yes"),
                    right = FALSE)


data$sex_level <- cut(data$sex,
                    breaks = c(-Inf, 0.5, Inf),
                    labels = c("Male", "Female"),
                    right = FALSE)


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 





# Sex 
# Male 559, Female 941
sex_summary <- data %>% 
  group_by(sex_level) %>% 
  summarise(
    Total = n(),
    Percent = (n() / nrow(data)) * 100)
print(sex_summary)

calculate_categorical_stats <- function(data, cat_var) {
  high_stats <- data %>%
    filter(high_hlth_lit == 1) %>%
    group_by(!!sym(cat_var)) %>%
    summarise(
      Total_High = n(),
      Percent_High = (n() / sum(data$high_hlth_lit == 1)) * 100
    )
  
  low_stats <- data %>%
    filter(low_hlth_lit == 1) %>%
    group_by(!!sym(cat_var)) %>%
    summarise(
      Total_Low = n(),
      Percent_Low = (n() / sum(data$low_hlth_lit == 1)) * 100
    )
  
  list(High = high_stats, Low = low_stats)
}
sex_level_stats <- calculate_categorical_stats(data, "sex_level")
print(sex_level_stats$High)
print(sex_level_stats$Low)

# Sex
# Chi_Square P-value
cross_table_sex <- table(data$high_hlth_lit, data$sex_level)
chisq.test(table(data$sex_level, data$high_hlth_lit), correct = FALSE)

# two-proportion z-tests
# for "Female"
female_high_lit <- sum(data$high_hlth_lit[data$sex_level == "Female"] == 1)
female_total <- sum(data$sex_level == "Female")
female_low_lit <- female_total - female_high_lit

z_test_female <- prop.test(x = c(female_high_lit, female_total - female_high_lit), 
                           n = rep(female_total, 2))
print(z_test_female)

# for "Male"
male_high_lit <- sum(data$high_hlth_lit[data$sex_level == "Male"] == 1)
male_total <- sum(data$sex_level == "Male")
male_low_lit <- male_total - male_high_lit

z_test_male <- prop.test(x = c(male_high_lit, male_low_lit),
                         n = c(male_total, male_total))
print(z_test_male)



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 





# Above poverty line      
# below 1072   above 428
pol_summary <- data %>% 
  group_by(pol_level) %>% 
  summarise(
    Total = n(),
    Percent = (n() / nrow(data)) * 100,
    Mean_Pol = mean(pol, na.rm = TRUE),
    SD_Pol = sd(pol, na.rm = TRUE)
  )
print(pol_summary)

calculate_categorical_stats <- function(data, cat_var) {
  high_stats <- data %>%
    filter(high_hlth_lit == 1) %>%
    group_by(!!sym(cat_var)) %>%
    summarise(
      Total_High = n(),
      Percent_High = (n() / sum(data$high_hlth_lit == 1)) * 100
    )
  
  low_stats <- data %>%
    filter(low_hlth_lit == 1) %>%
    group_by(!!sym(cat_var)) %>%
    summarise(
      Total_Low = n(),
      Percent_Low = (n() / sum(data$low_hlth_lit == 1)) * 100
    )
  
  list(High = high_stats, Low = low_stats)
}
pol_level_stats <- calculate_categorical_stats(data, "pol_level")
print(pol_level_stats$High)
print(pol_level_stats$Low)


# Above poverty line  
# P-value
chisq.test(table(data$pol_level, data$high_hlth_lit), correct = FALSE)

# Two-proportion z-test 
# for "No"
no_high_lit <- sum(data$high_hlth_lit[data$pol_level == "No"] == 1)
no_total <- sum(data$pol_level == "No")

z_test_no <- prop.test(x = c(no_high_lit, no_total - no_high_lit), n = c(no_total, no_total))
print(z_test_no)

# for "Yes"
yes_high_lit <- sum(data$high_hlth_lit[data$pol_level == "Yes"] == 1)
yes_total <- sum(data$pol_level == "Yes")

z_test_yes <- prop.test(x = c(yes_high_lit, yes_total - yes_high_lit), n = c(yes_total, yes_total))
print(z_test_yes)





# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 



# Daily Folate
# 702 798


calculate_stats <- function(data, var_name) {
  high_stats <- data %>%
    filter(high_hlth_lit == 1) %>%
    summarise(
      Total_High = n(),
      Percent_High = (n() / nrow(data)) * 100,
      Mean_High = mean(!!sym(var_name), na.rm = TRUE),
      SD_High = sd(!!sym(var_name), na.rm = TRUE)
    )
  
  low_stats <- data %>%
    filter(low_hlth_lit == 1) %>%
    summarise(
      Total_Low = n(),
      Percent_Low = (n() / nrow(data)) * 100,
      Mean_Low = mean(!!sym(var_name), na.rm = TRUE),
      SD_Low = sd(!!sym(var_name), na.rm = TRUE)
    )
  
  list(High = high_stats, Low = low_stats)
}

daily_fol_stats <- calculate_stats(data, "daily_fol")

daily_fol_stats_formatted <- list(
  High = daily_fol_stats$High %>%
    mutate(
      Mean_High = format(Mean_High, nsmall = 6),
      SD_High = format(SD_High, nsmall = 6)
    ),
  Low = daily_fol_stats$Low %>%
    mutate(
      Mean_Low = format(Mean_Low, nsmall = 6),
      SD_Low = format(SD_Low, nsmall = 6)
    )
)

overall_fol_stats <- data %>%
  summarise(
    Mean_Fol = mean(daily_fol, na.rm = TRUE),
    SD_Fol = sd(daily_fol, na.rm = TRUE)
  )
print(overall_fol_stats)
print(daily_fol_stats_formatted$High)
print(daily_fol_stats_formatted$Low)

# Daily Folate
# P-value
t_test_result <- t.test(daily_fol ~ high_hlth_lit, data = data)
print(t_test_result)







# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 






# Insurance 
# public 1125 private 300 uninsured 75
ins_summary <- data %>% 
  group_by(ins_level) %>% 
  summarise(
    Total = n(),
    Percent = (n() / nrow(data)) * 100,
    Mean_Ins = mean(ins, na.rm = TRUE),
    SD_Ins = sd(ins, na.rm = TRUE)
  )
print(ins_summary)

calculate_categorical_stats <- function(data, cat_var) {
  high_stats <- data %>%
    filter(high_hlth_lit == 1) %>%
    group_by(!!sym(cat_var)) %>%
    summarise(
      Total_High = n(),
      Percent_High = (n() / sum(data$high_hlth_lit == 1)) * 100
    )
  
  low_stats <- data %>%
    filter(low_hlth_lit == 1) %>%
    group_by(!!sym(cat_var)) %>%
    summarise(
      Total_Low = n(),
      Percent_Low = (n() / sum(data$low_hlth_lit == 1)) * 100
    )
  
  list(High = high_stats, Low = low_stats)
}
ins_level_stats <- calculate_categorical_stats(data, "ins_level")
print(ins_level_stats$High)
print(ins_level_stats$Low)


# Insurance 
# Chi-square P-value
cross_table_ins <- table(data$high_hlth_lit, data$ins_level)
chi_squared_test_ins <- chisq.test(cross_table_ins)
print(chi_squared_test_ins)

# two-proportion z test P-value
ins_levels <- levels(data$ins_level)
for (level in ins_levels) {
  high_lit_count <- sum(data$high_hlth_lit[data$ins_level == level] == 1)
  total_count <- sum(data$ins_level == level)
  z_test <- prop.test(x = c(high_lit_count, total_count - high_lit_count),
                      n = rep(total_count, 2))
  print(paste("Two-proportion z-test for", level))
  print(z_test)
}



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 





# Education 
# elementary 342 high 643 somecollege 399 college 111 graduate5
educ_summary <- data %>% 
  group_by(educ_level) %>% 
  summarise(
    Total = n(),
    Percent = (n() / nrow(data)) * 100,
    Mean_Educ = mean(educ, na.rm = TRUE),
    SD_Educ = sd(educ, na.rm = TRUE)
  )
print(educ_summary)



calculate_categorical_stats <- function(data, cat_var) {
  high_stats <- data %>%
    filter(high_hlth_lit == 1) %>%
    group_by(!!sym(cat_var)) %>%
    summarise(
      Total_High = n(),
      Percent_High = (n() / sum(data$high_hlth_lit == 1)) * 100
    )
  
  low_stats <- data %>%
    filter(low_hlth_lit == 1) %>%
    group_by(!!sym(cat_var)) %>%
    summarise(
      Total_Low = n(),
      Percent_Low = (n() / sum(data$low_hlth_lit == 1)) * 100
    )
  
  list(High = high_stats, Low = low_stats)
}

educ_level_stats <- calculate_categorical_stats(data, "educ_level")
print(educ_level_stats$High)
print(educ_level_stats$Low)



# Education 
# Chi-Square P-value 
cross_table_educ <- table(data$high_hlth_lit, data$educ_level)
chi_squared_test_educ <- chisq.test(cross_table_educ)
print(chi_squared_test_educ)

# two-proportion z test  P-value 
educ_levels <- levels(data$educ_level)
for (level in educ_levels) {
  high_lit_count <- sum(data$high_hlth_lit[data$educ_level == level] == 1)
  total_count <- sum(data$educ_level == level)
  z_test <- prop.test(x = c(high_lit_count, total_count - high_lit_count),
                      n = rep(total_count, 2))
  print(paste("Two-proportion z-test for", level))
  print(z_test)
}



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 




# HealthOutcome - Smoke

smoke_data <- calculate_stats(data, "smoke")

smoke_data_formatted <- list(
  High = smoke_data$High %>%
    mutate(
      Mean_High = format(Mean_High, nsmall = 6),
      SD_High = format(SD_High, nsmall = 6)
    ),
  Low = smoke_data$Low %>%
    mutate(
      Mean_Low = format(Mean_Low, nsmall = 6),
      SD_Low = format(SD_Low, nsmall = 6)
    )
)

overall_smoke_stats <- data %>%
  summarise(
    Mean_Smoke = mean(smoke, na.rm = TRUE),
    SD_Smoke = sd(smoke, na.rm = TRUE)
  )
print(overall_smoke_stats)
print(smoke_data_formatted$High)
print(smoke_data_formatted$Low)

# HealthOutcome - Smoke
# P-value
t_test_result <- t.test(smoke ~ high_hlth_lit, data = data)
print(t_test_result)


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 



# Table 3.2 Smoke
reg1 <-lm(smoke~ health_lit, data=data)
print(reg1)
summary(reg1)
summary(reg1)$r.squared 








