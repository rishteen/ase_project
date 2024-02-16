import { useState, useEffect } from "react";
import { useParams, Link as RouterLink } from "react-router-dom";
import apiClient from "../services/api-client";
import {
  Box,
  Image,
  Text,
  Heading,
  Link,
  Stack,
  VStack,
  HStack,
  Icon,
  Divider,
  Button,
  useColorModeValue,
} from "@chakra-ui/react";
import {
  FaFacebookF,
  FaInstagram,
  FaWhatsapp,
  FaEnvelope,
  FaGlobe,
  FaPhoneAlt,
  FaMapMarkerAlt,
  FaArrowLeft,
} from "react-icons/fa";

const RestaurantDetails = () => {
  const { id } = useParams();
  const [restaurant, setRestaurant] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    if (id) {
      getRestaurant(id);
    }
  }, [id]);

  const getRestaurant = async (id) => {
    try {
      const res = await apiClient.get(`/restaurant/${id}`);
      setRestaurant(res.data);
    } catch (error) {
      console.error("Error fetching restaurant details:", error);
      setError("Failed to load restaurant details. Please try again later.");
    }
  };

  const cardBg = useColorModeValue("white", "gray.800");
  const borderColor = useColorModeValue("gray.200", "gray.700");

  if (error) {
    return (
      <Box
        padding="6"
        boxShadow="lg"
        bg={cardBg}
        borderRadius="lg"
        border="1px solid"
        borderColor={borderColor}
        textAlign="center"
      >
        <Text>{error}</Text>
      </Box>
    );
  }

  if (!restaurant) {
    return (
      <Box padding="6" boxShadow="lg" bg={cardBg} borderRadius="lg">
        Loading or no restaurant found...
      </Box>
    );
  }

  return (
    <Box
      padding="6"
      boxShadow="lg"
      bg={cardBg}
      borderRadius="lg"
      border="1px solid"
      borderColor={borderColor}
    >
      <Button
        as={RouterLink}
        to="/"
        leftIcon={<FaArrowLeft />}
        colorScheme="teal"
        variant="link"
        mb="4"
      >
        برگرد به صفحه اصلی
      </Button>
      <Stack spacing="5">
        <Image
          width="400px"
          borderRadius="md"
          src={restaurant.url}
          alt={restaurant.name}
        />
        <VStack align="start" spacing="30">
          <Heading as="h1" size="xl">
            {restaurant.name}
          </Heading>

          <HStack divider={<Divider orientation="vertical" />} spacing="4">
            {restaurant.city && (
              <VStack align="start" spacing="1">
                <HStack spacing="2">
                  <Icon as={FaMapMarkerAlt} boxSize="5" color="red.500" />
                  <Text fontSize="sm">آدرس</Text>
                </HStack>
                {restaurant.street && (
                  <Text fontSize="sm">خیابان {restaurant.street}</Text>
                )}
                {restaurant.avenue && (
                  <Text fontSize="sm">کوچه {restaurant.avenue}</Text>
                )}
                {restaurant.district && (
                  <Text fontSize="sm">منطقه {restaurant.district}</Text>
                )}
                <Text fontSize="sm">شهر {restaurant.city}</Text>
              </VStack>
            )}

            {restaurant.phone && (
              <Link href={`tel:${restaurant.phone}`} isExternal>
                <HStack spacing="2">
                  <Icon as={FaPhoneAlt} boxSize="5" color="green.500" />
                  <Text fontSize="sm">{restaurant.phone}</Text>
                </HStack>
              </Link>
            )}
          </HStack>
          <HStack spacing="4">
            {restaurant.email && (
              <Link href={`mailto:${restaurant.email}`} isExternal>
                <Icon as={FaEnvelope} boxSize="5" color="blue.500" />
              </Link>
            )}
            {restaurant.web && (
              <Link href={restaurant.web} isExternal>
                <Icon as={FaGlobe} boxSize="5" color="purple.500" />
              </Link>
            )}
            {restaurant.facebook && (
              <Link
                href={`https://facebook.com/${restaurant.facebook}`}
                isExternal
              >
                <Icon as={FaFacebookF} boxSize="5" color="blue.700" />
              </Link>
            )}
            {restaurant.instagram && (
              <Link
                href={`https://instagram.com/${restaurant.instagram}`}
                isExternal
              >
                <Icon as={FaInstagram} boxSize="5" color="pink.400" />
              </Link>
            )}
            {restaurant.whatsapp && (
              <Link href={`https://wa.me/${restaurant.whatsapp}`} isExternal>
                <Icon as={FaWhatsapp} boxSize="5" color="green.400" />
              </Link>
            )}
          </HStack>
          {/* Placeholder for map integration */}
          {/* <Box>Your map component here</Box> */}
        </VStack>
      </Stack>
    </Box>
  );
};

export default RestaurantDetails;
