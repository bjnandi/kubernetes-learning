
tag:=v1.0.1
images_name:=crud-app-mern-client
repository:=bjnandi

build:
	@ docker build --platform linux/amd64 -t ${images_name}:${tag} .

push:
	@ echo "push ${repository}/${images_name}:${tag} to docker hub"
	@ docker tag ${images_name}:${tag} ${repository}/${images_name}:${tag}
	@ docker push ${repository}/${images_name}:${tag}