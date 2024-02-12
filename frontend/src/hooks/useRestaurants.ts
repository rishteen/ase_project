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
}



const useRestaurants = () => useData<Restaurant>('/restaurants');

export default useRestaurants;