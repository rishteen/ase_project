import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

// Define Category model
const Category = db.define("category", {
    name: DataTypes.STRING,
    description: DataTypes.STRING
}, {
    freezeTableName: true,
});
export default Category;
