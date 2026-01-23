# Temporary fix for __version__ import issue
try:
    from . import __version__ as app_version
except ImportError:
    # If import fails, define it here
    __version__ = "0.0.1"
    app_version = __version__

app_name = "freight_management"
required_apps = ["erpnext"]
app_title = "Freight Management"
app_publisher = "Your Name"
app_description = "Freight Management"
app_icon = "octicon octicon-file-directory"
app_color = "grey"
app_email = "your@email.com"
app_license = "MIT"
