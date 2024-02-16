import { useState, useEffect } from "react";
import apiClient from "../services/api-client";
import { useParams } from "react-router-dom";
import { Heading, Text, Box } from "@chakra-ui/react";

const RestaurantDetails = () => {
  // Correctly extract `id` from the `useParams` hook
  const { id } = useParams();

  const [restaurant, setRestaurant] = useState(null);

  useEffect(() => {
    if (id) {
      // Ensure `id` is not undefined
      getRestaurant(id);
    }
  }, [id]); // Add `id` as a dependency to `useEffect` to re-fetch if the ID changes

  const getRestaurant = async (id) => {
    try {
      // Use the `id` directly within the template string
      const res = await apiClient.get(`/restaurant/${id}`);
      setRestaurant(res.data);
    } catch (error) {
      console.error("Error fetching restaurant details:", error);
      // Consider setting some state here to show an error message to the user
    }
  };

  if (!restaurant) {
    return <div>Loading or no restaurant found...</div>;
  }

  // Render the restaurant details
  return (
    <div>
      <Box padding={10}>
        <Heading>{restaurant.name}</Heading>
        {/* Render additional restaurant details */}
        <Text>{restaurant.city}</Text>
      </Box>
      {/* Further details */}
    </div>
  );
};

export default RestaurantDetails;
