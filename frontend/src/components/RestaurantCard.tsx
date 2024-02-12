import React from "react";
import { Restaurant } from "../hooks/useRestaurants";
import {
  Card,
  CardBody,
  Heading,
  Image,
  HStack,
  Link,
  Center,
} from "@chakra-ui/react";
import { FaFacebookF, FaInstagram, FaWhatsapp } from "react-icons/fa";
import { MdEmail, MdWeb, MdPhone } from "react-icons/md";
import Views from "./Views";

interface Props {
  restaurant: Restaurant;
}

const RestaurantCard = ({ restaurant }: Props) => {
  // Construct URLs based on provided identifiers or usernames
  const facebookUrl = restaurant.facebook
    ? `https://facebook.com/${restaurant.facebook}`
    : "";
  const instagramUrl = restaurant.instagram
    ? `https://instagram.com/${restaurant.instagram}`
    : "";
  const whatsappUrl = restaurant.whatsapp
    ? `https://wa.me/${restaurant.whatsapp}`
    : "";
  const emailUrl = restaurant.email ? `mailto:${restaurant.email}` : "";
  const phoneUrl = restaurant.phone ? `tel:${restaurant.phone}` : "";
  const webUrl = restaurant.web ? restaurant.web : ""; // Assuming web is already a complete URL

  return (
    <Card borderRadius={10} overflow="hidden">
      <Image src={restaurant.url} alt={restaurant.name} />
      <CardBody>
        <Heading size="md" marginBottom={4}>
          {restaurant.name}&nbsp;&nbsp;
          <Views views={restaurant.id} />
        </Heading>

        <HStack spacing={10} wrap="wrap" justify="center">
          {restaurant.phone && (
            <Link href={phoneUrl} isExternal aria-label="Phone">
              <MdPhone />
            </Link>
          )}
          {restaurant.facebook && (
            <Link href={facebookUrl} isExternal aria-label="Facebook">
              <FaFacebookF />
            </Link>
          )}
          {restaurant.instagram && (
            <Link href={instagramUrl} isExternal aria-label="Instagram">
              <FaInstagram />
            </Link>
          )}
          {restaurant.whatsapp && (
            <Link href={whatsappUrl} isExternal aria-label="WhatsApp">
              <FaWhatsapp />
            </Link>
          )}
          {restaurant.email && (
            <Link href={emailUrl} isExternal aria-label="Email">
              <MdEmail />
            </Link>
          )}
          {restaurant.web && (
            <Link href={webUrl} isExternal aria-label="Website">
              <MdWeb />
            </Link>
          )}
        </HStack>
      </CardBody>
    </Card>
  );
};

export default RestaurantCard;
