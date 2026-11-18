{ ... }:
{
  system = {
    defaults = {
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleShowScrollBars = "Always";
        AppleTemperatureUnit = "Celsius";
        NSAutomaticPeriodSubstitutionEnabled = false;
        # Smart quotes and dashes mangle anything pasted into code or a shell.
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        # Fast key repeat, and press-and-hold off so holding a key repeats it
        # instead of opening the accent picker -- both needed for modal editing.
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        ApplePressAndHoldEnabled = false;
        # Tab reaches every control in dialogs, not just text fields.
        AppleKeyboardUIMode = 3;
        NSWindowResizeTime = 0.1;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
        "com.apple.trackpad.scaling" = 3.0;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      dock = {
        # Always shown on the desktop; full-screen apps still hide it, and the
        # timing below applies there.
        autohide = false;
        autohide-time-modifier = 0.25;
        expose-animation-duration = 0.25;
        mru-spaces = false;
        show-recents = false;
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXPreferredViewStyle = "Nlsv";
        _FXShowPosixPathInTitle = true;
        FXEnableExtensionChangeWarning = false;
      };

      # Click by pressing the trackpad only; a light tap does nothing.
      trackpad.Clicking = false;

      screencapture = {
        location = "~/Pictures/Screenshots";
        type = "png";
        disable-shadow = true;
      };
      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 0;
        ShowSeconds = true;
      };
    };
  };
}
