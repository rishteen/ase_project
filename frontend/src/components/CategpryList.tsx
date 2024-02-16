import React, { useEffect, useState } from "react";
import {
  Table,
  Thead,
  Tbody,
  Tfoot,
  Tr,
  Td,
  TableContainer,
  Button,
  AlertDialog,
  AlertDialogBody,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogContent,
  AlertDialogOverlay,
  useDisclosure,
} from "@chakra-ui/react";
import { toast } from "react-toastify";
import { Link } from "react-router-dom";
import apiClient from "../services/api-client";
import AddCategory from "./AddCategory";
import UpdateCategory from "./UpdateCategory";
import { getCategory,deleteCategoryById } from "../hooks/api_v2/fetchCategory";
const CategoryList = () => {
  const [categories, setCategories] = useState([]);
  const [categoryobjectIdToDelete, setCategoryobjectIdToDelete] = useState(null);
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [currentCategory, setCurrentCategory] = useState(null);
  const {
    isOpen: isUpdateModalOpen,
    onOpen: onOpenUpdateModal,
    onClose: onCloseUpdateModal,
  } = useDisclosure();

  useEffect(() => {
    getCategories();
  }, []);

  const getCategories = async () => {
    try {
      // const res = await apiClient.get("/categories");
      // setCategories(res.data);
      const res = await getCategory();
      setCategories(res);
    } catch (error) {
      toast.error("Failed to fetch categories. Please try again later.", {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        theme: "light",
      });
      console.error("Error fetching categories:", error);
    }
    const handleEditCategory = (category) => {
      setCurrentCategory(category);
      onOpenUpdateModal();
    };
  };

  const deleteCategory = async () => {
    try {
      const res = await deleteCategoryById(categoryobjectIdToDelete);
      toast.success(res, {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        theme: "light",
      });
      setCategories(
        categories.filter((category) => category.objectId !== categoryobjectIdToDelete)
      );
      onClose(); // Close the confirmation dialog
    } catch (error) {
      console.error(error);
      toast.error("خطا در حذف کردن دسته بندی", {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        theme: "light",
      });
    }
  };

  const askDeleteCategory = (categoryobjectId) => {
    setCategoryobjectIdToDelete(categoryobjectId);
    onOpen();
  };

  // Confirmation dialog cancel ref
  const cancelRef = React.useRef();
  const handleEditCategory = (category) => {
    setCurrentCategory(category); // Set the current category for editing
    onOpenUpdateModal(); // Open the modal for updating
  };

  return (
    <>
      <AddCategory refreshCategories={getCategories} />
      <TableContainer padding={20}>
        <Table size="sm">
          <Thead>
            <Tr>
              <th>#</th>
              <th>دسته بندی</th>
              <th>تفصیلات</th>
              <th>عملیات</th>
            </Tr>
          </Thead>
          <Tbody>
            {categories.map((category, index) => (
              <Tr key={category.objectId}>
                <Td>{index + 1}</Td> {/* Use index + 1 for row count */}
                <Td>{category.name}</Td>
                <Td>{category.description}</Td>
                <Td>
                  <Button
                    colorScheme="blue"
                    size="sm"
                    onClick={() => handleEditCategory(category)}
                  >
                    ویرایش
                  </Button>
                  {"  "}
                  <Button
                    colorScheme="red"
                    size="sm"
                    onClick={() => askDeleteCategory(category.objectId)}
                  >
                    حذف
                  </Button>
                </Td>
              </Tr>
            ))}
          </Tbody>

          <Tfoot>
            <Tr>
              <th>#</th>
              <th>دسته بندی</th>
              <th>تفصیلات</th>
              <th>عملیات</th>
            </Tr>
          </Tfoot>
        </Table>
      </TableContainer>
      {currentCategory && (
        <UpdateCategory
          isOpen={isUpdateModalOpen}
          onClose={onCloseUpdateModal}
          category={currentCategory}
          refreshCategories={getCategories}
        />
      )}
      {/* Confirmation Dialog */}
      <AlertDialog
        isOpen={isOpen}
        leastDestructiveRef={cancelRef}
        onClose={onClose}
        isCentered
      >
        <AlertDialogOverlay>
          <AlertDialogContent>
            <AlertDialogHeader fontSize="lg" fontWeight="bold">
              حذف دسته بندی
            </AlertDialogHeader>

            <AlertDialogBody>
              مطمئني؟ بعد از آن نمی توانید این عمل را لغو کنید
            </AlertDialogBody>

            <AlertDialogFooter>
              <Button ref={cancelRef} onClick={onClose}>
                لغو
              </Button>
              <Button colorScheme="red" onClick={deleteCategory} ml={3}>
                حذف
              </Button>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialogOverlay>
      </AlertDialog>
    </>
  );
};

export default CategoryList;
