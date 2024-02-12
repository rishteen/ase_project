import { SimpleGrid, Text } from "@chakra-ui/react";
import useRestaurants from "../hooks/useRestaurants";
import RestaurantCard from "./RestaurantCard";
import RestaurantCardSkeleton from "./RestaurantCardSkeleton";

const RestaurantGrid = () => {
  const { restaurants, error, isLoading } = useRestaurants();
  const skeleton = [1, 2, 3, 4, 5, 6];

  return (
    <>
      {error && <Text>{error}</Text>}
      <SimpleGrid
        columns={{ sm: 1, md: 2, lg: 3, xl: 5 }}
        spacing={10}
        padding="10px"
      >
        {isLoading &&
          skeleton.map((skeleton) => <RestaurantCardSkeleton key={skeleton} />)}
        {restaurants.map((restaurant) => (
          <RestaurantCard key={restaurant.id} restaurant={restaurant} />
        ))}
      </SimpleGrid>
    </>
  );
};

export default RestaurantGrid;
