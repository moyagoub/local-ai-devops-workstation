.PHONY: jenkins-build jenkins-up jenkins-password clean

DOCKER_GID := $(shell stat -c '%g' /var/run/docker.sock)

jenkins-build:
	docker build -t local-jenkins-docker:lts ./jenkins

jenkins-up:
	docker rm -f jenkins-local || true
	docker run -d \
	  --name jenkins-local \
	  --restart unless-stopped \
	  -p 8080:8080 \
	  -p 50000:50000 \
	  --group-add "$(DOCKER_GID)" \
	  -e HOST_REPO_DIR="$(PWD)" \
	  -v jenkins_home:/var/jenkins_home \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v /usr/local/bin/kind:/usr/local/bin/kind:ro \
	  -v /usr/local/bin/kubectl:/usr/local/bin/kubectl:ro \
	  -v "$(PWD):/workspace/local-ai-devops-workstation:ro" \
	  local-jenkins-docker:lts \
	  java -Djava.awt.headless=true -Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true -jar /usr/share/jenkins/jenkins.war
	sleep 10
	docker exec jenkins-local git config --global --add safe.directory /workspace/local-ai-devops-workstation/.git
	docker exec jenkins-local git config --global --add safe.directory /workspace/local-ai-devops-workstation

jenkins-password:
	docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword

clean:
	docker rm -f test-api localstack-lab02 lab03-k3s azurite-lab04 ansible-target-lab05 observability-api node-exporter prometheus grafana || true
	docker network rm lab02-net lab04-net lab06-monitoring || true
