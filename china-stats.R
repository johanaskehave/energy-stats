

# Settings ----------------------------------------------------------------

# These are our packages. Install a package using the command install.packages("dplyr")
library(rvest) ; library(dplyr) ; library(plotly) ; library(ggplot2) ; library(tidyr) ; library(readxl) ; library(magrittr)


# Get data ----------------------------------------------------------------

# Get table from Wiki
l_table_wiki <- "https://en.wikipedia.org/wiki/Wind_power_in_China" %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="mw-content-text"]/div/table[1]') %>%
  html_table(fill = TRUE)


# Clean data -------------------------------------------------------------

# Transpose table
df_table_wiki <- l_table_wiki[[1]] %>% t() %>% data.frame()

# We just want Capacity (MW)
dd_capacity <- df_table_wiki[-1,1] # I also remove row 1 because it contains just the names and no data
dd_capacity <- as.numeric(gsub(",", "", dd_capacity)) # The values have comma as thousand seperator and is of a class character. We have to fix that.

# Extract Year from table
i_years <- rownames(df_table_wiki)[-1] %>% as.integer() # Again I remove the first value as it contains no data

# Store data in tibble (data frame)
df_data_wiki <- tibble(year = i_years, mw = dd_capacity)


# Create plot -------------------------------------------------------------

p_plotly_wiki <- df_data_wiki %>%
  plot_ly(x = ~year, y = ~mw, type = "bar")


# We can also read your Excel data ----------------------------------------

# Load from Excel
df_data_excel <- read_excel("data/data.xlsx")

# Convert to long format before plotting (the ggplot2 package needs long format)
df_data_excel_long <- df_data_excel %>%
  gather(type, value, -Year)

# This is just the standard plot. You can make the graphs look exactly how you want, just a matter of tweaking the right parameters.
p_ggplot_excel <- ggplot(df_data_excel_long, aes(x=Year, y=value, fill=type)) + 
  geom_area()


# And we can make a simple report with all your data ----------------------

# We don't really need to copy the code three times and have three different
# input files. We could make a function and parse the variables to that function,
# but I'm being lazy here.

# HTML output
rmarkdown::render(input = "china-stats-html.Rmd", output_file = "output/china-stats.html")

# PDF
rmarkdown::render(input = "china-stats-pdf.Rmd", output_file = "output/china-stats.pdf")

# Word
rmarkdown::render(input = "china-stats-word.Rmd", output_file = "output/china-stats.docx")



