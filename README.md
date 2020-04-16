# pave_puppet_agent

`pave_puppet_agent` is designed to support migration of nodes during a side-by-side Puppet Enterprise upgrade. It takes it's name from *nuke and pave*, an old technique to fix systemic desktop issues where you would backup data, erase the hard drive, and reinstall the OS. `pave_puppet_agent` takes a similar, brute-force approach to node / agent migration.

## Description

Currently, `pave_puppet_agent` contains one task which is also called `pave_puppet_agent`. This task automates the brute-force way to migrate nodes to a new PE master, such as is needed during a side-by-side upgrade. 

The `pave_puppet_agent` task has two parameters:

* String `pe_master` - Puppet Enterprise FQDN. This is used to construct the Agent install URL.
* String `pe_masterport` - Puppet master port. Defaults to `8140`. The port over which agent-master communications occur.

### Task operations overview

The task runs the following operations in sequence:

* Stops the current Puppet Agent service
* Checks for the PE master yum repo and deletes it if it exists
* Checks for the directory `/etc/puppetlabs` and deletes it if it exists
* Checks for the directory `/opt/puppetlabs` and deletes it if it exists
* Checks for the Puppet Agent yum package and deletes it if it exists
* Installs new Puppet Agent directly from new PE Master using `curl`
* Kills the first run after agent install (this shortcuts receiving a CSR)
* Invokes `puppet agent -t` to get a CSR to the PE Master

## Setup

### Beginning with pave_puppet_agent

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

```sh
bolt task run -u <user> --password-prompt --no-host-key-check -t <your node> pave_puppet_agent -pe_master=<your master fqdn>
```
