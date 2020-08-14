#!/bin/zsh
# Generate new ssh key
ssh-keygen -t rsa -b 4096 -C "$(git config --global user.email)"

# Clone dotfiles repo
git clone git@github.com:victorprs/dotfiles.git
ln -s dotfiles/git/.gitconfig .gitconfig
ln -s dotfiles/git/.gitignore .gitignore_global

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
source ~/.zshrc
ln -s dotfiles/zsh/.zshrc .zshrc
source ~/.zshrc

# Improve pacman conf
sed '/^# Misc options/a ILoveCandy' /etc/pacman.conf | sudo tee /etc/pacman.conf > /dev/null

# Update and install programs from pacman
sudo pacman-mirrors --fasttrack 5
sudo pacman -Syyu
sudo pacman -S zsh terminator yay firefox-developer-edition vim neovim docker \
                docker-compose base-devel diff-so-fancy glu mesa wxgtk2 libpng \
                fop htop python-psycopg2 workrave dbeaver keepass
sudo pacman -Rcns firefox
# Set zsh shell as default
sudo chsh -s $(which zsh)
# Fix docker bs
sudo usermod -aG docker $USER

# Install more programs from yay
curl -sS https://download.spotify.com/debian/pubkey.gpg | gpg --import -
yay -S visual-studio-code-bin spotify redshift telegram-desktop heroku-cli

# Install asdf-vm and some plugins
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0-rc1

echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
source .zshrc

asdf plugin-add erlang
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
asdf install erlang latest
asdf global erlang $(asdf list erlang)

asdf plugin-add elixir
asdf install elixir latest
asdf global elixir $(asdf list elixir)

asdf plugin-add python
asdf install python latest
asdf global python $(asdf list python)

asdf reshim python

asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs latest
asdf global nodejs $(asdf list nodejs)

# Start redshift
nohup redshift -t 4700:4700 -b 0.77:0.77 -P >/dev/null 2>&1 &

# Change system swappiness
echo 10 | sudo tee /proc/sys/vm/swappiness > /dev/null