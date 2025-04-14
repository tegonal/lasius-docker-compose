# Lasius

This is a companion repo for Lasius, the open source time tracking solution for teams. This repo will allow you to spin
up a demo instance of Lasius in a few minutes on your local machine or on a server.

This setup currently provides two different configurations:

1. testing: Local instance based on demo instance populated with demo data and started with the local oauth provider
2. production: Local instance with an empty database attached to a local keycloak provider. Customize the setup to your needs or hook in other oauth providers

If you are looking for the source-code visit the [main repo](https://github.com/tegonal/lasius).

## Online demo

If you just want to have a look around without the need for any setup, you can check out our online demo
at [demo.lasius.ch](https://demo.lasius.ch) with the following login credentials:

User: demo1@lasius.ch, Password: demo

## The obligatory public beta disclaimer

1. Lasius is in use in production at [Tegonal](https://tegonal.com). We are using it to track our own time, but we
   cannot guarantee that it will work for you.
2. We plan to continuously improve Lasius to fit our needs and add new features that a broad audience might find useful.
   If you have any feedback, please let us know.
3. We currently only offer amd64 images. If there is enough demand, we will add support for other architectures.

## Requirements

```
$ uname -m
x86_64

$ docker version -f "{{.Server.Version}}"
23.0.1
```

- Your system needs to have [Docker](https://www.docker.com/) installed, with compose as a docker plugin.
- You should have at least 2GiB of RAM available

## Setup

```
git clone https://github.com/tegonal/lasius-docker-compose.git
cd lasius-docker-compose

# Run setup script
./setup.sh

# Start the containers
./start.sh

# Stop the containers
./stop.sh

# Update this repo and restart the containers
./update.sh
```

## Usage

### Testing

1. Go to `http://localhost:8080` in your browser. Use a different port if you changed it in the setup script.
2. Login using demo1@lasius.ch / demo
3. Have a look around

### Production

1. Enter the hostname you defined during setup in your browser.
2. Register a new user with the local Keycloak provider, or log in with one of the configured external oauth providers.
3. Create organisations, projects, invite users and start tracking time.

### If you like Lasius, we can help you with deployment and maintenance

If you would like to use Lasius in a commercial setting, please contact us
at [info@tegonal.com](mailto:info@tegonal.com). We can manage your deployment and provide support for your team.

## Customization

### Terms of Service

You can require users to accept your Terms of Service before they are able to use Lasius. To enable this feature,
answer 'yes' to the corresponding question during setup in production mode. Then, edit the template files in
`production/termsofservice/` to reflect your Terms of Service. There is one HTML file per supported language
(e.g. `en.html` for English).

Please note that if you update those files later, you also have to change `LASIUS_TERMSOFSERVICE_VERSION` in
`production/.env` and restart the service in order to force users to accept the updated version of the terms.

### Local Keycloak oauth provider

In production mode, the local oauth provider can be managed at `https://{hostname}/keycloak/`. The login
credentials are `admin` and an automatically generated password `KEYCLOAK_ADMIN_PWD`, which can be found in
`production/.env`.

## Terms of use

Lasius is licensed under Gnu Affero General Public License v3.0. Please read the [LICENSE](LICENSE) file for more
information. Lasius comes with no warranty.
