# PERLscripting image
Image built atop centos:7 with PERL5 and various libraries. Image contains no actual PERL scripts, you have to supply them.

## Image versioning
This image is versioned by our dockerfile version, it is not tied to PERL version in any way.

Naming scheme is as follows: **bcv-perlscripting:GENERAL_VERSION-rIMAGE_VERSION**.
- Image name is **bcv-perlscripting**.
- **GENERAL_VERSION** is a version defined by BCV developers. Version change signifies changes more or less according to SemVer.
- **IMAGE_VERSION** is an image release version written as a serial number, starting at 0. When images have the same general versions but different image versions it means there were some cosmetic changes in the image itself (i.e. bugfixes).

Example:
```
bcv-perlscripting:1.0-r0    // first release of PERLscripting 1.0 image
bcv-perlscripting:1.0-r2    // third release of PERLscripting 1.0 image
bcv-perlscripting:27.4-r0    // first release of PERLscripting 27.4 image
```

## Building
Simply cd to the directory which contains the Dockerfile and issue `docker build --no-cache -t <image tag here> ./`.

The build process:
1. Pulls **centos:7** image.
1. Updates binaries inside the image.
1. Installs vendored PERL (`v5.16.3` in CentOS 7).
1. Downloads and sets up Oracle InstantClient and Oracle::DBD from CPAN.
1. Creates startup scripts structure inside **/runscripts** folder in the image. If you want to add your scripts to the runscripts, simply place them between sources and run the build process.

## Use
After setup scripts finish, they execute `/opt/scripts/entrypoint.sh` which is a start for the real work to be performed.

Mount a directory with your PERL scripts as the `/opt/scripts` inside the container. Supply your own `entrypoint.sh` to start them. Your script will run under `perlscripting` user. When the container is about to shut down, all processes running as `perlscripting` user will receive SIGTERM.

## Container startup and hooks
Bootup process of the container:
1. Script **/runscripts/run.sh** is executed. This script allows you to set "breakpoints" that make script **sleep** for 3600 seconds in specific places. Those places are **RUNONCE_BREAKPOINT** (after script initialization, but before runOnce.sh is executed), **RUNEVERY_BREAKPOINT** (after runOnce.sh, but before runEvery.sh is executed), **STARTPERL_BREAKPOINT** (after runEvery.sh, but before startPerl.sh is executed). Those places allow you to connect into the container with `docker exec -it CONTAINER bash` and investigate its state and possible issues. To take effect, debug variable must be set but its contents do not matter.
1. The **run.sh** executes **/runscripts/runOnce.sh**.
  1. **runOnce.sh** checks if there is a **runOnce.done** file present. If it is, the **runOnce.sh** does nothing and exits.
  1. The **runOnce.done** contains timestamp of the time when **runOnce.sh** actually ran.
  1. If there is no **runOnce.done** file, it means the container was started for the first time ever and it may be necessary to perform some initialization steps.
  1. **runOnce.sh** executes all scripts in the **/runscripts/runOnce.d/** directory in an alphabetical order.
  1. You can hook up your custom runOnce script(s) by adding them into the **runOnce.d/**. Naming convention is: **IMAGENUM_SCRIPTNUM-userDefinedName.sh**.
    1. **IMAGENUM** - Number of image in the series. This image has a number **000**. If you create new image atop of it, you should use **001** as your image number.
    1. **SCRIPTNUM** - Serial number of the script for current image number. For example, if you already have **000_000-baseline.sh** script in the folder, you add another script as **000_001-doSomething.sh** (in case you remain in base image).
    1. **userDefinedName.sh** - Your naming of the script. The **.sh** suffix is mandatory.
1. After finishing with **runOnce.sh**, the run.sh executes **/runscripts/runEvery.sh** script.
  1. Philosophy of this script(s) is the same as for the **runOnce.sh** and **runOnce.d/**.
  1. Only difference is, the **runEvery.sh** is executed **every time the container starts**.
  1. Custom scripts are located in the **runEvery.d/** directory.
1. After finishing with **runEvery.sh**, the run.sh executes **startPerl.sh**.
1. The **startPerl.sh** simply runs `/opt/scripts/entrypoint.sh` under `perlscripting` user.

All runscripts scripts run as **root** user.

## Container shutdown
When initialized and running, the process tree in container looks like this:
```
run.sh
|___ startPerl.sh
     |___ sudo -Eu perlscripting /opt/scripts/entrypoint.sh
          |___ perl ... parameters ... (your PERL scripts or application)
```
Upon shutdown, Docker sends `SIGTERM` to the **run.sh** process. This process traps the SIGTERM and sends it to **every process running under the perlscripting user**, thus terminating the application. The **run.sh** also waits until all processes of perlscripting user terminate or until the **STOP_TIMEOUT** is reached. Afterwards, it waits another 1 second to let startPerl.sh script terminate too.

Please note that Docker also implements timeout for container shutdowns. If the **STOP_TIMEOUT** is set too high, it may be overriden by Docker from the outside and Docker will kill the container before stop timeout is reached.

## Environment variables
You can pass a number of environment variables into the container.
- **STOP_TIMEOUT** - Number of seconds (at most) the **run.sh** will wait for PERL to terminate. May be overriden by Docker itself (by killing the container). **Default: 15s**.
- **RUNONCE_BREAKPOINT** - When set (even to empty string), causes **run.sh** to sleep for 3600s so you can exec into the container and look around.
- **RUNEVERY_BREAKPOINT** - When set (even to empty string), causes **run.sh** to sleep for 3600s so you can exec into the container and look around.
- **STARTPERL_BREAKPOINT** - When set (even to empty string), causes **run.sh** to sleep for 3600s so you can exec into the container and look around.
- **TZ** - **On the first start** of the container, we set the timezone. Syntax is [IANA tzdata](https://www.iana.org/time-zones) (the same you know from Linux). **Default: UTC**.

## Mounted files and volumes
- Mandatory
  - Directory with PERL scripts
    - This directory contains all your PERL scripts and an entrypoint script.
    - Without this direcotry mounted, the container will do no real work.
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./scripts
          target: /opt/scripts
          read_only: false
      ```
- Optional
  - Trusted certificates directory
    - This directory contains certificates, that the PERL will trust. It replaces OS certificate truststore inside the container.
    - Without this directory mounted, PERL will trust all certificates the OS inside container does.
    - With this directory mounted, trust anchors will be completely replaced. If this is not what you want, explicitly mount your CA certificate into the directory inside container.
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./certs
          target: /etc/pki/ca-trust/source/anchors
          read_only: true
      ```

## Forbidden variables
- **RUNSCRIPTS_PATH** - Defined in the Dockerfile and used during both build of the image and life of the container. This is a root folder from which the startup scripts locate each other. If you change it, the container start process will go haywire. For safety reasons, this variable is set as `readonly` in the **run.sh**.
- **SCRIPT_HOME** - Defined in the Dockerfile, this variable points to a root directory where PERL scripts are located.
