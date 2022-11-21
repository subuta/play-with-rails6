# play-with-rails6

### How to develop

```
# Run rails new for creating boilerplate (only first time)
# SEE: https://qiita.com/masuidrive/items/7478fb9101652f2bbae1
docker run --rm -v `pwd`:/usr/src/app ruby:3.0.4 sh -c "curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get update -qq && apt-get install -qq --no-install-recommends nodejs && npm i yarn -g && gem install rails && rails new /usr/src/app --database postgresql --force --version 6"

# Pull base images.
docker pull heroku/buildpacks:20
docker pull heroku/pack:20

# Build web image by buildpack
# SEE: [Cloud Native Buildpacks · Cloud Native Buildpacks](https://buildpacks.io/)
# Pass `-u501` means run this command as UID:501 user.
docker run -u501: -v /var/run/docker.sock.raw:/var/run/docker.sock -v $PWD:/workspace -w /workspace --entrypoint=pack buildpacksio/pack:0.27.0 build play-with-rails6_web_prod --clear-cache --pull-policy if-not-present --builder heroku/buildpacks:20
# Or run custom npm script
npm run build

# Start development server/db.
docker-compose up
# Or run custom npm script
npm run dev

# Start production server with production image(built by buildpack)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
# Or run custom npm script
npm run start

# Create/Migrate database if needed.
docker-compose exec web bundle exec rake db:create
docker-compose exec web bundle exec rake db:migrate
```

### How to deploy your app with "AWS AppRunner"

#### Prerequisites

- AWS CLI
  - `~/.aws/config` and `~/.aws/credentials` should be configured properly.
- Docker

AWS ECR Repository needs to be initialized manually from AWS Web console.

```bash
# -p profile : Profile name, no default value.
# -e [stg|prod] : Environment name, defaults to "prod".
# -t tag : Tag name, defaults to "latest".
# -i image : Image name, defaults to "play-with-rails6_web".
# -v verbose : Show debug log.
$ ./bin/ecr-deploy.sh --profile "${AWS_PROFILE}" -e prod -t latest -i play-with-rails6_web
```

After successful deployment(push) of Docker image to ECR,
You can setup "ECR to AppRunner" deployment from AWS Web console.

Check official article [Introducing AWS App Runner | Containers](https://aws.amazon.com/jp/blogs/containers/introducing-aws-app-runner/) for further steps needed for deployment.

### Update deployed service

```bash
# Build latest image.
npm run build

# Do push Docker image into ECR.
# If you use "Repository type: Container registry" and set Deployment trigger to "Automatic", this "push" action results new deployment of AppRunner service.
./bin/ecr-deploy.sh --profile "${AWS_PROFILE}" -e prod -t latest -i play-with-rails6_web
```