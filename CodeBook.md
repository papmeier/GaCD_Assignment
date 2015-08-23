---
title: "CodeBook.md"
output: html_document
---

This document shall give you an overview of the data stored in variable_means.txt.

## Summary

The dataset stems from the machine learning dataset Human Activity Recofnition avaiable at <http://archive.ics.uci.edu/ml/data sets/Human+Activity+Recognition+Using+Smartphones>. In the data set presented here you'll find a mean caluculated each of the datasets mean and standard deviation variables for each subject and each activity from the original dataset.

## Cases

The rows in the dataset correspond to the measurements in the machine learning dataset.
In this dataset only the 79 mean and standard deviation are included.

## Dimensions

The column of the dataset are structured this way:

Column number | Column name | Description
--- | --- | ---
1 | Variable | Name of the variable for which the means were calculated
2 - 31 | Subject: ## | Mean for the named subject, where ## means the subjects number
32 - 37 | Activity: Activity name | Mean for the named Activity
