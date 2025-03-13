variable "BuildSpecFileNameForAPI" {
    type = string
    description = "Name of buildspec file for CodeBuild project."
  
}
variable "GitHubRepoName" {
    type = string
    description = "The GitHub repo name"
}
variable "GitHubRepoBranch" {
    type = string
    description = "The GitHub repo branch code pipelines should watch for changes on."
}
variable "GitHubUser" {
    type = string
    description = "GitHub UserName. This username must have access to the GitHubToken."
    default = "Ravi CHand"  
}
variable "GitHubToken" {
    type = string
    description = "Secret. OAuthToken with access to Repo. Long string of characters and digits. Go to https://github.com/settings/tokens"
}
variable "SAMOutputFile" {
    type = string
    description = "The filename for the output SAM file from the buildspec file."
}
variable "SAMInputFile" {
    type = string
    description = "The filename for the SAM file."
}
variable "CodeBuildImage" {
    type = string
    description = "Image used for CodeBuild project."
    default = "aws/codebuild/standard:7.0" 
}
variable "ParametersFile" {
    type = string
    description = "The filename for the cloudformation parameters."
}
variable "AppName" {
    type = string
    description = "Name of the application."
}