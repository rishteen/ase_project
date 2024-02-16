import apiClient from "../services/api-client";
import useData from "./useData";
import { useQuery } from "@tanstack/react-query";

export interface Category{
    id:number;
    name: string;
}

const useCategory = () => useQuery({
    queryKey:['category'],
    queryFn: () => 
    apiClient
        .get<Category[]>('/categories')
        .then(res => res.data),
    staleTime: 24 * 60 * 60 * 1000, // this 24hrs
})


export default useCategory;