% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api_functions.R
\name{bucket_create}
\alias{bucket_create}
\title{Create Bucket}
\usage{
bucket_create(bucket, project, region, ...)
}
\arguments{
\item{bucket}{eg. "projectname-d36109-u1-o1"}

\item{project}{Name of project "projectname"}

\item{region}{"us-central1"}

\item{...}{Any other arguments to pass to `gcs_create_bucket()`}
}
\description{
Simple wrapper function around googleCloudStorageR functions
Requires you to have already authorized with `authorize()`
}
