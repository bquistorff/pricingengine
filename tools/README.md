Tools, such as command line applications. 

Build environment
================
We started the project with one set of package dependencies. We then decided to support the Azure ML Workbench environment, which was very similar (slight downgrades of some common packages, a few packages added and few not included). We provide `yml` files of these two environements with all the packages these environments have on our build server. The `root-environment.yml` is the original set of usage dependencies plus the development dependencies (packages we are experimenting with, such as `cntk`, and packages to make the build artifacts, such as docs and examples). The `py35_AML_Workbench-environment.yml` is the Azure ML Workbench environment plus the additional packages needed to use the Pricing Engine. Note that these the `conda` package manager can only be installed in the root environment (we use v4.2.12) so the root env lists this while the AML Workbench one does not. If you want to create an environment from a `yml`, you can:

     conda env create -f py35_AML_Workbench-environment.yml
 If you want to update an existing environment, with the spec in a `yml`, you can

     conda env update -f py35_AML_Workbench-environment.yml

Legacy scripts in that subfolder include:
* `install_packages.bat` which was the old script that installed packages for the original set of dependencies (including development packages) on the build server. Originally we had local packages repositories for all packages. This script includes information on how to setup and modify these as well as options in the install routines to use local packages. The local repo info could be helpful again, but we should use `yml` files for package specs.
* `describe-pkgs.bat` will output the current conda environment to a file

pecmd
====
The `pecmd` project has scripts that can be launched via pecmd/run_cmd.bat. These scripts mainly sync local data sources to remote ones. The twitter one can do some searching.

