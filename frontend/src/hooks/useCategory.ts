import { useEffect, useState } from "react";
import { getCategory } from "./api_v2/fetchCategory";

export interface Category {
  objectId: number;
  name: string;
}

const useCategory = () => useData<Category>("/categories");

export default useCategory;
