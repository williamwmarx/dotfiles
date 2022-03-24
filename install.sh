#!/bin/bash
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install xcode tools
xcode-select --install

# Install brew utils
brew install dockutil exa fd ffmpeg fzf guetzli htop imagemagick m-cli mas node openssl p7zip python@3.10 ripgrep tor

# Install brew casks
brew install --cask adobe-creative-cloud asana blackhole-16ch clay cycling74-max docker dropbox figma firefox glyphs iina kitty little-snitch mullvadvpn parallels raycast rhino signal zoom

# Install app store apps
mas install 1592917505
mas install 1532801185
mas install 1290358394
mas install 975937182
mas install 1346203938
mas install 1569813296
mas install 1544743900
mas install 1365531024
mas install 409183694
mas install 409201541
mas install 409203825

# Install 1Password
curl -fsSLo 1password.pkg https://app-updates.agilebits.com/download/OPM7
sudo installer -pkg 1password.pkg -target /

# Setup dock
dockutil --remove all
dockutil --add /Applications/Fantastical.app/
dockutil --add /Applications/Safari.app/
dockutil --add /Applications/Texts.app/
dockutil --add /Applications/Clay.app/
dockutil --add /Applications/Toggl\ Track.app/
dockutil --add /Applications/OmniFocus.app/
dockutil --add /Applications/kitty.app/
dockutil --add /System/Applications/Notes.app/
dockutil --add /System/Applications/Music.app/
dockutil --add /Applications/Adobe\ Illustrator\ 2022/Adobe\ Illustrator.app/
dockutil --add /Applications/Adobe\ Photoshop\ 2022/Adobe\ Photoshop.app/
dockutil --add /Applications/Glyphs\ 3.app/
dockutil --add /System/Applications/System\ Preferences.app/
dockutil --add /Applications/1Password.app

# Move files
mv .vimrc ~/
mv .zshrc ~/
mv .gitconfig ~/
mv wwm.zsh-theme ~/.oh-my-zsh/themes/
mv kitty.conf ~/.config/kitty/
mv clear-format.sh ~/.raycast/tools/
mkdir -p ~/.vim/templates
mv skeleton.py ~/.vim/templates/

# Edit settings
m hostname citadel
m appearance darkmode YES
m wallpaper /System/Library/Desktop\ Pictures/Solid\ Colors/Black.png
m airdrop off

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "NO"

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Open other apps to install
open https://www.ableton.com/
open https://brain.fm/
open https://texts.com/install/macos
