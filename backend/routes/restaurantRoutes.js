import express from "express";
import { deleteRestaurant, getRestaurants, getRestaurant, saveRestaurant, updateRestaurant } from "../controller/restaurantController.js";
import { addCategory } from "../controller/categoryController.js";

const router = express.Router();

router.get("/restaurants", getRestaurants);
router.get("/restaurant/:id", getRestaurant);
router.post("/restaurant", saveRestaurant);
router.put("/restaurant/:id", updateRestaurant);
router.delete("/restaurant/:id", deleteRestaurant);


export default router;
