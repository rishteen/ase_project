import { HStack, IconButton, useColorMode } from "@chakra-ui/react";
import { FaSun, FaMoon } from "react-icons/fa"; // Assuming you're using react-icons

const ColorModeSwitch = () => {
  const { colorMode, toggleColorMode } = useColorMode();

  return (
    <HStack justifyContent="space-between">
      <IconButton
        aria-label="Toggle dark mode"
        icon={colorMode === "dark" ? <FaSun /> : <FaMoon />}
        onClick={toggleColorMode}
        isRound={true}
      />
    </HStack>
  );
};

export default ColorModeSwitch;
