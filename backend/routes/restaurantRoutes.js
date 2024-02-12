import express from "express";
import { deleteRestaurant, getRestaurants, getRestaurant, saveRestaurant, updateRestaurant, getRestaurantByCategory } from "../controller/restaurantController.js";

const router = express.Router();

router.get("/restaurants", getRestaurants);
router.get("/restaurant/:id", getRestaurant);
router.post("/restaurant", saveRestaurant);
router.put("/restaurant/:id", updateRestaurant);
router.delete("/restaurant/:id", deleteRestaurant);
router.get('/restaurants/category/:id', getRestaurantByCategory)


export default router;
