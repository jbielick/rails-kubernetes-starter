CONTAINER_NAME=app
CLUSTER_NAME=rails
EXTERNAL_REGISTRY_ENDPOINT='us.gcr.io/rails-kube-demo/'

cluster:
	gcloud container clusters create $(CLUSTER_NAME) \
		--enable-cloud-logging \
		--enable-cloud-monitoring \
		--machine-type n1-standard-2 \
		--num-nodes 1
	gcloud container node-pools create db-pool \
		--num-nodes 1 \
		--cluster $(CLUSTER_NAME)
	gcloud container clusters get-credentials $(CLUSTER_NAME)

ip:
	gcloud compute addresses create app-external — region=us-central1

db-disk:
	# create persistent disk on gcloud with name "db-data"
	gcloud compute disks create --size 300GB --type pd-ssd db-data

mysql: db-disk
	# create mysql deployment (replica set) so that one is always running
	# create mysql service to expose to the cluster (not externally)
	kubectl create -f kube/mysql.yml

web:
	# create web deployment (replica set - web server containers)
	# expose with a loadbalancer
	kubectl create -f kube/web.yml

build:
ifndef TAG
	$(error TAG is undefined)
endif
	docker build -t $(CONTAINER_NAME) .
	docker tag $(CONTAINER_NAME) $(EXTERNAL_REGISTRY_ENDPOINT)$(CONTAINER_NAME):$(TAG)
	docker tag $(CONTAINER_NAME) $(EXTERNAL_REGISTRY_ENDPOINT)$(CONTAINER_NAME):latest

push: build
	# push the built image to the gcloud container registry
	gcloud docker push $(EXTERNAL_REGISTRY_ENDPOINT)$(CONTAINER_NAME):$(TAG)

clean:
	kubectl delete -f kube

.PHONY: cluster db-disk mysql web build push