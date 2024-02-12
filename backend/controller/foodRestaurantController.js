
import RestaurantFood from '../models/restaurantFoodModel.js';

// Create a new RestaurantFood
export const createRestaurantFood = async (req, res) => {
  try {
    const { restaurant_id, food_id } = req.body;
    const restaurantFood = await RestaurantFood.create({ restaurant_id, food_id });
    res.status(201).json(restaurantFood);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Get all RestaurantFood entries
export const getAllRestaurantFood = async (req, res) => {
  try {
    const restaurantFood = await RestaurantFood.findAll();
    res.json(restaurantFood);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Get a single RestaurantFood entry by ID
export const getRestaurantFoodById = async (req, res) => {
  try {
    const { id } = req.params;
    const restaurantFood = await RestaurantFood.findByPk(id);
    if (!restaurantFood) {
      res.status(404).json({ message: 'RestaurantFood not found' });
      return;
    }
    res.json(restaurantFood);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Update a RestaurantFood entry
export const updateRestaurantFood = async (req, res) => {
  try {
    const { id } = req.params;
    const { restaurant_id, food_id } = req.body;
    const restaurantFood = await RestaurantFood.findByPk(id);
    if (!restaurantFood) {
      res.status(404).json({ message: 'RestaurantFood not found' });
      return;
    }
    await restaurantFood.update({ restaurant_id, food_id });
    res.json(restaurantFood);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Delete a RestaurantFood entry
export const deleteRestaurantFood = async (req, res) => {
  try {
    const { id } = req.params;
    const restaurantFood = await RestaurantFood.findByPk(id);
    if (!restaurantFood) {
      res.status(404).json({ message: 'RestaurantFood not found' });
      return;
    }
    await restaurantFood.destroy();
    res.json({ message: 'RestaurantFood deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
