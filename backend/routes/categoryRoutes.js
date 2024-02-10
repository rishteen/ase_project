import express from "express";
import {addCategory, deleteCategory, getCategories, updateCategory} from "../controller/categoryController.js";

const router = express.Router();


router.post("/category", addCategory);
router.get("/categories", getCategories);
router.delete("/category/:id", deleteCategory);
router.put("/category/:id", updateCategory)


export default router;
