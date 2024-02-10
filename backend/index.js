import express from "express";
import fileUpload from "express-fileupload";
import cors from "cors";
import restaurantRoutes from "../backend/routes/restaurantRoutes.js"
import categoryRoutes from "../backend/routes/categoryRoutes.js"

const app = express();
app.use(cors());
app.use(express.json());
app.use(fileUpload());
app.use(restaurantRoutes);
app.use(categoryRoutes);
app.use(express.static("public"));



app.listen(5080, console.log("Server is running"))