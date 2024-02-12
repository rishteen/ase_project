import { Restaurant } from "../hooks/useRestaurants";
import { Card, CardBody, Heading, Image } from "@chakra-ui/react";
interface Props {
  restaurant: Restaurant;
}
const RestaurantCard = ({ restaurant }: Props) => {
  return (
    <Card borderRadius={10} overflow="hidden">
      <Image src={restaurant.url} />
      <CardBody>
        <h1>{restaurant.name}</h1>
      </CardBody>
    </Card>
  );
};

export default RestaurantCard;
