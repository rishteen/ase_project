import { useEffect, useState } from "react";
import apiClient from "../services/api-client";
import { CanceledError } from "axios";

interface Category{
    id:number;
    name: string;
}
interface FetchCategoriesResponse{
    count:number;
    results:Category[];
}
const useCategory = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [error, setError] = useState("");
  const [isLoading, setLoading] = useState(false);
  useEffect(() => {
    setLoading(true)
    const controller = new AbortController();
    apiClient
      .get<FetchCategoriesResponse>("/categories",{signal:controller.signal})
      .then((res) => {
        setCategories(res.data);
        setLoading(false);
        })
      .catch((err) => {
        if(err instanceof CanceledError) return;
        setError(err.message)});
        setLoading(false);
    return () => controller.abort();
  },[]);
  return {categories, error, isLoading};
}
export default useCategory;