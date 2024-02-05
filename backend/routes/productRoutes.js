import express from "express";
import { deleteProduct, getProduct, getProducts, saveProduct, updateProduct } from "../controller/productController.js";

const router = express.Router();

router.get("/products", getProducts); //http://localhost:5080/products
router.get("/product/:id", getProduct); //http://localhost:5080/products
router.post("/products", saveProduct);
router.put("/product/:id", updateProduct);
router.delete("/product/:id", deleteProduct);

export default router;