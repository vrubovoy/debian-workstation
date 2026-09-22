# =============================================================================
# Fish — abbreviations
# =============================================================================
#
# Abbreviations expand in place, so history keeps the full command.
#
# Path:  ~/.config/fish/conf.d/30-abbreviations.fish

abbr --add ..  'cd ..'
abbr --add ... 'cd ../..'
abbr --add .3  'cd ../../..'
abbr --add .4  'cd ../../../..'
abbr --add .5  'cd ../../../../..'

abbr --add mkdir 'mkdir -p'
abbr --add disk  duf

abbr --add ls 'eza --group-directories-first --icons=auto'
abbr --add l  'eza -la --group-directories-first --icons=auto'
abbr --add ll 'eza -lah --git --group-directories-first --icons=auto'
abbr --add ld 'eza -lahD --group-directories-first --icons=auto'
abbr --add lt 'eza --tree --level=2 --group-directories-first --icons=auto'

abbr --add g  git
abbr --add lg lazygit
abbr --add vc codium
abbr --add p  python3

abbr --add m  'make -j8'
abbr --add mc 'make clean'

# Embedded flashing; the tools themselves are not installed by the workstation.
abbr --add j  'JLinkExe -nogui 1 -commandfile'
abbr --add jf 'JLinkExe -nogui 1 -commandfile flash/flash.jlink'
abbr --add je 'JLinkExe -nogui 1 -commandfile flash/erase.jlink'
abbr --add of 'openocd -f flash/script.cfg -f flash/flash.ocd'
abbr --add oe 'openocd -f flash/script.cfg -f flash/erase.ocd'
