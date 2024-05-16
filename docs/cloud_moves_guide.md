# Cloud MOVES Guide

Lead Developer: Tim Fraser, PhD

Contributors: Erin Murphy

## 0. Using Cornell Cloud MOVES (Alpha - for Cornell CAT Research Team only)

An exciting current research direction of the Cornell CAT MOVES team is the development of Cornell Cloud MOVES, a system for executing MOVES runs in the Cloud. This technology is currently in Alpha mode, available only for CAT research team members only with permission. Please see below for details on how to execute it.

### Objectives of Cloud MOVES

What are we trying to do with Cloud MOVES, and what aren't we trying to do?

-   Get emission inventory from `movesoutput` output tables from a MOVES run, for 1 geoid-year pair.

-   Get emission rates from `rateperdistance` and `ratepervehicle` output tables from a MOVES run, for 1 geoid-year pair.

## 1. Requirements for Cornell Cloud MOVES

### 1.1 Requirements

To use Cornell Cloud MOVES, you will need the following items.

| Name          | Description                                                                                                                  |
|--------------|----------------------------------------------------------|
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

### 1.2 Test Users

| ID | Name         |
| -  | ----------   |
| 1  | Test Account |
| 2  | Tim          |
| 3  | Erin         |
| 4  | Carl         |
| 5  | Alireza      |
| 6  | Tolkein      |
| 7  | Baby MOVES   |


## 2. Cloud MOVES Process

Cloud MOVES is run on Google Cloud, making use of the Workflows API, Cloud Run API, and Cloud SQL API, among others. The basic idea is as follows:

### Workflow: rs-to-moves

-   Add any custom input `.csv`s to the bucket.

-   Optionally add a `parameters.json` file, including the fields `mode`, `geoaggregation`, and `timeaggregation` if you want to customize your job memory settings. See below.

-   Add `rs_custom.xml` to the bucket. This is the trigger event that kicks off a cloud upload job. This step must always occur [**LAST**]{.underline}**.**

#### Figure 1: Triggering a MOVES Run Job

``` mermaid
flowchart LR  bucket csv["custom inputs"] rs["runspec"]  create_bucket[["create<br>bucket"]] add_files[["add files"]] add_rs[["add rs_custom.xml"]] workflow_moves["workflow<br><b>moves</b>"] create_job[["create job<br>& mount bucket"]] image_moves["image<br><b>moves:v1</b>"] container_moves["run<br>container<br><b>moves</b>"] output_csvs["output .csvs"]  create_bucket ---> bucket csv --> add_files --> bucket rs --> add_rs add_rs --> trigger_moves add_rs --> bucket  trigger_moves("trigger<br><b>rs-to-moves</b>") bucket --> trigger_moves  trigger_moves --> workflow_moves  image_moves ---> create_job workflow_moves --> create_job --> container_moves  bucket --- create_job  container_moves --> output_csvs  output_csvs -- Put Outputs back in Bucket --> bucket
```

**Note:** **Setting Memory, Processors, and Timeout for your Job**

Each Workflow execution creates a job which runs a container from the `moves` image. Your container can be run with various different settings for `memory`, `cpu`, and `timeout`. By default, your container will run with `memory = 4Gi,``image_cpu = 1000m, image_timeout = 600s`. But if you upload a `parameters.json` that contains the fields `mode`, `geoaggregation`, and `timeaggregation` (among others), it will set the `image_memory`, `image_cpu` , and `image_timeout` fields automatically to match our expectations of their needs, via a series of conditions. These settings tentatively look like this:

```         
   - check_run_type:
        switch:
            # Inventory / County / Year = 6 minutes
            - condition: ${ parameters.body.mode == "inv" and parameters.body.geoaggregation == "county" and parameters.body.timeaggregation == "year" }
              assign:
                - image_memory: '4Gi'
                - image_cpu: '1000m'
                - image_timeout: '600s'

            # Inventory / State / Year = 15 minutes??
            - condition: ${ parameters.body.mode == "inv" and parameters.body.geoaggregation == "state" and parameters.body.timeaggregation == "year" }
              assign:
                - image_memory: '4Gi'
                - image_cpu: '1000m'
                - image_timeout: '1200s'

            # Inventory / Nation / Year = 15 minutes??
            - condition: ${ parameters.body.mode == "inv" and parameters.body.geoaggregation == "nation" and parameters.body.timeaggregation == "year" }
              assign:
                - image_memory: '4Gi'
                - image_cpu: '1000m'
                - image_timeout: '1200s'

            # Rates / County / Year -->  <20 minutes
            - condition: ${ parameters.body.mode == "rates" and parameters.body.geoaggregation == "county" and parameters.body.timeaggregation == "year" }
              assign:
                - image_memory: '4Gi'
                - image_cpu: '1000m'
                - image_timeout: '1200s'

            # Rates / County / Hour --> ~30 minutes?
            - condition: ${ parameters.body.mode == "rates" and parameters.body.geoaggregation == "county" and parameters.body.timeaggregation == "hour" }
              assign:
                - image_memory: '8GiB'
                - image_cpu: '2000m'
                - image_timeout: '1800s'

            # Rates / Link / Hours = ~2.5 hours?
            - condition: ${ parameters.body.mode == "rates" and parameters.body.geoaggregation == "link" and parameters.body.timeaggregation == "hour" }
              assign:
                - image_memory: '32Gi'
                - image_cpu: '8000m'
                - image_timeout: '10800s'

            # If none of the above, then use these specs
            - condition: true
              next: default_run_type
```

### Workflow: data-to-upload

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

This walks through one example run in MOVES Emission Rates Mode, including generating a runspec using `custom_rs()`. 1. Clone this repository and open in RStudio 2. Add your `runapikey.json` file to the root `moves_anywhere` folder. 3. Locate `moves_anywhere/demos/demo_run/workflow_rate.R` 4. Alter any parameters on line 19 that you wish to configure your runspec. 5. Run this file line by line. This will create a custom runspec, create a bucket, and trigger the MOVES job. If you get errors at any step, skip to Troubleshooting. 6. Check on the status/success of the job [here.](https://console.cloud.google.com/run/jobs?authuser=1&project=moves-runs&supportedpurview=project)

#### Troubleshooting

-   `Error in library(catr) : there is no package called ‘catr’` and/or `Error: repeated formal argument 'folder' (trigger_run.R:10:24)`
    -   Run in R console: `install.packages("../../catr/catr_0.1.0.tar.gz", repos=NULL, type="source", dependencies=TRUE)`
-   `Error: lexical error: invalid char in json text. ../../runapikey.json (right here) ------^`
    -   Make sure you have `runapikey.json` in your root folder.

### Example 2: Custom Input Run with premade runspec

1.  On the [Google Storage Buckets page](https://console.cloud.google.com/storage/browser?forceOnBucketsSortingFiltering=true&authuser=1&hl=en&project=moves-runs&supportedpurview=project&prefix=&forceOnObjectsSortingFiltering=false), click on "CREATE +".
2.  Name your bucket according to the naming convention `d<geoid>-u<userid>-o<orderid>`. Click "Continue".
3.  Change "Location Type" to "Region" and select us-central1 (Iowa). If you select another region, the automatic triggering of the MOVES run may not work.
4.  Click "Continue" and do so for the rest of the bucket creation process, using the default settings and clicking "Confirm" on the pop-up window at the end.
5.  In your newly created bucket, upload any custom input files.
6.  Upload the runspec (must be called `rs_custom.xml`) which triggers the job.
7.  Check on the status/success of the job [here.](https://console.cloud.google.com/run/jobs?authuser=1&project=moves-runs&supportedpurview=project)

## Troubleshooting

### Issue: Timing

Right now, we're running into issues when trying to run simple inventory county-year jobs in 1990, 1999, and 2000. It's not entirely clear what's going on. So far, we've run into these errors, which suggest to me that there's an issue with Ethanol-85 (`fueltype == 5`). Ethanol 85 wasn't formally introduced until 1993\~1996. Fortunately, runs starting in 2005 work perfectly fine right now.

```         
  # # These fuel formulations have ETOH volume under 10,
  # # so MOVES is throwing a fit, wants to reclassify them as fuelSubTypeID = 13
  # # ERROR: Missing: Warning: Fuel formulation 2675 changed fuelSubtypeID from 12 to 13 based on ETOHVolume
  # # ERROR: Missing: Warning: Fuel formulation 2676 changed fuelSubtypeID from 12 to 13 based on ETOHVolume
  # # ERROR: Missing: Warning: Fuel type 5 is imported but will not be used
  # 
```

Things I have tried to resolve this:

-   [x] removing modifications to `fuelsupply` –\> NOPE

```{=html}
<!-- -->
```
-   [x] removing modifications to `fuelusagefraction` –\> NOPE

-   [x] adding modifications to `fuelformulation` –\> NOPE.

-   [x] Running with `ram=4Gi` and `cpu=1000m`

-   [x] Running with `ram=32Gi` and `cpu=8000m`

-   [x] Changing the fuelsubtype of fuel formulation 2675 and 2676 from 12 to 13. –\> NO CHANGE.

-   [x] Switching `max_allowed_packet` responsible from 1M to 10M.

-   [x] Switching `max_allowed_packet` responsible from 1M to 1024M.

-   [x] Switching `innodb_buffer_pool_size` to 2500000000 (2.5GB)

-   [x] Checking whether 1999 works –\> it does not.

-   [x] Checking whether 2000 works –\> it does not.

-   [x] Checking whether 2001 works –\> [it does]{.underline}!

-   [x] Checking whether it runs better with fewer pollutants –\> NOPE.

-   [x] Checking whether it runs better with fewer sourcetypes –\> NOPE.

-   [x] Filter out `fuelformulation` `2675` and `2676` –\> Removes error, but sitll ends early.

-   [x] Try running just passenger cars.

-   [x] Add debugging step

-   [x] removing modifications to `avft` —\> Didn't help. AVFT is required.

-   [x] Try filtering by `fueltype` in adapt. Didn't really help. Had to remove them.

-   [x] Check whether 2000 works again. –\> Nope.

-   [x] Check whether 2000 works with more pollutants. –\> Nope.

-   [x] Check whether 2000 works with more sourcetypes. –\> Nope.

-   [ ] Conclusion: Tentatively, focus on 2001 to 2060 for Cloud MOVES runs.

### Issue: `innodb` settings and packet size

### Issue: Database Connection

### 

### Issue: Signal 7

-   `Container terminated on signal 7.`

    -   We think this is an "out of memory" error. You can increase the memory and CPU by going to Job execution \> YAML and editing the file:

    ```         
    limits:
            cpu: 1000m
            memory: 4Gi
    ```

    -   Increase each of these limits by x2 (in this example, cpu = 2000m and memory = 8Gi).
    -   Rerun the task ("Execute").
