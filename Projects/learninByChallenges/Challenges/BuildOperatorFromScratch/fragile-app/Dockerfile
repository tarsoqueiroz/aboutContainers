# use a small base image
FROM golang:1.24-alpine

# set working directory
WORKDIR /app

# copy and build the go app
COPY . .
RUN go build -o fragile-app

# expose port 80 and run the app
EXPOSE 80
CMD [ "./fragile-app" ]
