import { SimpleGrid, Text } from "@chakra-ui/react";
import useRestaurants from "../hooks/useRestaurants";
import RestaurantCard from "./RestaurantCard";
import RestaurantCardSkeleton from "./RestaurantCardSkeleton";
import RestaurantCardContainer from "./RestaurantCardContainer";
import { RestaurantQuery } from "../App";

interface Props {
  restaurantQuery: RestaurantQuery;
}
const RestaurantGrid = ({ restaurantQuery }: Props) => {
  const { data, error, isLoading } = useRestaurants(restaurantQuery);
  const skeleton = [1, 2, 3, 4, 5, 6];
  if (error) return <Text>{error}</Text>;

  return (
    <>
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
          <RestaurantCardContainer key={restaurant.id}>
            <RestaurantCard restaurant={restaurant} />
          </RestaurantCardContainer>
        ))}
      </SimpleGrid>
    </>
  );
};

export default RestaurantGrid;
