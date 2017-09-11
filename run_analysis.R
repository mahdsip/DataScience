library(dplyr)
library(data.table)
#Merges the training and the test sets to create one data set.

activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")

XTrain <- read.table("train/X_train.txt")
setnames(XTrain,as.character(features$V2))
y_train <- read.table("train/y_train.txt")
#Uses descriptive activity names to name the activities in the data set
y_train <- merge(y_train,activity_labels,by.x = "V1",by.y = "V1")[,2]
y_train <-as.data.frame(y_train)
setnames(y_train,c("activity"))
subject_train <- read.table("train/subject_train.txt")
setnames(subject_train,c("subjectID"))
Train <- cbind(XTrain,y_train,subject_train)


XTest  <- read.table("test/X_test.txt")
setnames(XTest,as.character(features$V2))
y_test <- read.table("test/y_test.txt")
#Uses descriptive activity names to name the activities in the data set
y_test <- merge(y_test,activity_labels,by.x = "V1",by.y = "V1")[,2]
y_test <-as.data.frame(y_test)
setnames(y_test,c("activity"))
subject_test <- read.table("test/subject_test.txt")
setnames(subject_test,c("subjectID"))
Test <- cbind(XTest,y_test,subject_test)


data <- rbind(Train,Test)
#Extracts only the measurements on the mean and standard deviation for each measurement.
extracted_columns <- grepl("mean\\(\\)", features$V2) |grepl("std\\(\\)", features$V2)
append(extracted_columns,c(TRUE,TRUE))
data <- data[,extracted_columns] 

#Appropriately labels the data set with descriptive variable names.
names(data) <- gsub("^t","Time",names(data))
names(data) <- gsub("^f","Frequency",names(data))
#names(data) <- gsub("*Mag*","Magnitude",names(data))
#names(data) <- gsub("*\\(\\)*", "", names(data))
names(data) <- gsub("-mean\\(\\)", "Mean", names(data))
names(data) <- gsub("-std\\(\\)", "StdDev", names(data))
names(data) <- gsub("*\\-*", "", names(data))
#names(data) <- gsub("*\\(\\)*", "", names(data))

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

final <- data %>% group_by(activity,subjectID) %>% summarise_all(funs(mean)) %>% arrange(activity,subjectID)
#write.table(x = final,file ="data.txt",row.name=FALSE ) 
