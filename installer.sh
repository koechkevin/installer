#!/bin/bash
ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE..."
    while IFS='=' read -r key value; do
        if [[ $key != \#* ]]; then
            export "$key"="$value"
        fi
    done < "$ENV_FILE"
    echo "Environment variables loaded successfully."
else
    echo "$ENV_FILE not found."
fi

# Check if Docker is installed and install if not
if ! [ -x "$(command -v docker)" ]; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed and install if not
if ! [ -x "$(command -v docker-compose)" ]; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# Install nvm (Node Version Manager)
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
echo "nvm installed successfully."

# Install Node.js v18 using nvm
echo "Installing Node.js v18..."
nvm install 18
nvm use 18
echo "Node.js v18 installed successfully."

# Install Yarn
echo "Installing Yarn..."
npm install -g yarn
echo "Yarn installed successfully."

if [ -n "$USE_LOCAL_DB" ]; then
    cd database
    docker-compose --env-file=../.env up --build -d
    cd ..
else
    echo "USE_LOCAL_DB variable does not exist or is empty"
fi
# Clone or update inventory-management repository
REPO_DIR="inventory-management"
REPO_URL="https://github.com/koechkevin/inventory-management.git"

if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning inventory-management repository..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Updating inventory-management repository..."
    cd "$REPO_DIR"
    git pull
    cd ..
fi
cp .env $REPO_DIR
echo "Setting up inventory-management repository..."
cd "$REPO_DIR"
yarn
yarn prod:up
echo "inventory-management repository set up successfully."
cd ..
# Clone or update inventory-frontend repository
REPO_DIR="inventory-frontend"
REPO_URL="https://github.com/koechkevin/inventory-frontend.git"

if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning inventory-frontend repository..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Updating inventory-frontend repository..."
    cd "$REPO_DIR"
    git pull
    cd ..
fi
cp .env $REPO_DIR
echo "Setting up inventory-frontend repository..."
cd "$REPO_DIR"
yarn
export NODE_ENV=production
yarn prod:up
echo "inventory-frontend repository set up successfully."
cd ..

echo "Server starting"
cd server
docker-compose up --build -d
cd ..
