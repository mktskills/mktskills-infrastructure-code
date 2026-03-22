# Artifacts Registry Repository Module

## Module Code
*gcp_artreg_repo*

## Description

This Terraform module is designed to create and manage Artifact Registry repositories in Google Cloud Platform. The module can configure repositories for various formats, including Docker, Maven, NPM, and Python. It allows you to create standard repositories, virtual repositories, and remote repositories. Additional features include the ability to use customer-managed encryption keys, configure Docker images with immutable tags, and set policies for Maven artifacts.

The module also provides support for remote repositories by configuring upstream policies, which can be set for each format separately. This allows you to create proxy repositories that act as a cache for packages from remote public repositories. With the virtual repository option, you can aggregate multiple repositories into a single entry point, simplifying the management and retrieval of packages from multiple sources.

## Usage Examples

Create a Docker repository:

```
module "docker_repo" {
  source        = "./modules/gcp_artreg_repo"
  project_id    = "my-gcp-project"
  repository_id = "docker-repo"
  format        = "DOCKER"
  location      = "us-central1"
  description   = "Docker repository for our microservices."
  labels        = { "env" = "prod" }
  mode          = "STANDARD"
}
```

Create a Maven virtual repository that aggregates multiple repositories:

```
module "maven_virtual_repo" {
  source        = "./modules/gcp_artreg_repo"
  project_id    = "my-gcp-project"
  repository_id = "maven-virtual-repo"
  format        = "MAVEN"
  location      = "us-central1"
  description   = "Maven virtual repository that aggregates multiple repositories."
  mode          = "VIRTUAL_REPOSITORY"
  virtual_repo_upstream_policies = [
    {
      id         = "repo1"
      repository = "maven-repo1"
      priority   = 1
    },
    {
      id         = "repo2"
      repository = "maven-repo2"
      priority   = 2
    }
  ]
}
```

Create a remote NPM repository with public NPM registry as upstream:

```
module "npm_remote_repo" {
  source        = "./modules/gcp_artreg_repo"
  project_id    = "my-gcp-project"
  repository_id = "npm-remote-repo"
  format        = "NPM"
  location      = "us-central1"
  description   = "Remote NPM repository that proxies the public NPM registry."
  mode          = "REMOTE_REPOSITORY"
  remote_repo_address = "https://registry.npmjs.org"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The ID of the Google Cloud project to create the artifact registry repository in. | `string` | n/a | yes |
| repository_id | The unique ID for the artifact registry repository. | `string` | n/a | yes |
| format | The format of the packages that will be stored in the repository (DOCKER, MAVEN, NPM, or PYTHON). | `string` | n/a | yes |
| location | The location (region) where the artifact registry repository should be created. | `string` | n/a | yes |
| description | The description of the artifact registry repository. | `string` | n/a | yes |
| labels | A set of key-value pairs to associate with the repository as labels. | `map(string)` | `{}` | no |
| kms_key_name | The resource name of the customer-managed encryption key (KMS key) used for encryption. | `string` | `null` | no |
| mode | The mode of the repository (REMOTE_REPOSITORY, VIRTUAL_REPOSITORY, or STANDARD_REPOSITORY). | `string` | `"STANDARD_REPOSITORY"` | no |
| docker_immutable_tags | A list of tags that should be considered immutable for Docker repositories. | `bool` | `false` | no |
| maven_allow_snapshot_overwrites | Whether to allow overwriting of snapshot artifacts for Maven repositories. | `bool` | `false` | no |
| maven_version_policy | The version policy (RELEASE, SNAPSHOT, or MIXED) for Maven repositories. | `string` | `"VERSION_POLICY_UNSPECIFIED"` | no |
| virtual_repo_upstream_policies | A list of upstream policies for virtual repositories. | `list(object({ id=string, repository=string, priority=optional(number) }))` | `[]` | no |
| remote_repo_description | The description for remote repositories. | `string` | `null` | no |
| remote_repo_address | The address of the remote repository to be used as an upstream source. | `string` | `null` | no |
| read_principals | List of principals granted read access to the repo | `list(string)` | `[]` | no |
| write_principals | List of principals granted write access to the repo | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_name | The name of the Artifact Registry repository. |
| repository_id | The ID of the Artifact Registry repository. |
| repository_create_time | The time when the Artifact Registry repository was created. |
| repository_update_time | The time when the Artifact Registry repository was last updated. |
