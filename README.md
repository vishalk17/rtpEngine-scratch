Compile:

docker build -t ghcr.io/vishalk17/rtpengine:0.009 .
-----------
push docker image:

docker login ghcr.io   -- for login into ghcr.io

docker push ghcr.io/vishalk17/rtpengine:0.009

----------------------------
Replace image in rtpengine.yaml 

apply statefulset file :  kubectl apply -f rtpengine.yaml
-------------

restart deployment of statefuleset in order to reflect the changes 
--------------

we might need public ip for kworker1-3
