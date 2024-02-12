import React from "react";
import useCategory from "../hooks/useCategory";

const CategoryListAsSideMenu = () => {
  const { categories } = useCategory();
  return (
    <ul>
      {categories.map((category) => (
        <li key={category.id}>{category.name}</li>
      ))}
    </ul>
  );
};

export default CategoryListAsSideMenu;
