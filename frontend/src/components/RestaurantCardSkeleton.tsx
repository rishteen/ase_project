import { Card, CardBody, Skeleton, SkeletonText } from "@chakra-ui/react";

const RestaurantCardSkeleton = () => {
  return (
    <Card>
      <Skeleton />
      <CardBody>
        <SkeletonText />
      </CardBody>
    </Card>
  );
};

export default RestaurantCardSkeleton;
