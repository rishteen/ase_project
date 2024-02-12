import { Box } from "@chakra-ui/react";
import { ReactNode } from "react";

interface Props {
  children: ReactNode;
}
const RestaurantCardContainer = ({ children }: Props) => {
  return (
    <Box borderRadius={10} overflow="hidden"  padding={5}>
      {children}
    </Box>
  );
};

export default RestaurantCardContainer;