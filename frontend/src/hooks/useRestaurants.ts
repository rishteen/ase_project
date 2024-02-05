import React, { useEffect, useState } from "react";
import apiClient from "../services/api-client";

export interface Restaurant {
  id: number;
  name: string;
  image: string;
  url: string;
}

interface FetchRestaurantsResponse {
  count: number;
  result: Restaurant[];
}

const useRestaurants = () =>{
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [error, setError] = useState("");
  useEffect(() => {
    const controller = new AbortController();
    apiClient
      .get<FetchRestaurantsResponse>("/restaurants",{signal:controller.signal})
      .then((res) => setRestaurants(res.data))
      .catch((err) => {
        if(err instanceof CanceledError) return;
        setError(err.message)});
    return () => controller.abort();
  },[]);
  return {restaurants, error};
}

export default useRestaurants;