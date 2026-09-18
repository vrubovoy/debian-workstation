# =============================================================================
# Development-specific abbreviations
# =============================================================================
#
# Preserved from the previous workstation configuration.
#
# The corresponding development tools are intentionally NOT installed as part
# of the base home workstation.
#
# These abbreviations become useful automatically if the tools are installed
# later.
#
# =============================================================================


# =============================================================================
# SEGGER J-Link
# =============================================================================

abbr --add j  'JLinkExe -nogui 1 -commandfile'

abbr --add jf \
    'JLinkExe -nogui 1 -commandfile flash/flash.jlink'

abbr --add je \
    'JLinkExe -nogui 1 -commandfile flash/erase.jlink'


# =============================================================================
# OpenOCD
# =============================================================================

abbr --add of \
    'openocd -f flash/script.cfg -f flash/flash.ocd'

abbr --add oe \
    'openocd -f flash/script.cfg -f flash/erase.ocd'