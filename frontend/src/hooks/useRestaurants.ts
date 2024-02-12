import React, { useEffect, useState } from "react";
import apiClient from "../services/api-client";

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

interface FetchRestaurantsResponse {
  count: number;
  result: Restaurant[];
}

const useRestaurants = () =>{
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [error, setError] = useState("");
  const [isLoading, setLoading] = useState(false);
  useEffect(() => {
    setLoading(true)
    const controller = new AbortController();
    apiClient
      .get<FetchRestaurantsResponse>("/restaurants",{signal:controller.signal})
      .then((res) => {
        setRestaurants(res.data);
        setLoading(false);
        })
      .catch((err) => {
        if(err instanceof CanceledError) return;
        setError(err.message)});
        setLoading(false);
    return () => controller.abort();
  },[]);
  return {restaurants, error, isLoading};
}

export default useRestaurants;