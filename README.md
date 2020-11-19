# docker-geckomgv
A docker configuration to run GECKO-MGV anywhere!

## How to run
Build the container with `sudo docker build -t geckomgv-docker .` and run the container with `sudo docker run -p 5000:8080 geckomgv-docker`. This will bind port 5000 in your machine to port 8080 in the container, therefore to access gecko-mgv in your machine:

1. Open a browser
2. Navigate to localhost:5000
3. Thats it!

