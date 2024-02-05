sudo docker build -t nginxl7 .

sudo docker run -d -p 5000:5000 -p 80:80 nginxl7:latest