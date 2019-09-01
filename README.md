# GitOps Continuous Deployment

## Create Kubernetes Cluster

Setup the default preference in Google Cloud

```
gcloud config set project <your project's name>
gcloud config set compute/zone <your cluster's zone>
gcloud config set compute/region <your cluster's region>
```

Create the first container cluster

```
gcloud container clusters create <your cluster's name> \
--machine-type <your cluster's machine> \
--disk-type <your cluster's disk type> \
--disk-size <your cluster's disk size (GB)> \
--num-nodes <your cluster's nodes count> \
--no-enable-autoupgrade
```

Delete the existing container cluster

```
gcloud container clusters delete <your cluster's name>
```

## Create GitHub Repository

Grant access to Google Cloud

## Setup Cloud Build

- Go to [Cloud Build](https://console.cloud.google.com/cloud-build) Page
- Create an new trgger and follow up the steps to setup github repository
- Set the cloud build yaml path and the trigger condition

This is a sample to build and push docker image to `Container Registry`

```
steps:
- id: Build
  name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/${PROJECT_ID}/<your image's name>:${SHORT_SHA}', '.']
  timeout: 500s

- id: Push
  name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/${PROJECT_ID}/<your image's name>:${SHORT_SHA}']
```

## Deployment in Cloud Build

Choose some tool to manage the Kubernetes's manifest, and it will let the deployment simply

### Kustomize

Create an new builder by `Cloud Build`, and push image to `Container Registry`

```
git clone https://github.com/GoogleCloudPlatform/cloud-builders-community
cd cloud-builders-community/kustomize
gcloud builds submit . --config=cloudbuild.yaml
```

Add the step in your `cloudbuild.yaml`

```
- id: Change image
  name: 'gcr.io/${PROJECT_ID}/kustomize'
  args: ['edit', 'set', 'image', '<your image's name>=gcr.io/${PROJECT_ID}/<your image's name>:${SHORT_SHA}']
  env:
    - 'CLOUDSDK_COMPUTE_ZONE=<your cluster's zone>'
    - 'CLOUDSDK_CONTAINER_CLUSTER=<your cluster's name>'
    - 'GCLOUD_PROJECT=${PROJECT_ID}'

- id: Deploy by Kustomize
  name: 'gcr.io/${PROJECT_ID}/kustomize'
  args: ['build', '<your kustomization's path>']
  env:
    - 'APPLY=true'
    - 'CLOUDSDK_COMPUTE_ZONE=<your cluster's zone>'
    - 'CLOUDSDK_CONTAINER_CLUSTER=<your cluster's name>'
    - 'GCLOUD_PROJECT=${PROJECT_ID}'
```

The file structure

```
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── service.yaml
└── overlays
    ├── dev
    │   ├── cpu_count.yaml
    │   ├── kustomization.yaml
    │   └── replica_count.yaml
    └── prod
        ├── cpu_count.yaml
        ├── kustomization.yaml
        └── replica_count.yaml
```

Reference:
- https://github.com/kubernetes-sigs/kustomize
- https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/kustomize

### Helm

Create an new builder by `Cloud Build`, and push image to `Container Registry`

```
git clone https://github.com/GoogleCloudPlatform/cloud-builders-community
cd cloud-builders-community/helm
gcloud builds submit . --config=cloudbuild.yaml
```

Add the step in your `cloudbuild.yaml`

```
- id: Deploy by Helm
  name: 'gcr.io/${PROJECT_ID}/helm'
  dir: 'cicd/helm'
  args:
    - 'upgrade'
    - '--install'
    - 'helmdev'
    - '.'
    - '-f'
    - 'values.yaml'
    - '--set'
    - 'image.repository=gcr.io/${PROJECT_ID}/<your image's name>'
    - '--set'
    - 'image.tag=${SHORT_SHA}'
  env:
    - 'CLOUDSDK_COMPUTE_ZONE=<your cluster's zone>'
    - 'CLOUDSDK_CONTAINER_CLUSTER=<your cluster's name>'
```

The file structure

```
├── Chart.yaml
├── charts
├── templates
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   └── service.yaml
├── values-dev.yaml
├── values-prod.yaml
└── values.yaml
```

Reference:
- https://helm.sh/
- https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/helm
