Working with tabletidier outputs
================
2023-08-18

# tldr

The functions in [restructuring.R](/restructuring.R) are designed to
help you work with the json outputs from TableTidier.

# Reason for using json

We used json because it allows more flexible data structures than do
flat files such as comma-separated value files (CSV) or tab-delimited
files, while conversion into flat files is reasonably straightforward
using R packages (or equivalents in other software). If you are familiar
with lists in R, you can think of json files as nested lists.

The raw json files are difficult for a human to read. For example the
first 200 characters of the json file for a collection looks like this.

``` r
read_lines("collection_132_all.json") %>% str_sub(1,200)
```

    ## [1] "{\"selected_results\":[{\"tid\":12078,\"docid\":\"NCT03643965.html\",\"page\":1,\"collection_id\":132,\"doi\":\"https://doi.org/10.1016/S0140-6736(23)01554-4\",\"pmid\":\"\",\"url\":\"\",\"annotations\":{\"notes\":\"\",\"tableType\""

It looks a little better in a text editor with json support.

<figure>
<img src="json_image_text.png"
alt="Snapshot of collection using a json text editor" />
<figcaption aria-hidden="true">Snapshot of collection using a json text
editor</figcaption>
</figure>

Moreover, if you paste a json file such as “collection_123_all.json”
into json viewer (just google to find one) you can see the list
structure quite clearly. For our json files, the highest level of
structure is each table. Within each table there are sections for
information, notes, data and terminology. There are also objects which
allow us to map between data and terminology.

<figure>
<img src="json_image.png"
alt="Snapshot of collection using a json viewer" />
<figcaption aria-hidden="true">Snapshot of collection using a json
viewer</figcaption>
</figure>

# Conversion into R objects

It is quite straightforward to convert these into R objects (nested
lists) using the `R` `jsonlite` package. The package also has functions
that will automatically simplify the objects into, for example,
dataframes and vectors. However, many people are not comfortable with
nested lists, and even among those who are, almost all will be
unfamiliar with the structure of json files that TableTidier produces.
Therefore, we have created a set of helper functions to work with
TableTidier json files. The following demonstrates their usage.

# Reading in collections

Collections can be read in as follows. The whole file is read in as a
list object and the information for each table is printed.

``` r
clctn <- ReadCollection("collection_132_all_additional.json")
```

    ## # A tibble: 7 × 7
    ##     tid docid             page collection_id doi                     pmid  url  
    ##   <int> <chr>            <int>         <int> <chr>                   <chr> <chr>
    ## 1 12094 35241135.html        1           132 ""                      ""    ""   
    ## 2 12095 35241135.html        2           132 "10.1186/s13054-022-03… "352… "htt…
    ## 3 12096 35241135.html        4           132 ""                      "352… ""   
    ## 4 12097 35241135.html        3           132 ""                      "352… ""   
    ## 5 12078 NCT03643965.html     1           132 "https://doi.org/10.10… ""    ""   
    ## 6 12079 NCT03643965.html     2           132 "https://doi.org/10.10… ""    ""   
    ## 7 12080 NCT03643965.html     3           132 "https://doi.org/10.10… ""    ""

We can interrogate the object read in to find out more. It is
essentially a list.

``` r
class(clctn)
```

    ## [1] "list"

At the top level of this particular collection there are 6 tables, named
by the table IDs (TIDs).

``` r
names(clctn)
```

    ## [1] "TID12094" "TID12095" "TID12096" "TID12097" "TID12078" "TID12079" "TID12080"

Within a single table we have table information (tid, docid, page,
collection_id, doi, pmid and url), annotations, data (tableResults),
terminology (metadata) and list objects to allow mapping between the
data and terminology (concMapper and posiMapper).

``` r
names(clctn$TID12094)
```

    ##  [1] "tid"           "docid"         "page"          "collection_id"
    ##  [5] "doi"           "pmid"          "url"           "annotations"  
    ##  [9] "tableResults"  "metadata"      "concMapper"    "posiMapper"

The “information” fields were printed when we read in the collection.
You can also access these as a dataframe using the function
`ConvertInfo`.

``` r
ConvertInfo(clctn)
```

    ## # A tibble: 7 × 7
    ##     tid docid             page collection_id doi                     pmid  url  
    ##   <int> <chr>            <int>         <int> <chr>                   <chr> <chr>
    ## 1 12094 35241135.html        1           132 ""                      ""    ""   
    ## 2 12095 35241135.html        2           132 "10.1186/s13054-022-03… "352… "htt…
    ## 3 12096 35241135.html        4           132 ""                      "352… ""   
    ## 4 12097 35241135.html        3           132 ""                      "352… ""   
    ## 5 12078 NCT03643965.html     1           132 "https://doi.org/10.10… ""    ""   
    ## 6 12079 NCT03643965.html     2           132 "https://doi.org/10.10… ""    ""   
    ## 7 12080 NCT03643965.html     3           132 "https://doi.org/10.10… ""    ""

Finally, at the collection level it is also useful to extract
annotations into a dataframe.

``` r
ConvertNotes(clctn)
```

    ## # A tibble: 7 × 4
    ##   tid      notes tableType        completion
    ##   <chr>    <chr> <chr>            <chr>     
    ## 1 TID12094 ""    ""               ""        
    ## 2 TID12095 ""    "baseline_table" ""        
    ## 3 TID12096 ""    "results_table"  ""        
    ## 4 TID12097 ""    "results_table"  ""        
    ## 5 TID12078 ""    "baseline_table" ""        
    ## 6 TID12079 ""    "results_table"  ""        
    ## 7 TID12080 ""    "results_table"  ""

# Extracting data and terminology

For extracting data and terminology into more usable R objects it makes
sense to do so for individual tables as well as for collections. We can
extract data for single tables thus.

``` r
# print first 6 rows only
ConvertData(clctn$TID12095) %>% 
  head()
```

    ##   characteristics@1 characteristics@2                arms@1 col row   value
    ## 1                          Age (year)  Neostigmine (n = 40)   1   1 46 ± 13
    ## 2                          Age (year) Conventional (n = 40)   2   1 49 ± 14
    ## 3                          Age (year)               P value   3   1    0.85
    ## 4                           Sex (m/f)  Neostigmine (n = 40)   1   2   27/13
    ## 5                           Sex (m/f) Conventional (n = 40)   2   2    34/6
    ## 6                           Sex (m/f)               P value   3   2    0.11

We can also extract data for the whole collections at once using `map`
(or if preferred base `R` can use `lapply` ).

``` r
# print first row only
map(clctn, ~ ConvertData(.x) %>% head(1))
```

    ## $TID12094
    ##   characteristics@1 other@1 col row
    ## 1        Definition     IAH   1   1
    ##                                                             value
    ## 1 A sustained or repeated pathological elevation in IAP ≥ 12 mmHg
    ## 
    ## $TID12095
    ##   characteristics@1 characteristics@2               arms@1 col row   value
    ## 1                          Age (year) Neostigmine (n = 40)   1   1 46 ± 13
    ## 
    ## $TID12096
    ##                 arms@1            times@1 outcomes@1
    ## 1 Neostigmine (n = 40) Follow up 24 hours           
    ##                         outcomes@2 col row                     value
    ## 1 Percent change of IAP at 24 h, %   2   2 − 18.7 ([− 28.4]-[− 4.7])
    ## 
    ## $TID12097
    ##                       other@1               arms@1 measures@1 times@1 col row
    ## 1 Intention-to-treat analysis Neostigmine (n = 40)        IAP       0   1   3
    ##        value
    ## 1 16.3 ± 2.7
    ## 
    ## $TID12078
    ##                      arms@1 characteristics@1 characteristics@2 col row
    ## 1 Nefecon 16 mg/day (n=182)        Age, years                     2   1
    ##        value
    ## 1 43 (36–50)
    ## 
    ## $TID12079
    ##                                                                   measures@1
    ## 1 Number (%) of patients with confirmed 30% eGFR reduction or kidney failure
    ##             arms@1                                          other@1 col row
    ## 1 Nefecon16 mg/day Full analysis set (Nefecon n=182; placebo n=182)   2   2
    ##      value
    ## 1 21 (12%)
    ## 
    ## $TID12080
    ##                    times@1                    arms@1
    ## 1 9-month treatment period Nefecon 16 mg/day (n=182)
    ##                       characteristics@1 characteristics@2 col row     value
    ## 1 All treatment-emergent adverse events                     2   2 159 (87%)

We can extract terminology similarly, both for a single table

``` r
# print first 6 rows only
ConvertTerminology(clctn$TID12095) %>% 
  head()
```

    ##   concept_source concept_root                 concept
    ## 1                                          Age (year)
    ## 2                                           Sex (m/f)
    ## 3                                                 ACS
    ## 4                                      Use of opioids
    ## 5                                    Colonic ileusc,d
    ## 6                             24 h of defecation (mL)
    ##                                                                               cuis
    ## 1                                                       C0001779;C0439234;C0439508
    ## 2                   C0009253;C0036864;C0079399;C0804628;C1314687;C1522384;C1306057
    ## 3                                                       C0742343;C4318612;C0948089
    ## 4                                                       C1524063;C0002772;C0242402
    ## 5                                              C0073187;C0332173;C4484261;C0009368
    ## 6 C0439526;C1705224;C3887665;C0033727;C0369286;C0441932;C0564385;C4528284;C0011135
    ##   qualifiers cuis_selected qualifiers_selected istitle labeller
    ## 1                 C0001779                       FALSE       NA
    ## 2                 C0079399                       FALSE       NA
    ## 3                 C0948089                       FALSE       NA
    ## 4                 C0002772                       FALSE       NA
    ## 5                 C0009368                       FALSE       NA
    ## 6                 C0011135                       FALSE       NA

and for multiple tables. Since terminology tables are always in the same
format, it often makes sense to bind these into a single table after
extracting them.

``` r
# print first 6 rows
map(clctn, ~ ConvertTerminology(.x)) %>% 
  bind_rows(.id = "tid") %>% 
  slice(1:6)
```

    ##        tid concept_source concept_root                 concept
    ## 1 TID12095                                          Age (year)
    ## 2 TID12095                                           Sex (m/f)
    ## 3 TID12095                                                 ACS
    ## 4 TID12095                                      Use of opioids
    ## 5 TID12095                                    Colonic ileusc,d
    ## 6 TID12095                             24 h of defecation (mL)
    ##                                                                               cuis
    ## 1                                                       C0001779;C0439234;C0439508
    ## 2                   C0009253;C0036864;C0079399;C0804628;C1314687;C1522384;C1306057
    ## 3                                                       C0742343;C4318612;C0948089
    ## 4                                                       C1524063;C0002772;C0242402
    ## 5                                              C0073187;C0332173;C4484261;C0009368
    ## 6 C0439526;C1705224;C3887665;C0033727;C0369286;C0441932;C0564385;C4528284;C0011135
    ##   qualifiers cuis_selected qualifiers_selected istitle labeller
    ## 1                 C0001779                       FALSE       NA
    ## 2                 C0079399                       FALSE       NA
    ## 3                 C0948089                       FALSE       NA
    ## 4                 C0002772                       FALSE       NA
    ## 5                 C0009368                       FALSE       NA
    ## 6                 C0011135                       FALSE       NA

# Mapping between data and terminology

As well as allowing us to nest tables within collections, one of the
main motivations for using json files was to preserve the relationship
between the data and the terminology. This is done via the `concMapper`
and `posiMapper` objects. To simplify this process we have provided the
helper functions SearchConcepts, GetCuis and GetDataRowsCols. First we
describe how to use these. Next, for those interested we explain the
structures in more detail.

## Approach using SearchConcepts, GetCuis and GetDataRowsCols

We simplify mapping between terminology and data using the functions
SearchConcepts, GetCuis and GetDataRowsCols.

First we search for concepts with text or a concept ID we are interested
in. It will often make sense to do this after browsing the terminology
tables created by `ConvertTerminology` or looking at the tables on
TableTidier itself. Assuming we have an idea of what concepts were are
intersted in we can search. We can search either using a concept ID or
string.

First we can search for a string, in this case age. The search is a
regular expression search so is by default case sensitive.

``` r
res <- SearchConcepts(clctn$TID12078, cutext = "pressure")
res
```

    ## [1] 5

We could also have found this using the concept ID

``` r
res <- SearchConcepts(clctn$TID12078, cuis = "C0005823")
res
```

    ## [1] 5

Next we can use this number to identify which original rows and columns
the concept relates to.

``` r
res_r_c <- GetDataRowsCols(clctn$TID12078, res)
res_r_c
```

    ##   col row                           text conceptrow
    ## 1   2  12 Baseline blood pressure, mm Hg          5
    ## 2   2  13 Baseline blood pressure, mm Hg          5
    ## 3   3  12 Baseline blood pressure, mm Hg          5
    ## 4   3  13 Baseline blood pressure, mm Hg          5

Finally, we can obtain the relevant data by joining the above table to
the data table by rows and columns.

``` r
mydf <- ConvertData(clctn$TID12078)
mydf %>% 
  semi_join(res_r_c)
```

    ## Joining with `by = join_by(col, row)`

    ##                      arms@1              characteristics@1 characteristics@2
    ## 1 Nefecon 16 mg/day (n=182) Baseline blood pressure, mm Hg          Systolic
    ## 2           Placebo (n=182) Baseline blood pressure, mm Hg          Systolic
    ## 3 Nefecon 16 mg/day (n=182) Baseline blood pressure, mm Hg         Diastolic
    ## 4           Placebo (n=182) Baseline blood pressure, mm Hg         Diastolic
    ##   col row         value
    ## 1   2  12 126 (121–132)
    ## 2   3  12 124 (117–130)
    ## 3   2  13    79 (76–84)
    ## 4   3  13    79 (74–84)

## Mapping between data and terminology for multiple tables

If comfortable using `map` or `lapply`, it is also straightforward to
pull multiple concepts at once.

``` r
search_res <- map(clctn, function(each_tbl){
  SearchConcepts(each_tbl, cutext = "Placebo")
})
# take only those tables with a Placebo concept
clctn_slct <- clctn[map_lgl(search_res, ~ length(.x) >=1 )]
names(clctn_slct)
```

    ## [1] "TID12078" "TID12079" "TID12080"

Having limited the collection to those tables with the information, we
can loop over these pulling the relevant rows and columns

``` r
map(clctn_slct, function(each_tbl){
  res <- SearchConcepts(each_tbl, cutext = "Placebo")
res_r_c <- GetDataRowsCols(each_tbl, res)
mydf <- ConvertData(each_tbl)
mydf %>% 
  semi_join(res_r_c) %>% 
  slice(1)
})
```

    ## $TID12078
    ##            arms@1 characteristics@1 characteristics@2 col row      value
    ## 1 Placebo (n=182)        Age, years                     3   1 42 (34–49)
    ## 
    ## $TID12079
    ##                                                                   measures@1
    ## 1 Number (%) of patients with confirmed 30% eGFR reduction or kidney failure
    ##    arms@1                                          other@1 col row    value
    ## 1 Placebo Full analysis set (Nefecon n=182; placebo n=182)   3   2 39 (21%)
    ## 
    ## $TID12080
    ##                    times@1          arms@1
    ## 1 9-month treatment period Placebo (n=182)
    ##                       characteristics@1 characteristics@2 col row     value
    ## 1 All treatment-emergent adverse events                     3   2 125 (69%)

## Mapping from data to terminology

We can of course also map in the other direction, from data to
terminology.

``` r
ConvertData(clctn$TID12078) %>% slice(17)
```

    ##                      arms@1              characteristics@1 characteristics@2
    ## 1 Nefecon 16 mg/day (n=182) Baseline blood pressure, mm Hg          Systolic
    ##   col row         value
    ## 1   2  12 126 (121–132)

``` r
GetCuis(clctn$TID12078, row = 12, col = 2)
```

    ##                       arms@1              characteristics@1 characteristics@2
    ## 17 Nefecon 16 mg/day (n=182) Baseline blood pressure, mm Hg          Systolic
    ##    col row         value
    ## 17   2  12 126 (121–132)
    ## $`Nefecon 16 mg/day (n=182)`
    ## [1] 0
    ## 
    ## $`Baseline blood pressure, mm Hg`
    ## [1] 5
    ## 
    ## $Systolic
    ## [1] 25

    ##    concept_source concept_root                        concept
    ## 1                                   Nefecon 16 mg/day (n=182)
    ## 6                              Baseline blood pressure, mm Hg
    ## 26                                                   Systolic
    ##                                                                                         cuis
    ## 1                                                        C0369718;C0441922;C0439422;C0054201
    ## 6  C0439475;C0443150;C0005823;C1271104;C1272641;C0005767;C0005768;C0229664;C0168634;C1442488
    ## 26                                                                         C0039155;C4274438
    ##    qualifiers     cuis_selected qualifiers_selected istitle labeller
    ## 1                      C0054201                       FALSE       NA
    ## 6             C0439475;C0005823                       FALSE       NA
    ## 26            C0039155;C4274438                       FALSE       NA

# Detail on `concMapper` and `posiMapper`

The following is only for those interested in more detail on how
`concMapper` and `posiMapper` work. `concMapper` contains each original
text label and its index. Since this was created in javascript, the
indexing starts at zero rather than at one (R is unusual in starting its
indexing at one). The following shows the first 6 items in the
`concmapper` list for one of the tables.

``` r
clctn$TID12095$concMapper %>% head()
```

    ## $`Age (year)`
    ## [1] 0
    ## 
    ## $`Sex (m/f)`
    ## [1] 1
    ## 
    ## $ACS
    ## [1] 2
    ## 
    ## $`Use of opioids`
    ## [1] 3
    ## 
    ## $`Colonic ileusc,d`
    ## [1] 4
    ## 
    ## $`24 h of defecation (mL)`
    ## [1] 5

`posiMapper` is more complex, it contains each each original text label
and its index. Since this was created in javascript, the indexing starts
at zero rather than at one (R is unusual in starting its indexing at
one).

The posiMapper list has one element for each column at the highest
level.

``` r
a <- clctn$TID12095$posiMapper
names(a)
```

    ## [1] "1" "2" "3"

Within each column there is an entry for each row.

``` r
length(a[[1]])
```

    ## [1] 36

For each of these there is an entry for each text label corresponding to
the terminology labelling.

``` r
a$`1`$`2`$`Sex (m/f)`
```

    ## [1] 1

``` r
a$`1`$`2`$`Neostigmine (n = 40)`
```

    ## [1] 40

If we examine the data and terminology for this row and column we can
see how these lists allow us to map across between terminology and data.

``` r
ConvertData(clctn$TID12095) %>% filter(col == 1, row == 2)
```

    ##   characteristics@1 characteristics@2               arms@1 col row value
    ## 1                           Sex (m/f) Neostigmine (n = 40)   1   2 27/13

``` r
ConvertTerminology(clctn$TID12095)  %>% slice(c(1, 40)+1)
```

    ##   concept_source concept_root              concept
    ## 1                                        Sex (m/f)
    ## 2                             Neostigmine (n = 40)
    ##                                                             cuis qualifiers
    ## 1 C0009253;C0036864;C0079399;C0804628;C1314687;C1522384;C1306057           
    ## 2                   C0027679;C0369718;C0441922;C0439509;C3842587           
    ##   cuis_selected qualifiers_selected istitle labeller
    ## 1      C0079399                       FALSE       NA
    ## 2      C0027679                       FALSE       NA
