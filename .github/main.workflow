workflow "Deploy to Droplet" {
  on = "repository_dispatch"
  resolves = ["Create Droplet"]
}

action "Create Droplet" {
  uses = "actions/bin/sh@0e80959"
  env = {
    DROPLET_NAME = "post2slack-01"
    DROPLET_REGION = "sfo2"
    DROPLET_SIZE = "s-1vcpu-1gb"
  }
  secrets = ["DIGITAL_OCEAN_API_TOKEN"]
  args = "curl -X POST -H \"Content-Type: application/json\" -H \"Authorization: Bearer $DIGITAL_OCEAN_API_TOKEN\" -d '{\"name\": \"$DROPLET_NAME\", \"region\": \"$DROPLET_REGION\", \"size\": \"$DROPLET_SIZE\", \"image\": \"debian-9-x64\"}'"
}
