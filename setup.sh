#!/bin/bash

notify () {
  echo -e "--------------------------------------------------------------------------"
  echo -e "--- $1"
  echo -e "--------------------------------------------------------------------------"
}

notify-start () {
  notify "INSTALLING $1"
}

notify-end () {
  notify "INSTALLED $1"
  echo -e "\n"
}

# Install homebrew
notify-start "HOMEBREW"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
notify-end "HOMEBREW"

# Install normal brews
BREWS=(mas pyenv pyenv-virtualenv rbenv nvm)
for i in "${BREWS[@]}"; do
  notify-start "$(echo $i | awk '{print toupper($0)}')"
  brew install "$i"
  notify-end "$(echo $i | awk '{print toupper($0)}')"
done

# Tap other casks
CASKS=("homebrew/cask-fonts")
for i in "${CASKS[@]}"; do
  notify-start "$(echo $i | awk '{print toupper($0)}')"
  brew tap "$i"
  notify-end "$(echo $i | awk '{print toupper($0)}')"
done

# Install cask brews
CASK_BREWS=(bartender istat-menus iterm2 font-source-code-pro-for-powerline font-fira-code mactex-no-gui intellij-idea visual-studio-code google-chrome spotify vlc)
for i in "${CASK_BREWS[@]}"; do
  notify-start "$(echo CASK\ $i | awk '{print toupper($0)}')"
  brew cask install "$i"
  notify-end "$(echo CASK\ $i | awk '{print toupper($0)}')"
done

# Install apps from Mac App Store
MAS_APPS_AUTO=(Moom ScanSnap\ Cloud Slack Spark WhatsApp\ Desktop Wunderlist)
for i in "${MAS_APPS_AUTO[@]}"; do
  notify-start "$(echo $i | awk '{print toupper($0)}')"
  mas install "$(mas search "$i" | head -n 1 | awk -F ' ' '{print $1}')"
  notify-end "$(echo $i | awk '{print toupper($0)}')"
done

MAS_APPS_MANUAL=(446107677)
for i in "${MAS_APPS_MANUAL[@]}"; do
  notify-start "$(echo $i | awk '{print toupper($0)}')"
  mas install "$i"
  notify-end "$(echo $i | awk '{print toupper($0)}')"
done

# Install zprezto
notify-start "ZPREZTO"
./install_zprezto.sh
notify-end "ZPREZTO"

# Increase maxfiles and maxprocesses limits
PLIST_FILES=(limit.maxfiles.plist limit.maxproc.plist)
for i in "${PLIST_FILES[@]}"; do
  sudo cp ./files/${i} /Library/LaunchDaemons
  sudo chown root:wheel /Library/LaunchDaemons/${i}
  sudo launchctl unload -w /Library/LaunchDaemons/${i} >/dev/null 2>&1
  sudo launchctl load -w /Library/LaunchDaemons/${i}
done