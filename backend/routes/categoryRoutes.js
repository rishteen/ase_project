import express from "express";
import {addCategory, deleteCategory, getCategories} from "../controller/categoryController.js";

const router = express.Router();


router.post("/category", addCategory);
router.get("/categories", getCategories);
router.delete("/category/:id", deleteCategory);


export default router;
