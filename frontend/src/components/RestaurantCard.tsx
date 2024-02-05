import React from "react";
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
        <Heading fontSize="2xl">{restaurant.name}</Heading>
      </CardBody>
    </Card>
  );
};

export default RestaurantCard;
