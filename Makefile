.PHONY: before_install before_script script deploy

before_install:
	openssl aes-256-cbc -k "$(HELM_KEY_PASSPHRASE)" -in key.gpg.enc -out key.gpg -d

before_script:
	sudo apt-get update
	sudo apt-get install -y socat
	go get -u github.com/landoop/coyote
	sudo mount --make-rshared /
	curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.3/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.6.2/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
	sudo minikube start --vm-driver=none --bootstrapper=kubeadm --kubernetes-version=v1.17.0 --memory 4096
	minikube update-context
	until kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' 2>&1 | grep -q "Ready=True"; do sleep 1; done
	curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
	chmod 700 get_helm.sh
	sudo ./get_helm.sh
	rm get_helm.sh

script:
	# Linting Helms
	./scripts/lint.sh
	# Testing Helms
	kubectl cluster-info
	until kubectl -n kube-system get pods -lcomponent=kube-addon-manager -o jsonpath='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for kube-addon-manager to be available"; kubectl get pods --all-namespaces; done
	until kubectl -n kube-system get pods -lk8s-app=kube-dns -o jsonpath='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for kube-dns to be available"; kubectl get pods --all-namespaces; done
	helm init
	until kubectl -n kube-system get pods -lname=tiller -o jsonpath='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for tiller to be available"; kubectl get pods --all-namespaces; done
	#./scripts/ci-test.sh

deploy:
	./package.sh
