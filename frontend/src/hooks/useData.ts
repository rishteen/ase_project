import { useEffect, useState } from "react";
import apiClient from "../services/api-client";
import { AxiosRequestConfig, CanceledError } from "axios";
import { getCategory } from "./api_v2/fetchCategory";


interface FetchResponse<T>{
    count:number;
    results:T[];
}
const useData = <T>(endpoint:string, requestConfig?: AxiosRequestConfig, deps?:any[]) => {
  const [data, setData] = useState<T[]>([]);
  const [error, setError] = useState("");
  const [isLoading, setLoading] = useState(true);
  useEffect(() => {
    setLoading(true)
    const controller = new AbortController();
    apiClient
      .get<FetchResponse<T>>(endpoint,{signal:controller.signal, ...requestConfig})
      .then((res) => {
        setData(res.data);
        setLoading(false);
        })
      .catch((err) => {
        if(err instanceof CanceledError) return;
        setError(err.message)});
        setLoading(false);
    return () => controller.abort();
  },deps?[...deps]:[]);
  return {data, error, isLoading};
}

export default useData;