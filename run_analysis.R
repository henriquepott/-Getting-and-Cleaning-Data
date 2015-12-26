########################################################################################################################
########################################################################################################################
### Getting and Cleaning Data - Course Project
### Project objectives: R script called run_analysis.R that does the following:
### 1. Merges the training and the test sets to create one data set.
### 2. Extracts only the measurements on the mean and standard deviation for each measurement.
### 3. Uses descriptive activity names to name the activities in the data set
### 4. Appropriately labels the data set with descriptive activity names.
### 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
########################################################################################################################
########################################################################################################################

## Dependencies: run_analysis.R file should install reshape2 and data.table automatically.
if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("reshape2")) {
  install.packages("reshape2")
}
require("data.table")
require("reshape2")

## Labels
# Activity labels
actlabels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
# Features
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

## Load data and Label
# Test data
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(x_test) = features
# Train data.
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(x_train) = features


## Extracts only the measurements on the mean and standard deviation for each measurement.
# Subset config
extfeatures <- grepl("mean|std", features)
# Subset mean and sd for each measurement - x_test
x_test = x_test[,extfeatures]
# Subset mean and sd for each measurement - x_train
x_train = x_train[,extfeatures]

## Labels Step 2
# Activity labels - y_test
y_test[,2] = actlabels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"
# Activity labels - y_train
y_train[,2] = actlabels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

## Merges the training and the test sets to create one data set.
# Bind data - test
test_dat <- cbind(as.data.table(subject_test), y_test, x_test)
# Bind data - train
train_dat <- cbind(as.data.table(subject_train), y_train, x_train)
# Merge test and train data
data = rbind(test_dat, train_dat)
id_labels = c("subject", "Activity_ID", "Activity_Label")
dat_labels = setdiff(colnames(data), id_labels)
melt_data = melt(data, id = id_labels, measure.vars = dat_labels)

## Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_dat   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
write.table(tidy_dat, file = "./tidy_dat.txt")
