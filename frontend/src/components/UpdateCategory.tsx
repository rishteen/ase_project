import { useState, useEffect } from "react";
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
} from "@chakra-ui/react";
import { toast } from "react-toastify";
import apiClient from "../services/api-client";

const UpdateCategory = ({ isOpen, onClose, category, refreshCategories }) => {
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (category) {
      setName(category.name);
      setDescription(category.description);
    }
  }, [category]);

  const handleUpdateCategory = async () => {
    setIsSubmitting(true);
    try {
      const response = await apiClient.put(`/category/${category.id}`, {
        name,
        description,
      });
      toast.success(response.data.msg, {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        theme: "light",
      });
      refreshCategories(); // Refresh the category list in the parent component
      onClose(); // Close the modal
    } catch (error) {
      console.error(error);
      toast.error(
        error.response?.data?.msg || "خطا در به روز رسانی دسته بندی",
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
      setIsSubmitting(false);
    }
  };

  useEffect(() => {
    if (!isOpen) {
      setName("");
      setDescription("");
    }
  }, [isOpen]);

  return (
    <>
      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>به روز رسانی دسته بندی</ModalHeader>
          <ModalCloseButton />
          <ModalBody pb={6}>
            <FormControl>
              <FormLabel htmlFor="categoryName">دسته بندی</FormLabel>
              <Input
                id="categoryName"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="اسم دسته بندی"
              />
            </FormControl>

            <FormControl mt={4}>
              <FormLabel htmlFor="categoryDescription">تفصیلات</FormLabel>
              <Input
                id="categoryDescription"
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
              onClick={handleUpdateCategory}
              isLoading={isSubmitting}
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

export default UpdateCategory;
