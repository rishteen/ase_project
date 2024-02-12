import { Badge } from "@chakra-ui/react";

interface Props {
  views: number;
}

const Views = ({ views }: Props) => {
  let colorScheme = "green";
  if (views < 100) {
    colorScheme = "gray";
  } else if (views < 1000) {
    colorScheme = "blue";
  } else if (views < 10000) {
    colorScheme = "orange";
  } else {
    colorScheme = "red";
  }

  return <Badge colorScheme={colorScheme}>{views}</Badge>;
};

export default Views;
