import mqtt from "mqtt";

const client = mqtt.connect(
  "wss://broker.m-tech.fun:8084/mqtt"
);

export default client;
