#library(RCurl)
#library(tidyverse)
#library(tidylog)

#PASTA terminology:
#packageId ex: knb-lter-arc.1226.2 where arc=site, 1226=identifier, 2=revision
#each package contains 1 or more elements (e.g. datasets) with elementIds

lter_download = function(src_df, lter_dir, dmn){

    #src_df must have the following columns:
        #id: LTER packageId,
        #domain: must match subdir name for domain in lter folder,
        #pretty_name: will be printed to the user (in bookdown)
        #type: dateset category, e.g. "snow depth"
        #in_workflow: 0=ignored, 1=included (currently handled in global env)

    #lter_dir is the local parent folder for all lter domains,
        #e.g. HJ Andrews, HBEF, etc.

    #dmn must match subdir name for domain in lter folder.
        #this will also be used to filter src_df

    `%>%` = magrittr::`%>%`
    endpoint = 'https://pasta.lternet.edu/package/data/eml/'

    src_df = tidylog::filter(src_df, domain == dmn)

    for(i in 1:nrow(src_df)){

        pid = src_df$pid_str[i]
        element_ids = RCurl::getURLContent(paste0(endpoint, pid))
        element_ids = strsplit(element_ids, '\n')[[1]]
        rawdir = paste0(lter_dir,dmn, '/raw/',src_df$type[i])

        for(e in element_ids){

            dir.create(rawdir, showWarnings=FALSE, recursive = TRUE)
            rawfile = paste0(rawdir, '/', e, '.csv')
            download.file(url=paste0(endpoint, pid, e),
                destfile=rawfile, cacheOK=FALSE, method='curl')
        }

        print(paste0(i, ': Downloaded ', src_df$type[i], ' (',
            src_df$pretty_name[i], ') to ', lter_dir, '/', rawfile))
    }
}

