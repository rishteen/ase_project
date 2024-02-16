// AddCategory.js
import { useState } from "react";
import {
  Button,
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalCloseButton,
  ModalBody,
  ModalFooter,
  FormControl,
  FormLabel,
  Input,
  useDisclosure,
} from "@chakra-ui/react";
import { toast } from "react-toastify";
import apiClient from "../services/api-client";

const AddCategory = ({ refreshCategories }) => {
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleAddCategory = async () => {
    if (!name.trim() || !description.trim()) {
      toast.error("لطفاً همه فیلدها را پر کنید", {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        theme: "light",
      });
      return;
    }

    setIsLoading(true);
    try {
      const res = await apiClient.post("/category", {
        name,
        description,
      });
      toast.success(res.data.msg, {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        theme: "light",
      });
      refreshCategories(); // Call the passed function to refresh categories list
      onClose(); // Close the modal
    } catch (error) {
      console.error(error);
      toast.error(
        error.response?.data?.msg || "خطا در اضافه کردن دسته بندی جدید",
        {
          position: "top-right",
          autoClose: 5000,
          closeOnClick: true,
          pauseOnHover: true,
          draggable: true,
          theme: "light",
        }
      );
    } finally {
      setIsLoading(false);
      setName(""); // Reset the name field
      setDescription(""); // Reset the description field
    }
  };

  return (
    <>
      <Button onClick={onOpen} colorScheme="teal" marginTop={10} marginRight={20}>
        اضافه کردن دسته بندی جدید
      </Button>

      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>دسته بندی جدید</ModalHeader>
          <ModalCloseButton />
          <ModalBody pb={6}>
            <FormControl>
              <FormLabel>دسته بندی</FormLabel>
              <Input
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="اسم دسته بندی"
              />
            </FormControl>

            <FormControl mt={4}>
              <FormLabel>تفصیلات</FormLabel>
              <Input
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="تفصیلات"
              />
            </FormControl>
          </ModalBody>

          <ModalFooter>
            <Button
              colorScheme="blue"
              mr={3}
              onClick={handleAddCategory}
              isLoading={isLoading}
            >
              ثبت
            </Button>
            <Button onClick={onClose}>لغو</Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
};

export default AddCategory;
