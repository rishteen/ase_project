// AddCategory.js

import React, { useEffect, useState } from "react";
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
import { useNavigate } from "react-router-dom";

const AddCategory = () => {
  const { isOpen, onOpen, onClose } = useDisclosure();
  const navigate = useNavigate();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  const handleAddCategory = async () => {
    try {
      const response = await apiClient.post("/category", {
        name: name,
        description: description,
      });
      toast.success(response.data.msg, {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        theme: "light",
      });
      navigate("/categories");
      onClose(); // Close the modal
      setName(""); // Reset the name field
      setDescription(""); // Reset the description field
      // Optionally, refresh the category list if this component is part of a larger component that displays categories
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
    }
  };

  return (
    <>
      <Button onClick={onOpen} colorScheme="teal">
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
            <Button colorScheme="blue" mr={3} onClick={handleAddCategory}>
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
