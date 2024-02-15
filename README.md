# `moves_anywhere`

- Developers: Tim Fraser, Junna Chen
- Contributors: Mahak Bindal, Shungo Najima, Carl Closs, Erin Murphy
- Description: A Docker-based solution to run MOVES anywhere - on Windows, Mac, or Linux

## Getting Started
To run this software, you'll need to...
1. Install [Docker Engine](https://docs.docker.com/engine/install/) on your computer
2. (Optional) Install [RStudio](https://posit.co/download/rstudio-desktop/) or a Python IDE for an easier time interacting with this code.
3. Download this [`moves_anywhere` Github Repository](https://github.com/Gao-Labs/moves_anywhere/) repository!

### Windows Development
If running on a windows device:
- Install [Git Bash](https://git-scm.com/downloads) on your computer, to run Bash shell scripts

## Tutorial
- See `demos/demo1.sh`!
  
### Running with Command Line
  1. Ensure that Docker Desktop is open. You can do this by navigating to your applications and clicking on the app icon.
  2. Using either the terminal (MacOS) or GitBash (Windows), navigate to the demos folder in the moves_anywhere repository that you downloaded from Github.
  3. In the command line, run `./demo1_command.sh`. This will perform the setup for the system as well as build and run the docker image.
     - You will know the docker image is running when you see a line starting with `root` and ending with `cat-api`.
     - If you get a permission denied message, run `chmod 777 demo1_command.sh` to set the file to executable
  5. Run `bash launch.sh`. This will perform all the setup for MOVES and the run itself.
     - Once you see the prompt `BUILD SUCCESSFUL`, the MOVES run has finished.
  6. Now, we are done with MOVES. To get back to the script, run the `exit` command. You may need to run this twice.
     - At this point, the formatted output data has been copied to your machine

### Running with Rstudio
- View [our recent Training Video](https://vod.video.cornell.edu/media/MOVES+Anywhere+Training/1_d97n2qdm) of `moves_anywhere` for Cornell's Gao Labs Workshop in February 2024.

### Before Starting Another Run
Ensure that you have no dangling images. You can do this in 2 ways: manually versus command line.
#### Manually Deleting Images
Navigate to Docker Desktop and manually deleting any moves-related images and containers listed
#### Using the Command Line to Remove Dangling Images
Run the following commands: 
1. `docker stop dock`
2. `docker rm dock`
3. `docker rmi $(docker images -q -f "dangling=true");`
