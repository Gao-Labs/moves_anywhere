## `moves_anywhere` with Docker

- Summary by Junna Chen (January 2024)
- Note: Some of this content may be out of date. We aim to update this as soon as possible.


## Getting Started

To run this software, you'll need to...
1. Install [Docker Engine](https://docs.docker.com/engine/install/) on your computer
2. (Optional) Install [RStudio](https://posit.co/download/rstudio-desktop/) or a Python IDE for an easier time interacting with this code.
3. Download this [`moves_anywhere` Github Repository](https://github.com/Gao-Labs/moves_anywhere/) repository!

### Windows Development

If running on a windows device:
- Install [Git Bash](https://git-scm.com/downloads) on your computer, to run Bash shell scripts

## Tutorial

There are two ways you can interact with this repository. If you use R and have RStudio installed, see [Running With RStudio](https://github.com/Gao-Labs/moves_anywhere/tree/main?tab=readme-ov-file#running-with-rstudio). Otherwise, you can [Run With the Command Line](https://github.com/Gao-Labs/moves_anywhere/tree/main?tab=readme-ov-file#running-with-command-line). 

### Running with Rstudio

For a comprehensive walkthrough, view [our recent Training Video](https://vod.video.cornell.edu/media/MOVES+Anywhere+Training/1_d97n2qdm) of `moves_anywhere` for Cornell's Gao Labs Workshop in February 2024.
  1. Open an RStudio session. Navigate to the demos folder and open demo1.sh
  2. Run the script line by line
  
### Running with Command Line

  1. Ensure that Docker Desktop is open. You can do this by navigating to your applications and clicking on the app icon.
  2. Using either the terminal (MacOS) or GitBash (Windows), navigate to the demos folder in the moves_anywhere repository that you downloaded from Github.
  3. In the command line, run `./demos/demo0/testme.sh`. This will perform the setup for the system as well as build and run the docker container.
     - You will know the docker container is running when you see a line starting with `root` and ending with `cat-api`.
     - If you get a permission denied message, run `chmod 777 ./demos/demo0/testme.sh` to set the file to executable
  5. Run `bash launch.sh`. This will perform all the setup for MOVES and the run itself.
     - Once you see the prompt `BUILD SUCCESSFUL`, the MOVES run has finished.
  6. Now, we are done with MOVES. Post-processing functions will begin to execute. To get back to the script, run the `exit` command. You may need to run this twice.
     - If you want to explore within the docker container, you can do so now (do not run the `exit` command)
     - At this point, the formatted output data has been copied to your machine

#### Exploring Data Manually Within the Docker Container

First, we must restart the container and navigate into it: 

1. Restart the container with `docker start dock`
2. Navigate into the container with `docker exec -it dock bash`
This will allow you to interact with the container through the command line. To explore the data, you can start R with the command `R` or you can work with SQL directly with the command `mysql`. 
- If using R:
  - Load relevant libraries such as dplyr, DBI, RMariaDB, readr, and catr
  - Connect to the database you want to explore with `con = catr::connect(type = "mariadb", "dbname")`, replacing dbname with the database. Using this connection, you can check the results of your run by looking into different tables.
  - For additional functionality, refer to [step 5](https://github.com/Gao-Labs/moves_anywhere/blob/main/demos/demo1.sh#L151C1-L151C73) in demo1.sh
- If interacting with SQL directly:
  - `SHOW DATABASES;` will provide all the databases on the mySQL server
  - `USE dbname;` will select the database. Most of the moves output data is located in the `moves` database
  - Once you have selected a database, you can see all the tables in the database with `SHOW TABLES;`. These tables contain data outputted by moves. You can interact with the tables using various SQL SELECT statements.

### Before Starting Another Run

Ensure that you have no dangling images. You can do this in 2 ways: manually or command line.

#### Manually Deleting Images
Navigate to Docker Desktop and manually deleting any moves-related images and containers listed

#### Using the Command Line to Remove Dangling Images
Run the following commands: 
1. `docker stop dock`
2. `docker rm dock`
3. `docker rmi $(docker images -q -f "dangling=true");`
