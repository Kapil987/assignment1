```
1. Write a Dockerfile to run nginx version 1.19 in a container.

Choose a base image of your liking.

The build should be security conscious and ideally pass a container
image security test. [20 pts]
```
FROM nginx:1.19
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
RUN apt-get update && apt-get install -y
WORKDIR /app
RUN chown -R nginx:nginx /app && chmod -R 755 /app && \
        chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid
USER nginx
CMD ["nginx", "-g", "daemon off;"]
HEALTHCHECK --interval=5s --timeout=3s \
 CMD curl http://localhost:80 -k || exit 1
```
2.  Write a Kubernetes StatefulSet to run the above, using persistent volume claims and
resource limits. [15 pts]
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: www
spec:
  capacity:
    storage: 3Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  hostPath:
    path: /mnt/security
---
apiVersion: v1                                                                                                
kind: Service                                                                                                 
metadata:                                                                                                     
  name: nginx-svc                                                                                        
spec:                                                                                                         
   type: NodePort                                                                                             
   selector:                                                                                                  
     app: nginx                                                                                     
   ports:                                                                                                     
     - port: 80                                                                                               
       targetPort: 80                                                                                         
       nodePort: 30008
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: kapil0123/nginx-statefulset:1.19
        resources:
          limits:
            cpu: 100m
            memory: 100Mi 
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: standard
      resources:
        requests:
          storage: 1Gi

```
3. Write a simple build and deployment pipeline for the above using groovy /
Jenkinsfile, CircleCI or GitHub Actions. [15 pts]
```
node () {
    env.DOCKER_TAG = '1.19'

    stage ('Checkout SCM') {
        git url: 'https://github.com/Kapil987/assignment1.git', branch: 'main'
        }
    stage ('Docker Build') {
        docker.withRegistry( 'https://registry.hub.docker.com', 'docker_logins' )
            {
                def customImage = docker.build("kapil0123/nginx-statefulset:${DOCKER_TAG}")
                customImage.push()             
            }
        }

        stage ('Deploy') {
            sh 'sudo kubectl apply -f nginx-deploy.yml'
        }
}
```
4. Source or come up with a text manipulation problem and solve it with at least two of
awk, sed, tr and / or grep. Check the question below first though, maybe. [10pts]
```
sample data
Time            Type    Description
1698765432      INFO    system start-up
1698765432      INFO    user authorised
1698765432      INFO    booting completed
1698765432      INFO    user requested a file access
1698765432      ERROR   privilege escalation 
1698765432      INFO    system is healthy
1698765432      ERROR   Cron job started
1698765432      INFO    a file has been deleted

grep 'INFO' sample | sed s/'INFO'/'CRITICAL'/g
```
5. Solve the problem in question 4 using any programming language you like. [15pts]
```
import re
with open("sample",'r') as f:
    for line in f:
        if 'INFO' in line:
            print(re.sub("INFO", "CRITICAL",line),end='')

```
6. Write a Terraform module that creates the following resources in IAM;
---
• -  A role, with no permissions, which can be assumed by users within the same account,
• -  A policy, allowing users / entities to assume the above role,
• -  A group, with the above policy attached,
• -  A user, belonging to the above group.
All four entities should have the same name, or be similarly named in some meaningful way given the
context e.g. prod-ci-role, prod-ci-policy, prod-ci-group, prod-ci-user; or just prod-ci. Make the suffixes
toggleable, if you like. [25pts]
```
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:\\Users\\Kapil\\.aws\\credentials"]
}

variable "env-name" {
  description = "Environment Name"
  type = list
  default = ["prod-ci","dev-ci","test-ci"]
}


resource "aws_iam_user" "user1" {
  name = "${var.env-name[0]}-user1"
}

resource "aws_iam_role" "role1" {
  name = "${var.env-name[0]}-sample-role1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_group" "group1" {
  name = "${var.env-name[0]}-sample-group1"
}

resource "aws_iam_policy" "policy1" {
  name        = "${var.env-name[0]}-sample-policy"
  description = "A sample policy for prod-ci"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:iam::123456789012:*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "sample-attach" {
  name       = "${var.env-name[0]}-sample-attachment"
  users      = [aws_iam_user.user1.name]
  roles      = [aws_iam_role.role1.name]
  groups     = [aws_iam_group.group1.name]
  policy_arn = aws_iam_policy.policy1.arn
}

resource "aws_iam_user_group_membership" "user-group1" {
  user = aws_iam_user.user1.name

  groups = [
    aws_iam_group.group1.name
  ]
}

