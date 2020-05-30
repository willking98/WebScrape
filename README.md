# BNF WebScraping

This program extracts information from the British National Formulary (BNF) to aid cleaning and pricing medications reported in clinical trials.
The BNF website allows the researcher to receive the most up to date pricing information on any given medication licensed in the UK. As medication prices change constantly, it is important to have this information online so that it can be readily updated.

The aim of this program is to complement the BNF and allow researchers to extract various information from the BNF and format this in one dataset. Running this program prevents a researcher searching the BNF website each time medication information is required.

To run this program simply copy and paste the following code into your R console:

```{r, eval=FALSE}
library(shiny)
runGitHub("WebScrape", "willking98")
```

Once the program has finished extracting the BNF data, you will have the option to download various forms of the dataset.

* BNF - complete dataset of every drug listed on the BNF
* BNF minimum prices - dataset of each drug listed on the BNF but where two providers offer an identical product (same ingredients and dosage), only the provider offering the lowest price is kept.

```{r, echo=FALSE}
library(knitr)
bnf <- read_csv("BNF_sample.csv")
BNF_head <- head(BNF_sample)
kable(BNF_head)
```
