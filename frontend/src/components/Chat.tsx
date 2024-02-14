import React from "react";
import { Button, HStack, Link } from "@chakra-ui/react";
import { MdChat } from "react-icons/md";

const ChatContact = () => {
  return (
    <HStack marginTop={5} justifyContent="center">
      <Link href={"/"} isExternal aria-label="Chat">
        <Button rightIcon={<MdChat />} colorScheme="blue" variant="outline">
          چت مستقیم با ما
        </Button>
      </Link>
    </HStack>
  );
};

export default ChatContact;
