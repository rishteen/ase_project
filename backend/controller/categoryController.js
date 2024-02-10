
import Category from "../models/categoryModel.js";


export const getCategories = async (req, res) =>{
    try {
        const response = await Category.findAll();
        res.json(response)
    } catch (error) {
        console.log(error.message)
    }
}
export const addCategory = async (req, res) => {
    const { name: name, description: description } = req.body; // Destructured and renamed title to name

    try {
        await Category.create({ name, description });
        res.json({ msg: `دسته بندی با موفقیت افزوده شد.` }); // Successful response
    } catch (error) {
        console.error(error.message); // Log error to console
        res.status(500).json({ msg: "خطا در افزودن دسته بندی.", error: error.message }); // Respond with error
    }
};

// Assuming you have imported your Category model correctly at the top of your file
// For example:
// const Category = require('../models/Category');

export const deleteCategory = async (req, res) => {
    try {
        // Find the category by ID first to ensure it exists
        const category = await Category.findOne({
            where: {
                id: req.params.id
            }
        });

        // If the category doesn't exist, return an error response
        if (!category) {
            return res.status(404).json({ msg: "دسته بندی یافت نشد." });
        }

        // If the category exists, proceed to delete it
        await category.destroy(); // Since you've already found the category, you can call destroy directly on it

        res.json({ msg: "دسته بندی با موفقیت حذف شد." });
    } catch (error) {
        console.error("Deletion error:", error); // It's good practice to log the error
        res.status(500).json({ msg: "خطا در حذف دسته بندی.", error: error.message });
    }
};



export const updateCategory = async(req, res)=> {
     const { name, description } = req.body;

     try {
          await Category.update({name: name, description:description}, {
               where: {
                    id: req.params.id,
               }
          });
          res.json({msg: "دسته بندی با موفقیت ویرایش شد"})
     } catch (error) {
          res.json(error)
     }
}
