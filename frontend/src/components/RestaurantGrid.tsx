import { SimpleGrid, Text } from "@chakra-ui/react";
import useRestaurants from "../hooks/useRestaurants";
import RestaurantCard from "./RestaurantCard";
import RestaurantCardSkeleton from "./RestaurantCardSkeleton";
import RestaurantCardContainer from "./RestaurantCardContainer";

const RestaurantGrid = () => {
  const { data, error, isLoading } = useRestaurants();
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
          skeleton.map((skeleton) => (
            <RestaurantCardContainer>
              <RestaurantCardSkeleton key={skeleton} />
            </RestaurantCardContainer>
          ))}
        {data.map((restaurant) => (
          <RestaurantCardContainer>
            <RestaurantCard key={restaurant.id} restaurant={restaurant} />
          </RestaurantCardContainer>
        ))}
      </SimpleGrid>
    </>
  );
};

export default RestaurantGrid;
