---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lei-app
  labels:
    app: lei-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lei-app
  template:
    metadata:
      labels:
        app: lei-app
    spec:
      containers:
      - name: lei-app
        image: gcr.io/GOOGLE_CLOUD_PROJECT/lei-app:COMMIT_SHA
        ports:
        - containerPort: 5000
---
kind: Service
apiVersion: v1
metadata:
  name: lei-app
spec:
  selector:
    app: lei-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
  type: LoadBalancer
