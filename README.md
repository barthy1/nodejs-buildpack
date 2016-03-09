# CloudFoundry build pack: Node.js

A Cloud Foundry [buildpack](http://docs.cloudfoundry.org/buildpacks/) for Node based apps.

This is based on the [Heroku buildpack] (https://github.com/heroku/heroku-buildpack-nodejs).

Additional documentation can be found at the [CloudFoundry.org](http://docs.cloudfoundry.org/buildpacks/).

This version was adopted to support ppc64le architecture.
This version cannot be used without manual manipulations to get Node.js binaries. See the [IBM SDK for Node.js](#ibm-sdk-for-nodejs) section.

## Usage

This buildpack will get used if you have a `package.json` file in your project's root directory.

```bash
cf push my_app -b https://github.com/cloudfoundry/buildpack-nodejs.git
```

## Disconnected environments
To use this buildpack on Cloud Foundry, where the Cloud Foundry instance limits some or all internet activity, please read the [Disconnected Environments documentation](https://github.com/cf-buildpacks/buildpack-packager/blob/master/doc/disconnected_environments.md).

### Vendoring app dependencies
As stated in the [Disconnected Environments documentation](https://github.com/cf-buildpacks/buildpack-packager/blob/master/doc/disconnected_environments.md), your application must 'vendor' it's dependencies.

For the NodeJS buildpack, use ```npm```:

```shell 
cd <your app dir>
npm install # vendors into /node_modules
```

```cf push``` uploads your vendored dependencies.

### Additional extensions
In cached mode, [use the semver node_module](bin/compile#L30-32) (as opposed to http://semver.io) to resolve the correct node version. The semver.io service has an additional preference for stable versions not present in the node module version. We wrap the node module using [lib/version_resolver.js](lib/version_resolver.js) to add back this functionality.

## Building
1. Make sure you have fetched submodules

  ```bash
  git submodule update --init
  ```
1. Get latest buildpack dependencies

  ```shell
  BUNDLE_GEMFILE=cf.Gemfile bundle
  ```

1. Build the buildpack

  ```shell
  BUNDLE_GEMFILE=cf.Gemfile bundle exec buildpack-packager [ cached | uncached ]
  ```

1. Use in Cloud Foundry

  Upload the buildpack to your Cloud Foundry and optionally specify it by name
  ```bash
  cf create-buildpack custom_node_buildpack node_buildpack-offline-custom.zip 1
  cf push my_app -b custom_node_buildpack
  ```

## IBM SDK for Node.js

You need to download appropriate version of Node.js from [IBM SDK for Node.js](https://developer.ibm.com/node/sdk) and install it.
The following instructions expect that Node.js will be installed to `~/ibm/node/bin`, nodejs-buildpack code is cloned to `~/nodejs-buildpack` and Node.js version is `4.2.6`

You can easily adopt it to your requirements. The instructions show how to pack installed Node.js to archive and how to build packed buildpack. After that you can use it with
[Building](#building) instructions for upload to Cloud Foundry.

```bash
cd ~/ibm/node/bin
ln -sf ../lib/node_modules/appmetrics/bin/appmetrics-cli.js node-hc
ln -sf ../lib/node_modules/npm/bin/npm-cli.js npm
\cp node ~/nodejs-buildpack/bin/node
mkdir -p ~/nodejs-buildpack/dependencies/node/v4.2.6
mkdir /tmp/node-v4.2.6-linux-ppcle64
cd ../..
cp node/* /tmp/node-v4.2.6-linux-ppcle64 -r
cd /tmp
tar -zcvf  ~/nodejs-buildpack/dependencies/node/v4.2.6/node-v4.3.1-linux-ppcle64.tar.gz node-v4.2.6-linux-ppcle64
rm  -rf /tmp/node-v4.2.6-linux-ppcle64
cd ~/nodejs-buildpack

BUNDLE_GEMFILE=cf.Gemfile bundle
BUNDLE_GEMFILE=cf.Gemfile bundle exec buildpack-packager --use-custom-manifest=manifest-including-unsupported.yml uncached
```

## Supported binary dependencies

The NodeJS buildpack only supports the two most recent stable patches for each dependency in the [manifest.yml](manifest.yml).

If you want to use previously supported dependency versions, provide the `--use-custom-manifest=manifest-including-unsupported.yml` option to `buildpack-packager`.

## Options

### Specify a node version

Set engines.node in package.json to the semver range
(or specific version) of node you'd like to use.
(It's a good idea to make this the same version you use during development)

```json
"engines": {
  "node": "0.11.x"
}
```

```json
"engines": {
  "node": "0.10.33"
}
```

## Contributing

Find our guidelines [here](./CONTRIBUTING.md).

## Reporting Issues

Open an issue on this project

## Active Development

The project backlog is on [Pivotal Tracker](https://www.pivotaltracker.com/projects/1042066)
