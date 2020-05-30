list.of.packages <- c("shiny", "rvest", "stringr", "tidyverse", "stringdist")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(shiny)
library(rvest)
library(stringr)
library(tidyverse)
library(stringdist)
options(warn = 0)

drug_list_url <- "https://bnf.nice.org.uk/drug/"
drugpage <- read_html(drug_list_url)
drugs <- html_text(html_nodes(drugpage, 'span'))
drugs <- drugs[3:length(drugs)]
drugs <- tolower(drugs)
drugs <- str_replace_all(drugs, " ", "-")
drugs <- str_replace_all(drugs, ",", "")
drugs <- str_replace_all(drugs, "é", "e")
drugs <- str_replace(drugs, "\\(", "")
drugs <- str_replace(drugs, "\\)", "")
drugs <- str_replace(drugs, "'", "")
drugs <- str_replace_all(drugs, "d-(rh0)-", "d-rh0-")
drugs <- sub("noradrenaline/norepinephrine", "noradrenalinenorepinephrine", drugs)
drugs <- str_replace(drugs, "enaline/epinephr", "enalineepinephr")
drugs <- sub("-$", "", drugs)
drugs <- drugs[-c(87, 134:137, 163, 216, 236, 1628, 1629)]

url <- "https://bnf.nice.org.uk/medicinal-forms/anastrozole.html"
webpage <- read_html(url)

#Using CSS selectors to scrape the desired information
name <- html_nodes(webpage,'span.strengthOfActiveIngredient')
size <- html_nodes(webpage, 'td.packSize')
price <- html_nodes(webpage, 'td.nhsIndicativePrice')

#Converting the ranking data to text
name <- html_text(name)
size <- html_text(size)
price <- html_text(price)

# Check the extraction is works

name1 <- unlist(strsplit(name, "<"))
price <- unlist(strsplit(price, "\n                            "))
price1 <- price[seq(2, length(price), 3)]

z <- cbind(name1, size, price1)
progress <- 0

for(i in drugs){
    progress <- progress+1
    print(paste(round(progress/length(drugs)*100, digits = 1), "%", sep = ""))
    print("Once the program reaches 100% (eta 3mins), the data will be ready to download!")
    url <- paste("https://bnf.nice.org.uk/medicinal-forms/", i, ".html", sep = "")
    webpage <- read_html(url)

    #Using CSS selectors to scrape the desired information
    name <- html_nodes(webpage,'span.strengthOfActiveIngredient')
    size <- html_nodes(webpage, 'td.packSize')
    price <- html_nodes(webpage, 'td.nhsIndicativePrice')


    #Converting the ranking data to text
    name1 <- html_text(name)
    size1 <- html_text(size)
    price1 <- html_text(price)

    if(length(name)!=0){

        name1 <- unlist(strsplit(name1, "<"))
        price1 <- unlist(strsplit(price1, "\n                            "))
        price1 <- price1[seq(2, length(price1), 3)]


        z1 <- cbind(name1, size1, price1)
        z <- rbind(z, z1)
    }
}

# Choosing the lowest price for every given active ingredient

BNF <- as.data.frame(z)
BNF <- BNF %>%
    rename(ActiveIngredients = "name1", Size = "size", Price = "price1") %>%
    mutate(Price = as.character(Price)) %>%
    mutate(Price = str_replace(Price, "£", "")) %>%
    mutate(Price = as.numeric(Price)) %>%
    mutate(ActiveIngredients = as.character(ActiveIngredients)) %>%
    select(ActiveIngredients, Size, Price)

code <- seq(1:length(BNF$ActiveIngredients))
code <- paste("A", code, sep = "")
BNF <- BNF %>%
    add_column(Code = code, .before = "ActiveIngredients") %>%
    mutate(Dose = parse_number(ActiveIngredients)) %>%
    mutate(Dose_Type = ifelse(str_detect(ActiveIngredients, "mg"), "mg", NA)) %>%
    mutate(Dose_Type = ifelse(str_detect(ActiveIngredients, "microgram"), "microgram", Dose_Type)) %>%
    mutate(Dose_Type = ifelse(str_detect(ActiveIngredients, " gram"), "gram", Dose_Type))



BNF_min <- BNF %>%
    group_by(ActiveIngredients) %>%
    slice(which.min(Price)) %>%
    mutate(Dose = parse_number(ActiveIngredients)) %>%
    mutate(Dose_Type = ifelse(str_detect(ActiveIngredients, "mg"), "mg", NA)) %>%
    mutate(Dose_Type = ifelse(str_detect(ActiveIngredients, "microgram"), "microgram", Dose_Type)) %>%
    mutate(Dose_Type = ifelse(str_detect(ActiveIngredients, " gram"), "gram", Dose_Type))

ui <- fluidPage(
    titlePanel('BNF Download'),
    sidebarLayout(
        sidebarPanel(
            selectInput("dataset", "Choose a dataset:",
                        choices = c("BNF", "BNF minimum prices")),
            radioButtons("filetype", "File type:",
                         choices = c("csv")),
            downloadButton('downloadData', 'Download')
        ),
        mainPanel(
          img(src='NU_logo.png', align = "right"),
          tableOutput("table")
    )
  )
)

server <- function(input, output) {

    ### INPUT WEBSCRAPE CODE



    ### SHINY CONTINUE


    datasetInput <- reactive({
        # Fetch the appropriate data object, depending on the value
        # of input$dataset.
        switch(input$dataset,
               "BNF" = BNF,
               "BNF minimum prices" = BNF_min)
    })

    output$table <- renderTable({
        datasetInput()
    })

    # downloadHandler() takes two arguments, both functions.
    # The content function is passed a filename as an argument, and
    #   it should write out data to that filename.
    output$downloadData <- downloadHandler(

        # This function returns a string which tells the client
        # browser what name to use when saving the file.
        filename = function() {
            paste(input$dataset, input$filetype, sep = ".")
        },

        # This function should write data to a file given to it by
        # the argument 'file'.
        content = function(file) {
            sep <- switch(input$filetype, "csv" = ",", "tsv" = "\t")

            # Write to a file specified by the 'file' argument
            write.table(datasetInput(), file, sep = sep,
                        row.names = FALSE)
        }
    )
}

# RUN
# Run the application
shinyApp(ui = ui, server = server)
