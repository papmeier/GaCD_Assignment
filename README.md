---
title: "README.md"
output: html_document
---
This GitHub repository was created for an assignment in the Coursera course Getting and Cleaning Data <https://class.coursera.org/getdata-031/>.

The repostitory contains a flat file format data set in variable_means.txt, a Codebook.md which explains the Variables of the data set and a run_analysis.R file, with the R script used to create the data set.

In this ReadMe I will explain the latter.

---

### Tidy data set

The data set is based on another data set for machine learning: <http://archive.ics.uci.edu/ml/data sets/Human+Activity+Recognition+Using+Smartphones>
A thorough description of the original data set can be found on that website.

The script starts with loading the library used in the script.
As well as setting the directory in which the data files are stored. The original directory structure of the zip file must be maintained for the script to work.

The files containg data in the original data set are unlabeled. The labels are stored in two seperate files. Containing an id and the respective labels.

The following lines read the labels each into a dataframe names activity_labels and feature_labels. The columns of the dataframes are set accordingly, because the files contain no labels as well.

```
## Read labels for activities and features from the respective files
activity_labels = read.csv(paste0(data_dir, "activity_labels.txt"), header=FALSE, sep = " ", col.names = c("activity_id","activity_label"))
feature_labels =read.csv(paste0(data_dir, "features.txt"), header=FALSE, sep = " ", col.names = c("feature_id","feature_label"))
```
Then the scripts prints the structure of the created data frames.

Afterwards the relevant data files (seperated into train and test data) are read into data frames as well. They are seperated into a file for subject ids, a file for an activity and the file with all measurements. The rows of these files are matching.

```
## Read the train data files
train_data <- read.table(paste0(data_dir,"train/X_train.txt"), sep = "", header=FALSE)
train_subjects <- read.table(paste0(data_dir,"train/subject_train.txt"), sep = "", header=FALSE)
train_activities <- read.table(paste0(data_dir,"train/Y_train.txt"), sep = "", header=FALSE)
```

After a glance on structure and summary of all the data files, the same is done for the test data files.

```
## Read the test data files
test_data <- read.table(paste0(data_dir,"test/X_test.txt"), sep = "", header=FALSE)
test_subjects <- read.table(paste0(data_dir,"test/subject_test.txt"), sep = "", header=FALSE)
test_activities <- read.table(paste0(data_dir,"test/y_test.txt"), sep = "", header=FALSE)
```

Following another glance on these data frames, the files get properly labeled.

```
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
```

The labels for the 'data' data frames are assigned from the feature_labels data frame, where they are stored in the second column.

Since we are only interested in the variables containing a mean or a standard deviation and the summary function is included in the label, we can subset the columns by their name:

```
## Keep only the columns with mean or std in the column name from both main data frames
subset <- grepl("mean",names(test_data)) | grepl("std",names(test_data))
train_data <- train_data[,subset]
test_data <- test_data[,subset]
```

The grepl() function is used to get all columns with "mean" or "std" in their name. And the resulting logical vector is used to subset the columns to just the one we are interested in.

Then cbind is used to combine the subject-, data- and activity-data frames into one. Since the rows are orderd accordingly and of the same length that can be done quite easily.

When we combine the resulting data frame with rbind() to a single large one the main part of the assignement is done.

```
## Add the columns from the subject and activites data frame to the main data frame
test_data <- cbind(test_subjects,test_data,test_activities)
train_data <- cbind(train_subjects,train_data,train_activities)

## Combine the test and train data frames to a single data frame
tidy_data <- rbind(train_data,test_data)
```

In a last step we assign the labels for the activities by id from the activity_labels data frame, converting the column to factor on the flow.

```
## Assign the labels for the activities from the activies_labels data frame
tidy_data$activity <- factor(tidy_data$activity, levels = activity_labels[,1], labels = activity_labels[,2])
```

We now have a reduced tidy data set.

### Summary data set

Since we are dealing with a reduced set of features now, I have stored the labels for this reduced set in another variable.

```
## Create a summary dataset with averages by activity and subject
subset_features <- as.character(feature_labels[subset,2])
```

The goal is to create a data set containg the mean for each of the subjects and each of the acitivites for all remaining feature variables.

First I create a data frame for each subject: Begining with spliting the dataset by subject. A subset of the columns is used, beacause the subject_id and the activity don't make sense in the resulting data frame. The split function generates a list with a data frame for each subject. Therfore I use lapply() to run over each of the data frames in the list. Applying another *apply function (sapply), which gets passed the mean function. This converts each data frame in the list to a vector with the mean for each variable of this subject.  

```
split_subjects <- split(tidy_data[,2:80], tidy_data$subject_id)
subject_means <- lapply(split_subjects, sapply, mean)
```

These vectors I combine to a new data frame containing each subject just once with the mean for each variable, by applying cbind to the list. This generates a matrix first which I then convert to a dataframe and add the labels for the rows from the subset_features variable. Lastly I generate names for each column containing the Subjects 1 to 30. The resulting names follow the pattern "Subject: ##".

```
subject_means <- sapply(subject_means, cbind)
subject_means <- data.frame(subject_means, row.names = subset_features)
names(subject_means) <- c(paste("Subject:",1:30))
```

The same is done for the six activities. With the only difference being the naming of the columns with a similiar pattern "Activity: Activity-name".

```
split_activities <- split(tidy_data[,2:80], tidy_data$activity)
activity_means <- lapply(split_activities, sapply, mean)
activity_means <- sapply(activity_means, cbind)
activity_means <- data.frame(activity_means, row.names = subset_features)
names(activity_means) <- c(paste("Activity: ", activity_labels[,2]))
```

These two data frames properly named and of the same size regarding the rows can be combined column wise to a single summary data frame. Since the row names shall not be exported I generate a column with the feature/variable labels, therefore the rows can still be identified. The new first column has to be labeled, which is done in a last step.

```
summary_data <- bind_cols(data.frame(subset_features), subject_means, activity_means)
names(summary_data)[1] <- "Variable"
```

Finally the summary data set can be exported:

```
write.table(summary_data, "variable_means.txt", row.names = FALSE)
```