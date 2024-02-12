import express from "express";
import { deleteRestaurantFood,getAllRestaurantFood,getRestaurantFoodById,createRestaurantFood,updateRestaurantFood } from "../controller/foodRestaurantController.js";

const router = express.Router();


/**
 * @swagger
 * /api/allfoodRestaurant:
 *   get:
 *     summary: Get all restaurant food items
 *     description: Retrieve a list of all food items associated with restaurants.
 *     responses:
 *       '200':
 *         description: A list of restaurant food items.
 */
router.get("/allfoodRestaurant", getAllRestaurantFood);


/**
 * @swagger
 * /api/foodRestaurant/{id}:
 *   get:
 *     summary: Get a restaurant food item by ID
 *     description: Retrieve a single restaurant food item by its ID.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the restaurant food item to retrieve
 *         schema:
 *           type: integer
 *     responses:
 *       '200':
 *         description: A single restaurant food item.
 *       '404':
 *         description: Restaurant food item not found.
 */
router.get("/foodRestaurant/:id", getRestaurantFoodById);


/**
 * @swagger
 * /api/foodRestaurant:
 *   post:
 *     summary: Create a new restaurant food item
 *     description: Create a new restaurant food item with the provided data.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               restaurant_id:
 *                 type: integer
 *               food_id:
 *                 type: integer
 *           example:
 *             restaurant_id: 1
 *             food_id: 1
 *     responses:
 *       '201':
 *         description: The newly created restaurant food item.
 */
router.post("/foodRestaurant", createRestaurantFood);

/**
 * @swagger
 * /api/foodRestaurant/{id}:
 *   put:
 *     summary: Update a restaurant food item by ID
 *     description: Update an existing restaurant food item with the provided data.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the restaurant food item to update
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               restaurant_id:
 *                 type: integer
 *               food_id:
 *                 type: integer
 *           example:
 *             restaurant_id: 2
 *             food_id: 3
 *     responses:
 *       '200':
 *         description: The updated restaurant food item.
 *       '404':
 *         description: Restaurant food item not found.
 */
router.put("/foodRestaurant/:id", updateRestaurantFood);


/**
 * @swagger
 * /api/foodRestaurant/{id}:
 *   delete:
 *     summary: Delete a restaurant food item by ID
 *     description: Delete an existing restaurant food item by its ID.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the restaurant food item to delete
 *         schema:
 *           type: integer
 *     responses:
 *       '200':
 *         description: Restaurant food item deleted successfully.
 *       '404':
 *         description: Restaurant food item not found.
 */
router.delete("/foodRestaurant/:id", deleteRestaurantFood);


export default router;