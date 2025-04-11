"use strict";

const fs = require("fs");
const jwt = require("jsonwebtoken");

// Check if arguments are provided
if (process.argv.length < 5) {
  console.error("Usage: node generate_jwt.js <private_key_path> <key_id> <team_id>");
  process.exit(1);
}

const privateKeyPath = process.argv[2];
const keyId = process.argv[3];
const teamId = process.argv[4];

try {
  const privateKey = fs.readFileSync(privateKeyPath).toString();

  const jwtToken = jwt.sign({}, privateKey, {
    algorithm: "ES256",
    expiresIn: "180d",
    issuer: teamId,
    header: {
      alg: "ES256",
      kid: keyId
    }
  });

  console.log(jwtToken);
} catch (error) {
  console.error("Error generating token:", error.message);
  process.exit(1);
}
