import { getData, baseUrl, deleteData, updateData, postData } from "../utils";

export const getCategory = async (): Promise<Array<JSON>> => {
  try {
    const response = await getData(`${baseUrl}/classes/Category`);
    return response.results;
  } catch (error) {
    // Handle any network or parsing errors
    console.log("Error fetching data:", error);

    // Customize the returned error structure based on your needs
    throw new Error("Failed to fetch data");
  }
};
export const deleteCategoryById = async (id: string): Promise<JSON> => {
  try {
    const response = await deleteData(`${baseUrl}/classes/Category/${id}`);
    return response;
  } catch (error) {
    // Handle any network or parsing errors
    console.log("Error fetching data:", error);

    // Customize the returned error structure based on your needs
    throw new Error("Failed to fetch data");
  }
};
export const UpdateCategoryById = async (
  id: string,
  data: object
): Promise<JSON> => {
  try {
    const response = await updateData(`${baseUrl}/classes/Category/${id}`,data);
    return response;
  } catch (error) {
    // Handle any network or parsing errors
    console.log("Error fetching data:", error);

    // Customize the returned error structure based on your needs
    throw new Error("Failed to fetch data");
  }
};
export const AddCategoryByData = async (
  data: object
): Promise<JSON> => {
  try {
    const response = await postData(`${baseUrl}/classes/Category`,data);
    return response;
  } catch (error) {
    // Handle any network or parsing errors
    console.log("Error fetching data:", error);

    // Customize the returned error structure based on your needs
    throw new Error("Failed to fetch data");
  }
};