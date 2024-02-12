import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Category from "./categoryModel.js";

const { DataTypes } = Sequelize;

// Define Restaurant model
const Restaurant = db.define("restaurant", {
    name: DataTypes.STRING,
    image: DataTypes.STRING,
    url: DataTypes.STRING,
    category_id: {
        type: DataTypes.INTEGER,
        references: {
            model: 'Category', // This is a reference to another model
            key: 'id', // This is the column name of the referenced model
        },
        allowNull: false
    },
    latitude: DataTypes.DECIMAL(10, 8),
    longitude: DataTypes.DECIMAL(11, 8),
    phone: DataTypes.STRING,
    facebook: DataTypes.STRING,
    instagram: DataTypes.STRING,
    whatsapp: DataTypes.STRING,
    email: DataTypes.STRING,
    web: DataTypes.STRING,
    city: DataTypes.STRING,
    district: DataTypes.STRING,
    street: DataTypes.STRING,
    avenue: DataTypes.STRING,
    postal_code: DataTypes.STRING,
    opening_time: DataTypes.TIME,
    closing_time: DataTypes.TIME,
    working_days: DataTypes.STRING, // Consider using ARRAY or JSON type if your DB supports it, for more flexibility
    deliver: DataTypes.BOOLEAN,
    takeaway: DataTypes.BOOLEAN,
    serving: DataTypes.BOOLEAN,
    // Remove category string definition
}, {
    freezeTableName: true,
});


export default Restaurant;
