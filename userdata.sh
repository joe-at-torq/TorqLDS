#Install dependencies
sudo apt update
sudo apt install -y python python3-pip net-tools tree python3-flask

#Run App
git clone https://github.com/joe-at-torq/TorqLDS-UI.git
cd TorqLDS-UI/reg-form/
screen ./StartPublic.sh
