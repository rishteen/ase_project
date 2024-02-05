import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const Product = db.define("product", {
    name: DataTypes.STRING, 
    image: DataTypes.STRING,
    url: DataTypes.STRING,
    // Add latitude and longitude as new fields
    latitude: DataTypes.DECIMAL(10, 8), // Precision of 10, 8 digits after decimal
    longitude: DataTypes.DECIMAL(11, 8), // Precision of 11, 8 digits after decimal
},{
    freezeTableName: true,
});

export default Product;
