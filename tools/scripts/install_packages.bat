@rem Pip Install all required packages for the PE
@rem TODO: save the packages needed to install nbconvert
@echo off
setlocal

set lcl=
if "%1"=="local" set lcl=local
set condasrc=
if "%lcl%"=="local" set condasrc=--offline --override-channels --channel %cd%\condachannel

@rem Make sure superset of lib/setup.py
@rem Main lib packages
call :InstallConda "pip==9.0.1"
call :InstallConda "numpy=1.13.1=py35_0"
call :InstallConda "Scipy==0.19.1"
call :Install "statsmodels==0.8.0"
call :Install "pandas==0.20.3"
@rem call :Install tensorflow
call :Install "scikit-learn==0.19.0"

@rem For building docs
call :InstallConda "sphinx==1.6.3"

@rem For ploting in the examples
call :Install matplotlib==2.1.0

@rem Eventually for the cli version
@rem call :Install click

@rem Building the package and wheel
call :Install "pylint==1.5.4"
call :Install "docutils=0.14"

@rem Don't currently use the financial tools in mseadapters
@rem call :Install "pandas-datareader==0.4.0"

@rem Don't currently use the sql tools in msecore
@rem call :Install "pyodbc==4.0.16"

@rem Don't currently need all of jupyter, just nbconvert
@rem call :InstallConda jupyter==1.0.0
call :InstallConda nbconvert==4.2.0
call :InstallConda ipython==5.1.0

@rem Dependencies for the pip-required ones
call :InstallConda asn1crypto
call :InstallConda cffi
call :InstallConda cryptography
call :InstallConda future
call :InstallConda idna
call :InstallConda pycparser

IF "%lcl%"=="local" (
    call :LocalPip
) ELSE (
    call :RemotePip
)

goto :Done


:RemotePip
call :InstallPip xmlrunner
call :InstallPip azure-storage
call :InstallPip "autograd==1.1.13"
call :InstallPip https://cntk.ai/PythonWheel/CPU-Only/cntk-2.0-cp35-cp35m-win_amd64.whl
call :InstallPip "recommonmark==0.4.0"
goto :EOF

:LocalPip
call :InstallPip "pip\autograd-1.1.13.tar.gz"
call :InstallPip "pip\azure_nspkg-2.0.0-py2.py3-none-any.whl"
call :InstallPip "pip\azure_common-1.1.8-py2.py3-none-any.whl"
call :InstallPip "pip\azure_storage-0.36.0-py2.py3-none-any.whl"
call :InstallPip "pip\cntk-2.0-cp35-cp35m-win_amd64.whl"
call :InstallPip "pip\xmlrunner-1.7.7.tar.gz"
call :InstallPip "pip\recommonmark-0.4.0.tar.gz"
goto :EOF

:LocalPi
@rem Could be alternative to LocalPip
@rem Need to fix the file-path so that it's recognized
@rem Also a bit wasteful as the index stores files also stored in condachannel

@rem how to build local Python Index
@rem https://github.com/wolever/pip2pi
@rem pip install pip2pi
@rem mkdir pippi
@rem pip2pi pippi --no-symlink azure-storage https://cntk.ai/PythonWheel/CPU-Only/cntk-2.0-cp35-cp35m-win_amd64.whl  autograd==1.1.11 xmlrunner

set pipsrc=--index-url=file://pippi/simple
call :InstallPip xmlrunner
call :InstallPip azure-storage
call :InstallPip "autograd==1.1.13"
call :InstallPip "cntk=2.0"
goto :EOF

:Install
@rem Use conda for now (statsmodel requires conda and we don't want to reinstall the dependencies with slightly different verions)
call :InstallConda %1
@rem call :InstallPip %1
goto :EOF

:InstallPip
echo.
echo ####################################
echo Installing %1
echo ####################################
call pip install --upgrade-strategy only-if-needed %pipsrc% %1
goto :EOF

:InstallConda
echo.
echo ####################################
echo Installing %1
echo ####################################

@rem Conda Custom Channels: (https://conda.io/docs/user-guide/tasks/create-custom-channels.html)
@rem conda install conda-build
@rem mkdir condachannel/win-64
@rem mkdir condachannel/noarch
@rem Looked for packages that were installed.
@rem Copy those files from from <Anaconda_root>\pkgs (e.g. C:\Users\<username>\AppData\Local\Continuum\Anaconda3\pkgs) to condachannel/win-64
@rem > conda index condachannel/win-64
@rem > conda index condachannel/noarch

call conda install --no-update-deps %condasrc% -y %1
goto :EOF

:Done
endlocal
exit /b %ERRORLEVEL%
