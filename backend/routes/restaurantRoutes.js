import express from "express";
import { deleteRestaurant, getRestaurants, getRestaurant, saveRestaurant, updateRestaurant } from "../controller/restaurantController.js";
import { addCategory } from "../controller/categoryController.js";

const router = express.Router();


/**
 * @swagger
 * /restaurants:
 *   get:
 *     summary: Get all restaurants
 *     description: Retrieve a list of all restaurants.
 *     responses:
 *       '200':
 *         description: A list of restaurants.
 */
router.get("/restaurants", getRestaurants);



/**
 * @swagger
 * /restaurant/{id}:
 *   get:
 *     summary: Get a restaurant by ID
 *     description: Retrieve a single restaurant by its ID.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the restaurant to retrieve
 *         schema:
 *           type: integer
 *     responses:
 *       '200':
 *         description: A single restaurant.
 *       '404':
 *         description: Restaurant not found.
 */
router.get("/restaurant/:id", getRestaurant);


/**
 * @swagger
 * /restaurant:
 *   post:
 *     summary: Create a new restaurant
 *     description: Create a new restaurant with the provided data.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               image:
 *                 type: string
 *               url:
 *                 type: string
 *               latitude:
 *                 type: number
 *               longitude:
 *                 type: number
 *           example:
 *             name: "Restaurant Name"
 *             image: "restaurant.jpg"
 *             url: "https://restaurant.com"
 *             latitude: 123.456
 *             longitude: 456.789
 *     responses:
 *       '201':
 *         description: The newly created restaurant.
 */
router.post("/restaurant", saveRestaurant);



/**
 * @swagger
 * /restaurant/{id}:
 *   put:
 *     summary: Update a restaurant by ID
 *     description: Update an existing restaurant with the provided data.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the restaurant to update
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               image:
 *                 type: string
 *               url:
 *                 type: string
 *               latitude:
 *                 type: number
 *               longitude:
 *                 type: number
 *           example:
 *             name: "Updated Restaurant Name"
 *             image: "updated-restaurant.jpg"
 *             url: "https://updated-restaurant.com"
 *             latitude: 123.456
 *             longitude: 456.789
 *     responses:
 *       '200':
 *         description: The updated restaurant.
 *       '404':
 *         description: Restaurant not found.
 */
router.put("/restaurant/:id", updateRestaurant);



/**
 * @swagger
 * /restaurant/{id}:
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
