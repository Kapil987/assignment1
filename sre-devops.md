```
1. Write a Dockerfile to run nginx version 1.19 in a container.

Choose a base image of your liking.

The build should be security conscious and ideally pass a container
image security test. [20 pts]
```

```
2.  Write a Kubernetes StatefulSet to run the above, using persistent volume claims and
resource limits. [15 pts]
```

```
3. Write a simple build and deployment pipeline for the above using groovy /
Jenkinsfile, CircleCI or GitHub Actions. [15 pts]
```

```
4. Source or come up with a text manipulation problem and solve it with at least two of
awk, sed, tr and / or grep. Check the question below first though, maybe. [10pts]
```

```
5. Solve the problem in question 4 using any programming language you like. [15pts]
```

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
