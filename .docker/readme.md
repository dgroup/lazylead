#### Docker FAQ
-  Prepare environment
    ````bash
    docker start <container_name>               # start particular container
    docker start -i <container_name>            # start particular container in interactive mode
    docker stop <container_name>                # stop particular container
    docker ps                                   # display all running containers
    docker ps -a                                # display all existing containers (stopped)
    docker exec -it <container_name> /bin/bash  # join to the container via bash
    docker rm <container_name>                  # remove particular container
    docker rmi <image_name>                     # remove particular image
    docker pull <image_name>                    # download particular image from the remote repository (NC Artifactory, dockerhub, etc)
    ````
  
-  Monitoring
    ```bash
    # Display on-line information regarding system usage (CPU,RAM,IO) per container    
    docker stats $(docker ps --format '{{.Names}}')        
    docker stats $(docker ps | awk '{if(NR>1) print $NF}')
    ```

-  [Cheat sheet](https://gist.github.com/dgroup/5046bac5531fae11242dd03201626f5b)

-  [Basics](https://github.com/wsargent/docker-cheat-sheet)
