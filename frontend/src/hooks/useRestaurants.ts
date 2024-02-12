// Assuming useCategory and useData are correctly implemented
import { Category } from "./useCategory";
import useData from "./useData";

export interface Restaurant {
  id: number;
  name: string;
  image: string;
  url: string;
  phone: string;
  facebook: string;
  instagram: string;
  whatsapp: string;
  email: string;
  web: string;
  category_id: number;
}

const useRestaurants = (selectedCategory: Category | null) => {
  const endpoint = selectedCategory ? `/restaurants/category/${selectedCategory.id}` : '/restaurants';
  return useData<Restaurant>(endpoint, {}, [selectedCategory?.id]);
};

export default useRestaurants;
