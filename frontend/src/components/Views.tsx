import { Badge } from "@chakra-ui/react";

interface Props {
  views: number;
}

const Views = ({ views }: Props) => {
  let colorScheme =
    views < 50 ? "red" : views < 100 ? "yellow" : views < 1000 ? "green" : "";
  return (
    <Badge fontSize={16} padding={1} colorScheme={colorScheme} borderRadius={4}>
      {views}
    </Badge>
  );
};

export default Views;
