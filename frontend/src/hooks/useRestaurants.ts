// Assuming useCategory and useData are correctly implemented
import { RestaurantQuery } from "../App";
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

const useRestaurants = (restaurantQuery:RestaurantQuery) => {
  const endpoint = restaurantQuery.category ? `/restaurants/category/${restaurantQuery.category.id}` : '/restaurants';
  return useData<Restaurant>(endpoint, {}, [restaurantQuery.category?.id]);
};

export default useRestaurants;
