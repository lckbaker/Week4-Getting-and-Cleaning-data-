## Installing necessary packages
library(dplyr)

## Downloading the data and unzipping
if(!file.exists("./data")){dir.create("./data")}      ##checks if larger working file exists and if needed creates
if(!file.exists("./data/UCI HAR Dataset")) {          ##checks if database already downloaded, and does if needed
      url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
      download.file(url, destfile = "./data/zipped.zip", method = "curl")
      unzip("./data/zipped.zip", exdir = "./data")
      file.remove("./data/zipped.zip")
}

## Getting train data set
xtrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
subtrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
      
## Getting test data set
xtest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
subtest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## Features and activity labels
features <- read.table("./data/UCI HAR Dataset/features.txt")
actlab <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

## Naming columns
colnames(xtrain) <- features[,2]; colnames(xtest) <- features[,2]
colnames(ytrain) <- "actID"; colnames(ytest) <- "actID"
colnames(subtrain) <- "subjectID"; colnames(subtest) <- "subjectID"
colnames(actlab) <- c("actID", "Activity")

##Merging
train <- cbind(ytrain, subtrain, xtrain)
test <- cbind(ytest, subtest, xtest)
alldata <- rbind(test,train)

##Filtering for Mean and std_dev
valid_column_names <-make.names(names = names(alldata), unique = TRUE, allow_ = TRUE)  ##have to replace invalid column names for select function to work
names(alldata) <- valid_column_names
filtered <- select(alldata, actID, subjectID, contains("mean"), contains("std"), -contains("meanfreq"))

## Adding acitivy labels
with_activity <- merge(actlab, filtered, by = "actID")

##Finding means for each column and arranging by activity and subject
tidymeandata <- with_activity %>%
      group_by(subjectID, Activity) %>%
      summarize_all(funs(mean)) %>%
      arrange(actID, subjectID)

##Outputing as a text file
write.table(tidymeandata, "./data/Tidy Data.txt", row.name = FALSE)

