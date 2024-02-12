import { Card, CardBody, Skeleton, SkeletonText } from "@chakra-ui/react";

const RestaurantCardSkeleton = () => {
  return (
    <Card width="300px" borderRadius={10}>
      <Skeleton height="200px" />
      <CardBody>
        <SkeletonText />
      </CardBody>
    </Card>
  );
};

export default RestaurantCardSkeleton;
