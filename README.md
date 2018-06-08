Pricing Engine
============
DESCRIPTION
--------
The Pricing Engine is price-aware forecasting used for decision making.

Python requirements: We use Python 3.5. See `tools/scripts/install_packages.bat` for a tool to install the specific package versions required and for which usages they are required.

Please also see this package's [License](lib/LICENSE.txt) and the Microsoft's [Privacy & Cookies](https://go.microsoft.com/fwlink/?LinkId=521839) statement


INSTALLATION
--------
### Prerequisites
What follows are instructions how to install on our "main" environment. See below for an additionally supported AML Workbench environment. The Pricing Engine requires a `Python==3.5` and the package `Scipy==0.19.1`. If you do not already have Scipy installed, it [can be difficult on Windows](https://stackoverflow.com/questions/28190534/windows-scipy-install-no-lapack-blas-resources-found). On Anaconda distributions you can install it easily:

```batch
conda install Scipy==0.19.1
```

You will additionally need `numpy==1.13.1`, `pandas==0.20.3`, `scikit-learn==0.19.0`, and `statsmodels== 0.8.0`. Then you should be able to install the Pricing Engine via: 

Optional packages: `matplotlib` (graphs), `cvxopt==1.1.9` (for Synthetic Control features), `jupyter==1.0.0` (for the notebook examples)

We have done limited testing to ensure that the AzureML Workbench environment works as well: `numpy==1.11.3`, `pandas==0.19.2`, `scipy==0.18.1`, `scikit-learn==0.18.1` (you will need to install `statsmodels==0.8.0`). 

Note: Newer versions of packages may work but given our currently limited resources they are currently not tested or supported (contact us if you have specific environment specifications).

We have only tested the package on Windows 10 and Windows Server 2012R2 environments.

### Local
You can install the wheel by downloading it from the `pkgrepo` folder and using
```batch
pip install pricingengine-X.X.X-py3-none-any.whl
```

USAGE
--------
See the `lib/examples` folder.

See documentation at [https://bquistorff.github.io/pricingengine/index.html](https://bquistorff.github.io/pricingengine/index.html).

