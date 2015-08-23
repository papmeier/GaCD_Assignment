#####
##
## Script for cleaning and reducing the dataset for Human Activity Recognition from
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
## A full description of the script can be found in the Readme.md and a code book in CodeBook.md
##
#####

## Loading required libraries
library(dplyr)

## Set directory containing data
data_dir = "UCI HAR Dataset/"

## Read labels for activities and features from the respective files
activity_labels = read.csv(paste0(data_dir, "activity_labels.txt"), header=FALSE, sep = " ", col.names = c("activity_id","activity_label"))
feature_labels =read.csv(paste0(data_dir, "features.txt"), header=FALSE, sep = " ", col.names = c("feature_id","feature_label"))

## Check content of the labels data frames
str(activity_labels)
str(feature_labels)

## Read the train data files
train_data <- read.table(paste0(data_dir,"train/X_train.txt"), sep = "", header=FALSE)
train_subjects <- read.table(paste0(data_dir,"train/subject_train.txt"), sep = "", header=FALSE)
train_activities <- read.table(paste0(data_dir,"train/Y_train.txt"), sep = "", header=FALSE)

## Check the contents of the train data files
summary(train_data)
summary(train_subjects)
summary(train_activities)

str(train_data)
str(train_subjects)
str(train_activities)

## Read the test data files
test_data <- read.table(paste0(data_dir,"test/X_test.txt"), sep = "", header=FALSE)
test_subjects <- read.table(paste0(data_dir,"test/subject_test.txt"), sep = "", header=FALSE)
test_activities <- read.table(paste0(data_dir,"test/y_test.txt"), sep = "", header=FALSE)

## Check the contents of the train data files
summary(test_data)
summary(test_subjects)
summary(test_activities)

str(test_data)
str(test_subjects)
str(test_activities)

## Set column names for the subject and activities data frames
names(train_subjects) <- "subject_id"
names(train_activities) <- "activity"

## Assign the column names for the train data frame from the feature labels data frame
names(train_data) <- feature_labels[,2]

## Set column names for the subject and activities data frames
names(test_subjects) <- "subject_id"
names(test_activities) <- "activity"

## Assign the column names for the test data frame from the feature labels data frame
names(test_data) <- feature_labels[,2]

## Keep only the columns with mean or std in the column name from both main data frames
subset <- grepl("mean",names(test_data)) | grepl("std",names(test_data))
train_data <- train_data[,subset]
test_data <- test_data[,subset]

## Add the columns from the subject and activites data frame to the main data frame
test_data <- cbind(test_subjects,test_data,test_activities)
train_data <- cbind(train_subjects,train_data,train_activities)

## Combine the test and train data frames to a single data frame
tidy_data <- rbind(train_data,test_data)

## Assign the labels for the activities from the activies_labels data frame
tidy_data$activity <- factor(tidy_data$activity, levels = activity_labels[,1], labels = activity_labels[,2])

## Check content of tidy data frame
str(tidy_data)
summary(tidy_data)

## Create a summary dataset with averages by activity and subject
subset_features <- as.character(feature_labels[subset,2])

split_subjects <- split(tidy_data[,2:80], tidy_data$subject_id)
subject_means <- lapply(split_subjects, sapply, mean)
subject_means <- sapply(subject_means, cbind)
subject_means <- data.frame(subject_means, row.names = subset_features)
names(subject_means) <- c(paste("Subject:",1:30))

split_activities <- split(tidy_data[,2:80], tidy_data$activity)
activity_means <- lapply(split_activities, sapply, mean)
activity_means <- sapply(activity_means, cbind)
activity_means <- data.frame(activity_means, row.names = subset_features)
names(activity_means) <- c(paste("Activity: ", activity_labels[,2]))

summary_data <- bind_cols(data.frame(subset_features), subject_means, activity_means)
names(summary_data)[1] <- "Variable"


write.table(summary_data, "variable_means.txt", row.names = FALSE)
