import { Button, List, ListItem, Spinner, Text } from "@chakra-ui/react";
import useCategory, { Category } from "../hooks/useCategory";

interface Props {
  onSelectCategory: (category: Category) => void;
  selectedCategory: Category | null;
}
const CategoryListAsSideMenu = ({
  selectedCategory,
  onSelectCategory,
}: Props) => {
  const { data, isLoading, error } = useCategory();

  if (isLoading) return <Spinner />;
  if (error) return <Text>Something went wrong!</Text>;

  return (
    <List spacing={2}>
      {data?.map((category) => (
        <ListItem key={category.id} paddingY="2">
          {/* Use a Flex container to center the button if needed */}
          <Button
            fontWeight={
              category.id === selectedCategory?.id ? "bold" : "normal"
            }
            color={category.id === selectedCategory?.id ? "teal" : ""}
            fontSize="lg"
            width="full" // Set button width to full to ensure it occupies the full width of its container
            justifyContent="center" // This centers the button's content
            alignItems="center" // Ensures vertical alignment is centered, useful if there's icon or similar
            onClick={() => onSelectCategory(category)}
          >
            {category.name}
          </Button>
        </ListItem>
      ))}
    </List>
  );
};

export default CategoryListAsSideMenu;
