export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@ph-notebook\[\e[m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
export TERM=xterm-256color
alias grep="grep --color=auto"
alias ls="ls --color=auto"

echo -e "\e[1;31m"
cat << "TF"
    _   __                      ______                 __                   
   / | / /__  __  ___________  / ____/________ _____  / /_  ___  _________ _
  /  |/ / _ \/ / / / ___/ __ \/ / __/ ___/ __ `/ __ \/ __ \/ _ \/ ___/ __ `/
 / /|  /  __/ /_/ / /  / /_/ / /_/ / /  / /_/ / / / / /_/ /  __/ /  / /_/ / 
/_/ |_/\___/\__,_/_/   \____/\____/_/   \__,_/_/ /_/_.___/\___/_/   \__, /  
                                                                   /____/  


TF
echo -e "\e[0;33m"

if [[ $EUID -eq 0 ]]; then
  cat <<WARN
WARNING: You are running this container as root, which can cause new files in
mounted volumes to be created as the root user on your host machine.

To avoid this, run the container by specifying your user's userid:

$ docker run -u \$(id -u):\$(id -g) args...
WARN
else
  cat <<EXPL
You are running this container as user with ID $(id -u) and group $(id -g),
which should map to the ID and group for your user on the Docker host. Great!
EXPL
fi

# Turn off colors
echo -e "\e[m"
