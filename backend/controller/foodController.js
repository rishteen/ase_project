import Food from '../models/foodModel.js';

// Create a new food item
export const createFood = async (req, res) => {
  try {
    const { name, description, price } = req.body;
    const food = await Food.create({ name, description, price });
    res.status(201).json(food);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Get all food items
export const getAllFood = async (req, res) => {
  try {
    const food = await Food.findAll();
    res.json(food);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Get a single food item by ID
export const getFoodById = async (req, res) => {
  try {
    const { id } = req.params;
    const food = await Food.findByPk(id);
    if (!food) {
      res.status(404).json({ message: 'Food not found' });
      return;
    }
    res.json(food);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Update a food item
export const updateFood = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price } = req.body;
    const food = await Food.findByPk(id);
    if (!food) {
      res.status(404).json({ message: 'Food not found' });
      return;
    }
    await food.update({ name, description, price });
    res.json(food);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Delete a food item
export const deleteFood = async (req, res) => {
  try {
    const { id } = req.params;
    const food = await Food.findByPk(id);
    if (!food) {
      res.status(404).json({ message: 'Food not found' });
      return;
    }
    await food.destroy();
    res.json({ message: 'Food deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
