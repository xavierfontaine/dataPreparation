###################################################################################################
############################### findAndTransformNumerics  #########################################
###################################################################################################
#' Identify numeric columns in a dataSet set
#' 
#' Function to find and transform characters that are in fact numeric.
#' @param dataSet Matrix, data.frame or data.table
#' @param n_test Number of non-null rows on which to test (numeric, default to 30)
#' @param verbose Should the algorithm talk? (logical, default to TRUE)
#' @details 
#' This function is looking for perfect transformation. 
#' If there are some mistakes in dataSet, consider setting them to NA before.
#' @section Warning:
#' All these changes will happen \strong{by reference}: please send a copy() of
#' your data.table to prepareSet if you do not want your
#' original dataSet to be modified.
#' @return The dataSet set (as a data.table) with identified numeric transformed.
#' @examples
#' # Let's build a dataSet set
#' dataSet <- data.table(ID = 1:5,
#'                   col1 = c("1.2", "1.3", "1.2", "1", "6"), 
#'                   col2 = c("1,2", "1,3", "1,2", "1", "6")
#'                   )
#' 
#' # using the findAndTransformNumerics
#' findAndTransformNumerics(dataSet, n_test = 5)
#' @export
findAndTransformNumerics <- function(dataSet, n_test = 30, verbose = TRUE){
  ## Working environement
  function_name <- "findAndTransformNumerics"
  
  ## Sanity check
  dataSet <- checkAndReturnDataTable(dataSet)
  
  
  ## Initialization
  start_time <- proc.time()
  
  ## Computation
  # identify
  numerics <- identifyNumerics(dataSet, n_test = n_test, verbose = verbose)
  if (verbose){
    printl(function_name, ": It took me ", round((proc.time() - start_time)[[3]], 2), 
           "s to identify ", length(numerics$notToStrip) + length(numerics$toStrip), 
           " numerics column(s), i will set them as numerics")
  }
  
  # Format
  if (length(numerics) < 1){
    if (verbose){
      printl(function_name, 
             ": There are no numerics to transform.", 
             "(If i missed something consider using setColAsNumeric to transform it)")
    }
    return(dataSet)
  }
  start_time <- proc.time()
  if (length(numerics$notToStrip) > 0 || length(numerics$toStrip) > 0 ){
    dataSet <- setColAsNumeric(dataSet, cols = numerics$notToStrip, stripString = FALSE, verbose = FALSE)  
    dataSet <- setColAsNumeric(dataSet, cols = numerics$toStrip, stripString = TRUE, verbose = FALSE)  
    
    if (verbose){
      printl(function_name, ": It took me ", round((proc.time() - start_time)[[3]], 2), 
             "s to transform ", length(numerics$notToStrip) + length(numerics$toStrip), 
             " column(s) to a numeric format")
    }
  }
  
  
  ## Wrapp-up
  return(dataSet)
}

###################################################################################################
############################### identifyNumerics  #################################################
###################################################################################################
identifyNumerics <- function(dataSet, n_test = 30, verbose = TRUE, ...){
  ## Working environment
  function_name = "identifyNumerics"
  
  ## Sanity check
  dataSet <- checkAndReturnDataTable(dataSet)
  n_test <- control_nb_rows(dataSet = dataSet, nb_rows = n_test, function_name = function_name, 
                            variable_name = "n_test")
  
  ## Initialization
  numerics_cols_dont_strip <- NULL
  numerics_cols_strip <- NULL
  if (verbose){ 
    pb <- initPB(function_name, names(dataSet))
  }
  
  ## Computation
  for (col in names(dataSet)){
    # Something is performed only if col is in a character format
    if (all(class(dataSet[[col]]) == "character")){
      # Get a few lines that aren't NA, NULL nor ""
      data_sample <- findNFirstNonNull(dataSet[[col]], n_test)
      
      # We check only columns that contains something (not NA, NULL, "")
      if (length(data_sample) > 0){ 
        # Check for direct convertion
        options(warn = -1) # Localy disable warning (we are trying to transform stuff if there is a mistake we skip it)
        data_sample_converted <- as.numeric(data_sample)
        options(warn = 0)
        if (sum(is.na(data_sample_converted)) == sum(is.na(data_sample))){
          numerics_cols_dont_strip <- c(numerics_cols_dont_strip, col)
          next()
        }
        
        ## Check for conversion with strip
        options(warn = -1) # Localy disable warning (we are trying to transform stuff if there is a mistake we skip it)
        data_sample_converted <- as.numericStrip(data_sample)
        options(warn = 0)
        if (sum(is.na(data_sample_converted)) == sum(is.na(data_sample))){
          numerics_cols_strip <- c(numerics_cols_strip, col)
          next()
        }
      }
    }
    if (verbose){
      setPB(pb, col)
    }
  }
  
  if (verbose){ 
    close(pb); rm(pb); gc(verbose = FALSE)
  }
  
  ## Wrapp-up
  return(list(notToStrip = numerics_cols_dont_strip, toStrip = numerics_cols_strip))
}


#######################################################################################
############################### As numerical strip  ###################################
#######################################################################################
as.numericStrip <- function(x){
  return(as.numeric(gsub(",", ".", x)))
}
