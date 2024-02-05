import axios from "axios";

const apiClient = axios.create({
    baseURL: 'http://localhost:5080'
});

export default apiClient;
