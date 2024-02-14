import { Heading } from "@chakra-ui/react";
import { RestaurantQuery } from "../App";

interface Props {
  restaurantQuery: RestaurantQuery;
}
const RestaurantHeading = ({ restaurantQuery }: Props) => {
  const heading = `رستوارن  ${restaurantQuery?.category?.name || "همه"}`;
  return <h1 style={{ fontSize: "24px", fontWeight: "bold" }}>{heading}</h1>;
};

export default RestaurantHeading;
