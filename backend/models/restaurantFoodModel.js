// models/RestaurantFood.js
import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const RestaurantFood = db.define(
  "RestaurantFood",
  {
    restaurant_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    food_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    // Define table name
    tableName: "Restaurant_Food",
    // Define primary key
    primaryKey: true,
  }
);

// Define associations (if needed)
RestaurantFood.associate = (models) => {
  RestaurantFood.belongsTo(models.restaurantModel, { foreignKey: "restaurant_id" });
  RestaurantFood.belongsTo(models.foodModel, { foreignKey: "food_id" });
};


export default RestaurantFood;