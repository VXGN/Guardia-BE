import axios from "axios";
import { env } from "./env";

export const pythonClient = axios.create({
  baseURL: env.pythonServiceUrl,
  timeout: 30000,
  headers: {
    "Content-Type": "application/json",
  },
});
