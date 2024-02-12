import express from "express";
import {
  deleteRestaurant,
  getRestaurants,
  getRestaurant,
  saveRestaurant,
  updateRestaurant,
} from "../controller/restaurantController.js";
import { addCategory } from "../controller/categoryController.js";

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
router.get("/restaurants", getRestaurants);

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
router.get("/restaurant/:id", getRestaurant);

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
router.post("/restaurant", saveRestaurant);

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
router.put("/restaurant/:id", updateRestaurant);

/**
 * @swagger
 * /api/restaurant/{id}:
 *   delete:
 *     summary: Delete a restaurant by ID
 *     description: Delete an existing restaurant by its ID.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the restaurant to delete
 *         schema:
 *           type: integer
 *     responses:
 *       '200':
 *         description: Restaurant deleted successfully.
 *       '404':
 *         description: Restaurant not found.
 */
router.delete("/restaurant/:id", deleteRestaurant);

export default router;
