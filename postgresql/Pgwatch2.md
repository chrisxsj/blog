# pgwatch2
 
Flexible self-contained PostgreSQL metrics monitoring/dashboarding solution
 
# Demo
 
[https://demo.pgwatch.com/](https://demo.pgwatch.com/)
 
Note: has a self-signed certificate as configured out the box in Docker, so you need to click "Allolw / Add exception / Trust" or similar
 
# Installing
 
Software is packaged as Docker (for custom setup see the last paragraph below, for a Docker quickstart see
[here](https://docs.docker.com/get-started/)) for getting started quickly.
```
# fetch and run the latest Docker image, exposing Grafana on port 3000 and administrative web UI on 8080
docker run -d -p 3000:3000 -p 8080:8080 --name pw2 cybertec/pgwatch2
```
 
After some minutes you could open the ["db-overview"](http://127.0.0.1:3000/dashboard/db/db-overview) dashboard and start
 
1、docker程序需要联网！！
2、需要安装docker
 
[root@dbrs software]# docker run -d -p 3000:3000 -p 8080:8080 --name pw2 cybertec/pgwatch2
Unable to find image 'cybertec/pgwatch2:latest' locally
latest: Pulling from cybertec/pgwatch2
8ee29e426c26: Pull complete
6e83b260b73b: Pull complete
e26b65fd1143: Pull complete
40dca07f8222: Pull complete
b420ae9e10b3: Pull complete
b4e35901a416: Downloading [==================================>                ]  188.7MB/271.1MB
d45f83511b5d: Download complete
4dc621ad16b3: Download complete
a777ee289e5c: Download complete
7c892d710344: Download complete
736751114a36: Download complete
1ccba433302a: Download complete
941da39e521a: Download complete
8ee3ba22af16: Download complete
5530fd1669cc: Download complete
71a6b4b88a54: Download complete
 
 
[root@dbrs software]# docker run -d -p 3000:3000 -p 8080:8080 --name pw2 cybertec/pgwatch2
Unable to find image 'cybertec/pgwatch2:latest' locally
latest: Pulling from cybertec/pgwatch2
8ee29e426c26: Pull complete
6e83b260b73b: Pull complete
e26b65fd1143: Pull complete
40dca07f8222: Pull complete
b420ae9e10b3: Pull complete
b4e35901a416: Pull complete
d45f83511b5d: Pull complete
4dc621ad16b3: Pull complete
a777ee289e5c: Pull complete
7c892d710344: Pull complete
736751114a36: Pull complete
1ccba433302a: Pull complete
941da39e521a: Pull complete
8ee3ba22af16: Pull complete
5530fd1669cc: Pull complete
71a6b4b88a54: Pull complete
Digest: sha256:4c35f818ac409efb10be6c99ef99440a896dafca5e6d9cfa85086aacbd42463b
Status: Downloaded newer image for cybertec/pgwatch2:latest
c897302a3cdbd11961d955932c987ff54cc4ca8a645f66b9b1c62c39283fbb92
[root@dbrs software]#
 
 
连接
 
http://192.168.80.22:3000/d/702c65021/db-overview?orgId=1