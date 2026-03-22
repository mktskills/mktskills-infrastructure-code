variable "project_id" {
  description = "The ID of the Google Cloud project to create the artifact registry repository in."
  type        = string
}

variable "repository_id" {
  description = "The unique ID for the artifact registry repository."
  type        = string
}

variable "format" {
  description = "The format of the packages that will be stored in the repository (DOCKER, MAVEN, NPM, or PYTHON)."
  type        = string
}

variable "location" {
  description = "The location (region) where the artifact registry repository should be created."
  type        = string
}

variable "description" {
  description = "The description of the artifact registry repository."
  type        = string
}

variable "labels" {
  description = "A set of key-value pairs to associate with the repository as labels."
  type        = map(string)
  default     = {}
}

variable "kms_key_name" {
  description = "The resource name of the customer-managed encryption key (KMS key) used for encryption."
  type        = string
  default     = null
}

variable "mode" {
  description = "The mode of the repository (REMOTE_REPOSITORY, VIRTUAL_REPOSITORY, or STANDARD_REPOSITORY)."
  type        = string
  default     = "STANDARD_REPOSITORY"
}

variable "docker_immutable_tags" {
  description = "A list of tags that should be considered immutable for Docker repositories."
  type        = bool
  default     = false
}

variable "maven_allow_snapshot_overwrites" {
  description = "Whether to allow overwriting of snapshot artifacts for Maven repositories."
  type        = bool
  default     = false
}

variable "maven_version_policy" {
  description = "The version policy (RELEASE, SNAPSHOT, or MIXED) for Maven repositories."
  type        = string
  default     = "VERSION_POLICY_UNSPECIFIED"
}

variable "virtual_repo_upstream_policies" {
  description = "A list of upstream policies for virtual repositories."
  type        = list(object({
    id         = string
    repository = string
    priority   = optional(number)
  }))
  default     = []
}

variable "remote_repo_description" {
  description = "The description for remote repositories."
  type        = string
  default     = null
}

variable "remote_repo_address" {
  description = "The address of the remote repository to be used as an upstream source."
  type        = string
  default     = null
}

variable "read_principals" {
  description = "List of principals granted read access to the repo"
  type        = list(string)
  default     = []
}

variable "write_principals" {
  description = "List of principals granted write access to the repo"
  type        = list(string)
  default     = []
}
