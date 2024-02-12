import express from "express";
import fileUpload from "express-fileupload";
import cors from "cors";
import swaggerSetup from './swagger.js';


import restaurantRoutes from "../backend/routes/restaurantRoutes.js";
import categoryRoutes from "../backend/routes/categoryRoutes.js";
import foodRestaurantRoutes from "../backend/routes/foodRestaurantRoutes.js";
import foodRoutes from "../backend/routes/foodRoutes.js";

const app = express();
app.use(cors());
app.use(express.json());
app.use(fileUpload());
app.use(restaurantRoutes);
app.use(categoryRoutes);
app.use(foodRestaurantRoutes);
app.use(foodRoutes);
app.use(express.static("public"));


swaggerSetup(app);


app.listen(5080, console.log("Server is running"));
