variable "location" {
  description = "The location for the Google Cloud Build trigger."
  type        = string
}

variable "project_id" {
  description = "The ID of the project where the pipeline will be created."
  type        = string
}

variable "pipeline_id" {
  description = "The ID of the pipeline."
  type        = string
}

variable "description" {
  description = "The description of the Cloud Build trigger."
  type        = string
}

variable "service_account_id" {
  description = "Id of a specific service account for the pipeline."
  type        = string
  default     = null
}

variable "env" {
  description = "Environment label for the pipeline (e.g. dev, prod)."
  type        = string
  default     = null
}

variable "repo_type" {
  description = "The type of repo to monitor (SOURCEREPO, GITHUB, GITHUB_V2)"
  type        = string
  default     = "SOURCEREPO"
}

variable "v2_repo_id" {
  description = "Full resource ID of a Cloud Build v2 repository (projects/.../connections/.../repositories/...). Required when repo_type = GITHUB_V2."
  type        = string
  default     = null
}

variable "repo_name" {
  description = "The name of the repository."
  type        = string
}

variable "repo_branch_regexp" {
  description = "A Regular Expression branch name of the repository."
  type        = string
}

variable "repo_trigger" {
  description = "The type of trigger on the repo (PUSH, PULL_REQUEST)"
  type        = string
  default     = "PUSH"
}

variable "build_policies" {
  description = "List of build policies for the Cloud Build service account in the cross project."
  type = list(object({
    role        = string
    title       = optional(string)
    description = optional(string)
    expression  = optional(string)
  }))
  default = []
}

variable "deploy_project_id" {
  description = "The ID of the project where the built resources will be deployed."
  type        = string
}

variable "deploy_policies" {
  description = "List of deploy policies for the Cloud Build service account in the destination project."
  type = list(object({
    role        = string
    title       = optional(string)
    description = optional(string)
    expression  = optional(string)
  }))
}

variable "deploy_act_as_service_account" {
  description = "A list of service accounts in the project where resources are deployed to act as"
  type        = list(string)
  default     = []
}

variable "steps" {
  description = "List of steps to be performed by Cloud Build."
  type = list(object({
    name       = string
    args       = optional(list(string))
    script     = optional(string)
    entrypoint = optional(string)
  }))
}

variable "substitutions" {
  description = "Subsititution data for the Cloud Build environment."
  type        = map(string)
  default     = {}
}

variable "timeout" {
  description = "The timeout for the Cloud Build trigger."
  type        = string
  default     = "600s"
}

variable "machine_type" {
  description = "The machine type for the Cloud Build trigger."
  type        = string
  default     = null
}

variable "env_vars" {
  description = "List of environment variables in the format KEY=VALUE."
  type        = list(string)
  default     = []
}

variable "logging" {
  description = "Logging configuration for Cloud Build."
  type        = string
  default     = null
}

variable "ignored_files" {
  description = "List of files to be ignored by the Cloud Build trigger."
  type        = list(string)
  default     = []
}

variable "included_files" {
  description = "List of files to be included by the Cloud Build trigger."
  type        = list(string)
  default     = []
}

variable "map_substitutions_to_env_vars" {
  description = "Map substitutions to environment variables."
  type        = bool
  default     = false
}

variable "map_base_substitutions_to_env_vars" {
  description = "Map base substitutions to environment variables."
  type        = bool
  default     = false
}

variable "read_artifacts_repos" {
  description = "The list of artifacts repositories to read from. format: project/location/repository"
  type        = list(string)
  default     = []
}
