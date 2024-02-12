import express from "express";
import { deleteFood,getAllFood,getFoodById,createFood,updateFood } from "../controller/foodController.js";

const router = express.Router();

/**
 * @swagger
 * /allfood:
 *   get:
 *     summary: Get all food items
 *     description: Retrieve a list of all food items.
 *     responses:
 *       '200':
 *         description: A list of food items.
 */
router.get("/allfood", getAllFood);

/**
 * @swagger
 * /food/{id}:
 *   get:
 *     summary: Get a food item by ID
 *     description: Retrieve a single food item by its ID.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the food item to retrieve
 *         schema:
 *           type: integer
 *     responses:
 *       '200':
 *         description: A single food item.
 *       '404':
 *         description: Food item not found.
 */
router.get("/food/:id", getFoodById);

/**
 * @swagger
 * /food:
 *   post:
 *     summary: Create a new food item
 *     description: Create a new food item with the provided data.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               price:
 *                 type: number
 *           example:
 *             name: "Burger"
 *             description: "Delicious burger"
 *             price: 9.99
 *     responses:
 *       '201':
 *         description: The newly created food item.
 */
router.post("/food", createFood);

/**
 * @swagger
 * /food/{id}:
 *   put:
 *     summary: Update a food item by ID
 *     description: Update an existing food item with the provided data.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the food item to update
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
 *               description:
 *                 type: string
 *               price:
 *                 type: number
 *           example:
 *             name: "New Burger"
 *             description: "Updated description"
 *             price: 10.99
 *     responses:
 *       '200':
 *         description: The updated food item.
 *       '404':
 *         description: Food item not found.
 */
router.put("/food/:id", updateFood);

/**
 * @swagger
 * /food/{id}:
 *   delete:
 *     summary: Delete a food item by ID
 *     description: Delete an existing food item by its ID.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the food item to delete
 *         schema:
 *           type: integer
 *     responses:
 *       '200':
 *         description: Food item deleted successfully.
 *       '404':
 *         description: Food item not found.
 */


router.delete("/food/:id", deleteFood);


export default router;
