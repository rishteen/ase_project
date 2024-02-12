// models/category.js
import { Sequelize, DataTypes } from 'sequelize';
import db from '../config/database.js';

const Category = db.define('category', {
    // Assuming id as the primary key
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false
    },
    description: DataTypes.STRING
}, {
    freezeTableName: true
});

export default Category;
