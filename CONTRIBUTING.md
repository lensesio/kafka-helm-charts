# Contributing Guidelines

**First off, thanks for taking the time to contribute!**

The Kafka Helm Charts project accepts contributions via GitHub pull requests. This document outlines the process to help get your contribution accepted. The document was adapted from the [Contributing to Helm Charts](https://github.com/helm/charts) document.

## How to Contribute a Chart

1. Fork this repository, develop and test your Chart. 
1. Choose the correct folder for your chart as it is already structured.
1. Ensure your Chart follows the [technical](#technical-requirements) and [documentation](#documentation-requirements) guidelines, described below.
1. Bump version of the chart.
1. Submit a pull request.

***NOTE***: In order to make testing and merging of PRs easier, please submit changes to multiple charts in separate PRs.

### Technical requirements

* All Chart dependencies should also be submitted independently
* Must pass the linter (`helm lint`)
* Must successfully launch with default values (`helm install .`)
    * All pods go to the running state (or NOTES.txt provides further instructions if a required value is missing
    * All services have at least one endpoint
* Images should not have any major security vulnerabilities
* Must be up-to-date with the latest stable Helm/Kubernetes features
    * Use Deployments in favor of ReplicationControllers
* Should follow Kubernetes best practices
    * Include Health Checks wherever practical
    * Allow configurable [resource requests and limits](http://kubernetes.io/docs/user-guide/compute-resources/#resource-requests-and-limits-of-pod-and-container)
* Provide a method for data persistence (if applicable)
* Support application upgrades
* Allow customization of the application configuration
* Provide a secure default configuration
* Do not leverage alpha features of Kubernetes
* Follows [best practices](https://github.com/helm/helm/tree/master/docs/chart_best_practices)
  (especially for [labels](https://github.com/helm/helm/blob/master/docs/chart_best_practices/labels.md)
  and [values](https://github.com/helm/helm/blob/master/docs/chart_best_practices/values.md))

### Documentation requirements

* Must include an in-depth `README.md`, including:
    * Short description of the Chart
    * Any prerequisites or requirements
    * Customization: explaining options in `values.yaml` and their defaults
* Must include a short `NOTES.txt`, including:
    * Any relevant post-installation information for the Chart
    * Instructions on how to access the application or service provided by the Chart

### Merge approval and release process

A Kafka Helm Charts maintainer will review the Chart submission, and start a validation job in the CI to verify the technical requirements of the Chart. No pull requests can be merged until at least one maintainer signs off with an approve in Github.

Once the Chart has been merged, the release job will automatically run in the CI to package and release the.

## Support Channels

Whether you are a user or contributor, official support channels include:

- GitHub issues: https://github.com/landoop/kafka-helm-charts/issues
- Slack community: https://launchpass.com/landoop-community

Before opening a new issue or submitting a new pull request, it's helpful to search the project - it's likely that another user has already reported the issue you're facing, or it's a known issue that we're already aware of.