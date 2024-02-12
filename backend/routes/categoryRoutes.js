import express from "express";
import {addCategory, deleteCategory, getCategories, updateCategory} from "../controller/categoryController.js";

const router = express.Router();

/**
 * @swagger
 * /api/category:
 *   post:
 *     summary: Create a new category
 *     description: Create a new category with the provided data.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *           example:
 *             name: "Category Name"
 *     responses:
 *       '201':
 *         description: The newly created category.
 */
router.post("/category", addCategory);

/**
 * @swagger
 * /api/categories:
 *   get:
 *     summary: Get all categories
 *     description: Retrieve a list of all categories.
 *     responses:
 *       '200':
 *         description: A list of categories.
 */
router.get("/categories", getCategories);

/**
 * @swagger
 * /api/category/{id}:
 *   delete:
 *     summary: Delete a category by ID
 *     description: Delete an existing category by its ID.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the category to delete
 *         schema:
 *           type: integer
 *     responses:
 *       '200':
 *         description: Category deleted successfully.
 *       '404':
 *         description: Category not found.
 */
router.delete("/category/:id", deleteCategory);

/**
 * @swagger
 * /api/category/{id}:
 *   put:
 *     summary: Update a category by ID
 *     description: Update an existing category with the provided data.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the category to update
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
 *           example:
 *             name: "New Category Name"
 *     responses:
 *       '200':
 *         description: The updated category.
 *       '404':
 *         description: Category not found.
 */
router.put("/category/:id", updateCategory)


export default router;
