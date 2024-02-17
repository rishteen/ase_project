import { Button, List, ListItem, Spinner, Text } from "@chakra-ui/react";
import useCategory, { Category } from "../hooks/useCategory";
import { useEffect, useState } from "react";
import { getCategory } from "../hooks/api_v2/fetchCategory";

interface Props {
  onSelectCategory: (category: Category) => void;
}
const CategoryListAsSideMenu = ({ onSelectCategory }: Props) => {
  // const { data, isLoading, error } = useCategory();
  const [data, setData] = useState([]);
  const [isLoading, setLoading] = useState(true);
  const [error, setError] = useState("");
  useEffect(() => {
    const fetchCategory = async () => {
      try {
        const res = await getCategory();
        setData(res);
        setLoading(false);
      } catch (error) {
        setError(error.msg);
        console.error(error);
      }
    };
    fetchCategory();
  }, []);
  if (isLoading) return <Spinner />;
  if (error) return <Text>Something went wrong!</Text>;

  return (
    <List spacing={2}>
      {data.map((category) => (
        <ListItem key={category.objectId} paddingY="2">
          {/* Use a Flex container to center the button if needed */}
          <Button
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
