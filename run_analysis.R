# Course Project for Coursera Get Data

# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# loads required packages
library(dplyr); library(reshape2)

# load datasets
x_train = read.table("UCI HAR Dataset/train/X_train.txt")
y_train = read.table("UCI HAR Dataset/train/Y_train.txt")
x_test = read.table("UCI HAR Dataset/test/X_test.txt")
y_test = read.table("UCI HAR Dataset/test/Y_test.txt")
x_features = read.table("UCI HAR Dataset/features.txt")
subject_train = read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test = read.table("UCI HAR Dataset/test/subject_test.txt")
activity_lbls = read.table("UCI HAR Dataset/activity_labels.txt",stringsAsFactors=FALSE)
names(activity_lbls)[2] = "activity"  # changes to descriptive label for use in tidy dataset

# QUESTION 1 - MERGE DATA
# merge the train and test datasets - x, y, subject, and activity_lbls
subject = rbind(subject_train, subject_test)
names(subject)[1] = "subject"    # changes to descriptive label for use in tidy dataset
x = rbind(x_train, x_test)
colnames(x) = x_features$V2   # renames descriptively, as required in question #4
y = rbind(y_train, y_test)
y = merge(y, activity_lbls, by.x="V1", by.y="V1", all=TRUE)  # essentially an "Excel vlookup" to add descriptive activity values
y = subset(y, select = -c(V1))   # drops redundant variable that was duplicated in merge above ("Y1") in favor of "activity"
dat = cbind(y,x)                 # merges the x and y datasets

# QUESTION 2 - EXTRACT THE MEAN & SD FOR EACH VARIABLE
dat_forstats = subset(dat, select = -c(activity))
dat_mean = sapply(dat_forstats,mean)
dat_sd = sapply(dat_forstats,sd)
dat_stats = rbind(dat_mean, dat_sd)  # combines to one data frame with mean and sd for each variable

# QUESTION 3 - NAME THE ACTIVITES DESCRIPTIVELY
# completed above, where it is more appropriate -- see line 31

# QUESTION 4 - LABEL THE VARIABLES DESCRIPTIVELY
# completed above, where it is more appropriate -- see line 29

# QUESTION 5 - CREATE NEW TIDY DATASET WITH AVERAGE OF EACH VARIABLE, GROUPED BY SUBJECT AND ACTIVITY
dat = cbind(subject, dat)                            # merges the subject data into the main dataset
dat_melt = melt(dat, id=c("activity","subject"))     # puts dataset into long form for the summarize function
tidy_avgs = dat_melt %>% group_by(activity,subject,variable) %>% summarize(average = mean(value))  # gets variable averages by group

# Output question 5 as per project requirement
write.table(tidy_avgs, "tidyavgs.txt", row.name=FALSE)
