project="${VVV_SITE_NAME}"

echo "Commencing Bedrock Setup"

# Make a database, if we don't already have one
echo "Creating database"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS $project"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON $project.* TO wp@localhost IDENTIFIED BY 'wp';"

# Download Bedrock
if [ ! -d public_html ]
then

  # Nginx Logs
  echo "Creating logs"
  mkdir -p ${VVV_PATH_TO_SITE}/log
  touch ${VVV_PATH_TO_SITE}/log/error.log
  touch ${VVV_PATH_TO_SITE}/log/access.log

  echo "Installing Bedrock stack using Composer"

  # TODO: change eval to cd ${VVV_PATH_TO_SITE}/public_html or use mkdir command
  eval cd .. && composer create-project roots/bedrock public_html

  # Start download Sage theme
  echo "Downloading Sage Theme"
  eval cd public_html/web/app/themes
  git clone https://github.com/roots/sage.git $project-theme
  eval cd $project-theme
  composer install && npm install
  eval cd ../
  # End download theme

  # Start download Understrap theme and child theme
  echo "Downloading Understrap Theme"
  git clone https://github.com/understrap/understrap.git $project-understrap
  eval cd $project-understrap
  npm instal
  echo "Downloading Understrap Child Theme"
  cd ../
  git clone https://github.com/understrap/understrap-child.git $project-understrap-child
  eval cd $project-understrap-child
  npm install
  # End download theme
fi

# The Vagrant site setup script will restart Nginx for us

echo "$project Bedrock is now installed";

echo "Configuring Nginx";

cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf.tmpl" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"

if [ -n "$(type -t is_utility_installed)" ] && [ "$(type -t is_utility_installed)" = function ] && `is_utility_installed core tls-ca`; then
    sed -i "s#{{TLS_CERT}}#ssl_certificate /vagrant/certificates/${VVV_SITE_NAME}/dev.crt;#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
    sed -i "s#{{TLS_KEY}}#ssl_certificate_key /vagrant/certificates/${VVV_SITE_NAME}/dev.key;#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
else
    sed -i "s#{{TLS_CERT}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
    sed -i "s#{{TLS_KEY}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
fi

echo "Nginx configured!";
