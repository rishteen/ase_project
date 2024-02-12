// associations/index.js or wherever you prefer
import Category from './models/category.js';
import Restaurant from './models/restaurant.js';

// Define associations
Category.hasMany(Restaurant, {
    foreignKey: 'category_id',
    as: 'restaurants'
});

Restaurant.belongsTo(Category, {
    foreignKey: 'category_id',
    as: 'category'
});
