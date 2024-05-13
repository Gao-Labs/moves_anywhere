# Cloud MOVES Guide

Lead Developer: Tim Fraser, PhD

Contributors: Erin Murphy

## 0. Using Cornell Cloud MOVES (Alpha - for Cornell CAT Research Team only)

An exciting current research direction of the Cornell CAT MOVES team is the development of Cornell Cloud MOVES, a system for executing MOVES runs in the Cloud. This technology is currently in Alpha mode, available only for CAT research team members only with permission. Please see below for details on how to execute it.

## 1. Requirements for Cornell Cloud MOVES

To use Cornell Cloud MOVES, you will need the following items.

| Name          | Description                                                                                                                  |
|---------------|------------------------------------------------------------------------------------------------------------------------------|
| API Key       | Google Cloud API Key with requisite permissions                                                                              |
| Gmail Account | Cornell gmail account                                                                                                        |
| Viewer        | Viewer Permissions for Google Storage Buckets, assigned to your Cornell gmail account                                        |
| catr Package  | The catr package installed in RStudio, plus any dependencies                                                                 |
| Runspec       | Your runspec, saved as rs_custom.xml. It must always be added to the bucket LAST after your custom input tables.             |
| Parameters    | Your parameters file, saved as parameters.json. If you want your data to be saved to catcloud's orderdata database.          |
| Custom Tables | Any custom input tables in the style described in Section 3.1 above.                                                         |
| CAT Account   | A CAT user account, with a userid number                                                                                     |
| Bucket Name   | A unique bucket name that has not yet been used and a dtablename that has not yet been used. Standard format is d36109-u1-o1 |
| Single Run    | If doing just 1 single MOVES run, review demo_run.R.                                                                         |
| Scenario Run  | If doing several MOVES run as a scenario, review demo_scenario.R.                                                            |

If any questions, ask Tim Fraser [tmf77\@cornell.edu](mailto:tmf77@cornell.edu){.email}. Please be sure to read the documentation first, as 99% of questions often can be first resolved with the documentation. 😃

## 2. Cloud MOVES Process

Cloud MOVES is run on Google Cloud, making use of the Workflows API, Cloud Run API, and Cloud SQL API, among others. The basic idea is as follows:

#### Figure 1: Triggering a MOVES Run Job

-   Add any custom input `.csv`s to the bucket.

-   Add `rs_custom.xml` to the bucket. This is the trigger event that kicks off a cloud upload job. This step must always occur [**LAST**]{.underline}**.**

``` mermaid
flowchart LR

bucket
csv["custom inputs"]
rs["runspec"]

create_bucket[["create<br>bucket"]]
add_files[["add files"]]
add_rs[["add rs_custom.xml"]]
workflow_moves["workflow<br><b>moves</b>"]
create_job[["create job<br>& mount bucket"]]
image_moves["image<br><b>moves:v1</b>"]
container_moves["run<br>container<br><b>moves</b>"]
output_csvs["output .csvs"]

create_bucket ---> bucket
csv --> add_files --> bucket
rs --> add_rs
add_rs --> trigger_moves
add_rs --> bucket

trigger_moves("trigger<br><b>rs-to-moves</b>")
bucket --> trigger_moves

trigger_moves --> workflow_moves

image_moves ---> create_job
workflow_moves --> create_job --> container_moves

bucket --- create_job

container_moves --> output_csvs 
output_csvs -- Put Outputs back in Bucket --> bucket
```

#### Figure 2: Triggering a Cloud SQL Upload Job

Next, optionally, if the developer desires for their `data.csv` to be stored in our Cloud SQL `catcloud` server in the `orderdata` database, they must...

-   Add a `parameters.json` file to the bucket.

    -   That `parameters.json` file should specify the `dtablename` of the table they want to create/add to.

    -   If they want to add multiple data.csv files from different buckets to the same table, then they should keep the `dtablename` the same, but list `multiple: TRUE`.

-   Add a `data.csv` file to the bucket. This is the trigger event that kicks off a cloud upload job. This step must always occur [**LAST**]{.underline}**.**

``` mermaid

flowchart LR

bucket

workflow_upload["workflow<br><b>upload</b>"]
create_job[["create job<br>& mount bucket"]]
image_upload["image<br><b>upload:v2</b>"]
container_upload["run<br>container<br><b>upload</b>"]
add_parameters[["add parameters.json"]]
add_data[["Add data.csv"]] 
parameters["parameters.json"]
data["data.csv"]
trigger_upload("trigger<br><b>data-to-upload</b>")
add_table[["Add table<br><b>[dtablename]</b>"]]
cloudsql[("Cloud SQL<br><b>[dtablename]</b>")]

parameters --> add_parameters
add_parameters --> bucket
data --> add_data
add_data --> bucket
bucket --> trigger_upload
add_data --> trigger_upload


trigger_upload --> workflow_upload
image_upload ---> create_job
bucket --> create_job

workflow_upload --> create_job --> container_upload
container_upload --> add_table
add_table --> cloudsql 
```

## 3. Frequent Links

These links may be helpful to you as you check in on the status of your uploads and jobs, etc.

-   [Check Bucket Status](https://console.cloud.google.com/storage/browser?forceOnBucketsSortingFiltering=true&authuser=1&hl=en&project=moves-runs&supportedpurview=project&prefix=&forceOnObjectsSortingFiltering=false)

-   [Check MOVES Workflow Status Here:](https://console.cloud.google.com/workflows/workflow/us-central1/run-moves/executions?authuser=1&hl=en&project=moves-runs&supportedpurview=project)

-   [Check Jobs Status Here](https://console.cloud.google.com/run/jobs?authuser=1&project=moves-runs&supportedpurview=project)

-   [Check Upload Workflow Status Here](https://console.cloud.google.com/workflows/workflow/us-central1/upload-data/executions?authuser=1&hl=en&project=moves-runs&supportedpurview=project)

-   [Check CAT Cloud Server Here](https://console.cloud.google.com/sql/instances/catcloud/overview?authuser=1&hl=en&project=moves-runs)

-   [Check Permissions Here](https://console.cloud.google.com/iam-admin/iam?authuser=1&hl=en&project=moves-runs)

-   [Check Billing Here](https://console.cloud.google.com/billing/01C33B-2EA889-CDC484?authuser=1&hl=en&project=moves-runs)

-   [Check CATSERVER Read-Only Credentials for `granddata` here.](https://docs.google.com/document/d/1La8vmQ5KcUBRjdwVW7C24HholWNq_YXJPg5ZiAad6X4/edit?usp=sharing) (Need permission)

-   [Check API Key here](https://drive.google.com/file/d/1i09dCu8aC6yEuxd2UVQZcRddRHrgkUKc/view?usp=sharing). (Need permission)

-   [Check CATCLOUD Read-Write Credentials for `orderdata` here.](https://docs.google.com/document/d/1ZA-Q5pPdhPyOwZrjfHl99TfyRz67P2BN245LV4TydvQ/edit?usp=sharing) (Need permission)

## 4. Step-By-Step Example
### Example 1: Runspec Generation via `moves_anywhere` repo and RStudio
This walks through one example run in MOVES Emission Rates Mode, including generating a runspec using `custom_rs()`.
1. Clone this repository and open in RStudio
2. Add your `runapikey.json` file to the root `moves_anywhere` folder.
3. Locate `moves_anywhere/demos/demo_run/workflow_rate.R`
4. Alter any parameters on line 19 that you wish to configure your runspec.
5. Run this file line by line. This will create a custom runspec, create a bucket, and trigger the MOVES job. If you get errors at any step, skip to Troubleshooting.
6. Check on the status/success of the job [here.](https://console.cloud.google.com/run/jobs?authuser=1&project=moves-runs&supportedpurview=project)

#### Troubleshooting
- `Error in library(catr) : there is no package called ‘catr’` and/or `Error: repeated formal argument 'folder' (trigger_run.R:10:24)`
    - Run in R console: `install.packages("../../catr/catr_0.1.0.tar.gz", repos=NULL, type="source", dependencies=TRUE)`
- `Error: lexical error: invalid char in json text. ../../runapikey.json (right here) ------^`
    - Make sure you have `runapikey.json` in your root folder.

### Example 2: Custom Input Run with premade runspec
1. On the [Google Storage Buckets page](https://console.cloud.google.com/storage/browser?forceOnBucketsSortingFiltering=true&authuser=1&hl=en&project=moves-runs&supportedpurview=project&prefix=&forceOnObjectsSortingFiltering=false), click on "CREATE +".
2. Name your bucket according to the naming convention `d<geoid>-u<userid>-o<orderid>`. Click "Continue".
3. Change "Location Type" to "Region" and select us-central1 (Iowa). If you select another region, the automatic triggering of the MOVES run may not work. 
4. Click "Continue" and do so for the rest of the bucket creation process, using the default settings and clicking "Confirm" on the pop-up window at the end.
5. In your newly created bucket, upload any custom input files.
6. Upload the runspec (must be called `rs_custom.xml`) which triggers the job.
7. Check on the status/success of the job [here.](https://console.cloud.google.com/run/jobs?authuser=1&project=moves-runs&supportedpurview=project)

#### Troubleshooting
- `Container terminated on signal 7.`
    - We think this is an "out of memory" error. You can increase the memory and CPU by going to Job execution > YAML and editing the file:
    ```
    limits:
            cpu: 1000m
            memory: 4Gi
    ```
    - Increase each of these limits by x2 (in this example, cpu = 2000m and memory = 8Gi).
    - Rerun the task ("Execute").
 
  
 
  

