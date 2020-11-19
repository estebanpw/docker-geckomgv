# docker-geckomgv
A docker configuration to run GECKO-MGV anywhere!

## How to run
Build the container with `sudo docker build -t geckomgv-docker .` and run the container with `sudo docker run -p 5000:8080 geckomgv-docker`. This will bind port 5000 in your machine to port 8080 in the container, therefore to access gecko-mgv in your machine:

1. Open a browser
2. Navigate to localhost:5000
3. Login with user "user" and password "user"
4. You can now use GECKO-MGV services

## Changing the configuration of GECKO-MGV
If you want to create users, delete files, add services, etc., you can do this by logging into the django administration backend. Follow these steps:

1. Navigate to localhost:5000/admin
2. Enter login user "Admin" and password "Pass"
3. You have now access to the backend
