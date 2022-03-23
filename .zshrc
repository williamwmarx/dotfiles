################################################################################
# Information
################################################################################
# Maintained by WWM (wwm@marx.design)
# 🄯 Copyleft 2021, All Wrongs Reserved
# Included in Zumthor (https://github.com/darwinoss/zumthor)
# Released into the Public Domain via CC0 1.0
# Certified Platinum under the OmniOpen Initiative


################################################################################
# Base Installs
################################################################################
# ----------------------------- Oh-my-zsh Install -----------------------------
if [[ ! -d $HOME/.oh-my-zsh ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
		"" --unattended --keep-zshrc
fi

# ------------------------------ Oh-my-zsh Theme ------------------------------
if [[ ! -f $HOME/.oh-my-zsh/themes/wwm.zsh-theme ]]; then
	curl -fsSLo ~/.oh-my-zsh/themes/wwm.zsh-theme \
		https://raw.githubusercontent.com/darwinoss/zumthor/master/zsh/theme
fi

# ----------------------- Oh-my-zsh syntax highlighting -----------------------
if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
		${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# ------------------------- Oh-my-zsh autosuggestions -------------------------
if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions \
		${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi


################################################################################
# Config
################################################################################
# ------------------------------ Oh-my-zsh Config -----------------------------
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="wwm"
plugins=(zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# ---------------------------- ARM64 Homebrew PATH ----------------------------
if [[ `uname -sp` == "Darwin arm" ]]; then export PATH="${PATH:+${PATH}:}/opt/homebrew/bin"; fi

# --------------------------------- Fzf Config --------------------------------
if [[ `which fzf &>/dev/null && echo "$?"` -eq 0 ]]; then
	if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then export PATH="${PATH:+${PATH}:}$HOME/.fzf.bin"; fi

	[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2>/dev/null

	if [[ `which fd &>/dev/null && echo "$?"` -eq 0 ]]; then  # If fd is available, use it
		_fzf_compgen_path() { fd -HLE ".git" -E "Library" . $1 }
		_fzf_compgen_dir() { fd -HLtd -E ".git" -E "Library" . "$1" }
	fi

	if [[ `which bat &>/dev/null && echo "$?"` -eq 0 ]]; then  # If bat is available, use it
		export FZF_COMPLETION_OPTS="--preview-window 'right:60%' --preview 'bat --style=numbers \
			--color=always {}'"
	else  # Otherwise use cat
		export FZF_COMPLETION_OPTS="--preview-window 'right:60%' --preview 'cat {}'"
	fi

	# source "$HOME/.fzf/shell/key-bindings.zsh"  # Source key bindings
fi

################################################################################
# Aliases
################################################################################
# --------------------------------- General -----------------------------------
if [[ `uname` == "Darwin" ]]; then
	alias o="open ."  # Open current directory (macOS Only)
	if [[ `uname -m` == "arm64" ]]; then
		alias d64-run="arch -x86_64 docker run --platform linux/amd64"  # Docker x86_64 images on M1
	fi
elif [[ `uname` == "Linux" ]]; then
	alias pbcopy="xsel --clipboard --input"  # macOS's pbcopy for Linux
	alias pbpaste="xsel --clipboard --output"  # macOS's pbpaste for Linux
fi

alias ds="cd ~/Desktop"
alias dc="cd ~/Documents"
alias dl="cd ~/Downloads"
alias tree="exa -T"
alias tarxz="tar cfJ"  # Compress to .tar.xz archive
alias python2="python"
alias python="/opt/homebrew/bin/python3"
alias macspoof="sudo ifconfig en0 ether $(openssl rand -hex 6 | sed 's%\(..\)%\1:%g; s%.$%%')"
alias framecount="ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0"
alias suffixes="python -c \"import pathlib; import glob; print(set([pathlib.Path(x).suffix for x in glob.glob('**/*')]))\""
alias icat="kitty +kitten icat"

# ---------------------------- ARM64 Homebrew PATH ----------------------------
if [[ -d "/Users/wwm/Library/Python/3.9/bin" ]]; then
	export PATH="${PATH:+${PATH}:}$HOME/Library/Python/3.9/bin"
fi
if [[ -d "/Users/wwm/Library/Python/3.10/bin" ]]; then
	export PATH="${PATH:+${PATH}:}$HOME/Library/Python/3.10/bin"
fi

################################################################################
# Functions
################################################################################
# SMOL
function smol() {
	# Make y4m
	echo "Converting to y4m"
	ffmpeg -hide_banner -loglevel error -i $1 -pix_fmt yuv420p "${1%.*}.y4m"
	# Make opus
	echo "Extracting audio and converting to opus"
	ffmpeg -hide_banner -loglevel error -i $1 -q:a 0 -map a -c:a libopus -b:a 256K "${1%.*}.opus"
	# Print framecount
	echo "Framecount: $(framecount $1)"
	# Convert to ivf
	rav1e --threads=10 "${1%.*}.y4m" --output "${1%.*}.ivf"
	# Attach audio and save as mkv
	ffmpeg -hide_banner -loglevel error -i "${1%.*}.ivf" -i "${1%.*}.opus" -c:v copy -c:a copy "${1%.*}.mkv"
	# Remove tmp files
	rm "${1%.*}.y4m" "${1%.*}.ivf" "${1%.*}.opus"
	echo "Done"
}

function img2() {
	for IMG in *.(jpg|png|jpeg); do convert $IMG "${IMG%.*}.$1"; done
	rm *.(png|jpg|jpeg)
}

function img3() {
	for IMG in **/*.(JPG|PNG); do convert $IMG "${IMG%.*}.$1"; done
	rm **/*.(JPG|PNG)
}


# --------------------------------- exa > ls -----------------------------------
function ls() {
	if [[ `which exa &>/dev/null && echo "$?"` -eq 0 ]]; then exa $@
	else ls $@; fi
}

# -------------------------------- exa > tree ----------------------------------
function tree() {
	if [[ `which exa &>/dev/null && echo "$?"` -eq 0 ]]; then exa -T $@
	else tree $@; fi
}

# ------------------------------------- ip ------------------------------------
function ip() {
	case $1 in
		-l|--local) ifconfig en0 | grep inet | awk '$1=="inet" {print $2}';;
		-p|--public) curl -fSSL https://ipecho.net/plain ; echo;;
		*) echo -e "Fetch local and public IP addresses\n\nUsage: ip [OPTIONS]\n\nOptions:";
			 echo -e "  -l, --local\tLocal IP address\n  -p, --public\tPublic IP address\n";;
	esac
}

# ------------------------------- Clipboard OCR -------------------------------
# Run OCR on clipboard image and copy text back to clipboard
if [[ `uname` == "Darwin" ]]; then
	function cbocr() {
		# Save clipboard image to .cbocr.tmp so we can use tesseract
		osascript &>/dev/null <<EOF
			set tmpFile to (open for access POSIX file ".cbocr.tmp" with write permission)
			try
				write (the clipboard as JPEG picture) to tmpFile
			end try
			close access tmpFile
EOF
		# Run OCR on image, pipe into clipboard, and delete temp image
		tesseract .cbocr.tmp stdout 2>/dev/null | pbcopy; rm .cbocr.tmp
	}
fi

# ---------------------------------- OmniOpen ---------------------------------
function omniopen() {
	if [[ ! -f CODE_OF_CONDUCT.md ]]; then
		curl -fsSLo CODE_OF_CONDUCT.md \
			https://raw.githubusercontent.com/concurrent-studio/OmniOpen/master/CODE_OF_CONDUCT.md
	fi

	if [[ ! -f LICENSE.md ]]; then
		curl -fsSLo LICENSE.md \
			https://raw.githubusercontent.com/concurrent-studio/OmniOpen/master/LICENSE.md
	fi

	[[ ! -f SOURCES.md ]] && touch SOURCES.md
	[[ ! -f CONTRIBUTING.md ]] && touch CONTRIBUTING.md
}

if [[ ! "$PATH" == *$HOME/Library/Python/3.8/bin* ]]; then export PATH="${PATH:+${PATH}:}$HOME/Library/Python/3.8/bin"; fi


# ---------------------------------- Manpager ---------------------------------
export MANPAGER="vim -M +MANPAGER --not-a-term -"

################################################################################
# Startup
################################################################################
# ---------------------------- Launch tmux on start ---------------------------
# if [[ `which tmux &>/dev/null && echo "$?"` -eq 0 ]]; then
# 	# First session named "main". Others named alt0, alt1, alt2, ...
# 	if [[ -z "$TMUX" ]]; then
# 		LASTSESSION=`tmux ls 2>/dev/null | awk -F":" '{print $1}' | sort | tail -2 | head -1`
# 		if [[ $LASTSESSION == main ]]; then
# 			tmux new -s alt0
# 		elif [[ $LASTSESSION == alt* ]]; then
# 			NUMBER=$(( 10#$(echo $LASTSESSION | grep -Eo '\d+') + 1 ))
# 			tmux new -s alt$NUMBER
# 		else
# 			tmux new -s main
# 		fi
# 	fi
# fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/.poetry/bin:$PATH"
