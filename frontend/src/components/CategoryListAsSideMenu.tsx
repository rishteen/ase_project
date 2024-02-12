import { HStack, List, ListItem, Spinner, Text } from "@chakra-ui/react";
import useCategory from "../hooks/useCategory";

const CategoryListAsSideMenu = () => {
  const { data, isLoading, error } = useCategory();
  if (error) return "some went wrong!";
  if (isLoading) return <Spinner />;
  return (
    <List>
      {data.map((category) => (
        <ListItem key={category.id} paddingY="5px">
          <HStack>
            <Text fontSize="lg">{category.name}</Text>
          </HStack>
        </ListItem>
      ))}
    </List>
  );
};

export default CategoryListAsSideMenu;
