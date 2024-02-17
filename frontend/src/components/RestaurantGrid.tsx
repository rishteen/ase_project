import { SimpleGrid, Text } from "@chakra-ui/react";
import useRestaurants from "../hooks/useRestaurants";
import RestaurantCard from "./RestaurantCard";
import RestaurantCardSkeleton from "./RestaurantCardSkeleton";
import RestaurantCardContainer from "./RestaurantCardContainer";
import { Category } from "../hooks/useCategory";
import { useEffect, useState } from "react";
import { getRestaurant } from "../hooks/api_v2/fetchCategory";

interface Props {
  selectedCategory: Category | null;
}
const RestaurantGrid = ({selectedCategory}:Props) => {
  // const { data, error, isLoading } = useRestaurants(selectedCategory);
  const [data, setData] = useState([]);
  const [isLoading, setLoading] = useState(true);
  const [error, setError] = useState("");
  useEffect(() => {
    const fetchRestaurant = async () => {
      try {
        const res = await getRestaurant()
        setData(res);
        setLoading(false);
      } catch (error) {
        setError(error.msg);
        console.error(error);
      }
    };
    fetchRestaurant();
  }, []);

  const skeleton = [1, 2, 3, 4, 5, 6];

  return (
    <>
      {error && <Text>{error}</Text>}
      <SimpleGrid
        columns={{ sm: 1, md: 2, lg: 3, xl: 4 }}
        spacing={1}
        padding="10px"
      >
        {isLoading &&
          skeleton.map((skeleton) => (
            <RestaurantCardContainer key={skeleton}>
              <RestaurantCardSkeleton />
            </RestaurantCardContainer>
          ))}
        {data.map((restaurant) => (
          <RestaurantCardContainer key={restaurant.objectId}>
            <RestaurantCard restaurant={restaurant} />
          </RestaurantCardContainer>
        ))}
      </SimpleGrid>
    </>
  );
};

export default RestaurantGrid;
