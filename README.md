# Helm3Spinnaker-Example

## Helm 3 deployment of spinnaker into Kubernetes Cluster Defined by ~/.kube/config - currentContext

Change all instances of `testthe.site` to your base url
```
./spinnaker.yml:  - host: "spinnaker.testthe.site"
./install-spinnaker.sh:        \$HAL_COMMAND config security api edit --override-base-url http://spinnaker-api.testthe.site
./install-spinnaker.sh:        \$HAL_COMMAND config security ui edit --override-base-url http://spinnaker.testthe.site
./install-spinnaker.sh:  host: spinnaker.testthe.site
./install-spinnaker.sh:  host: spinnaker-api.testthe.site
```

## Execution
Run `./install-spinnaker.sh` and then apply `spinnaker.yml` using your Kubernetes control of Choice.

## Access
Spinnaker should now be accessible at `http://spinnaker.BASE.URL`

## Configuration
Run the following command to set your halyard pod. (Add namspace as necessary)
`HALYARD_POD=$(kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep halyard)`

Then you can `kubctl exec -it $HALYARD_POD -- bash`
