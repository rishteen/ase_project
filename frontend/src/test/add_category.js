import { postData, getData, getRandom, genRandomNumber } from "../utils.js";

const foodCategoriesForTest = [
  "Appetizers",
  "Main Course",
  "Desserts",
  "Beverages",
  "Salads",
  "Snacks",
  // "Soups",
  // "Breakfast",
  // "Lunch",
  // "Dinner",
  // "Vegetarian",
  // "Vegan",
  // "Gluten-Free",
  // "Seafood",
  // "Pasta",
  // "Pizza",
  // "Burgers",
  // "Sandwiches",
  // "Mexican",
  // "Italian",
  // "Asian",
  // "Mediterranean",
  // "Indian",
  // "Chinese",
  // "Japanese",
  // "Thai",
  // "Korean",
  // "Middle Eastern",
  // "American",
  // "European",
  // "African",
  // "Latin American",
  // "Fusion",
  // "Comfort Food",
  // "Healthy",
  // "Organic",
  // "Local",
  // "Street Food",
  // "BBQ",
  // "Grilled",
  // "Fried",
  // "Spicy",
  // "Sweet",
  // "Savory",
];


const generateCategories = () => {
  const categories = [];
  var conuter = 0;
  for (var category of foodCategoriesForTest) {
    var name = "Test " + category;
    var description = name + "category";

    categories.push({
      name,
      description,
    });
  }
  return categories;
};

// const requestPayload = generateUsers();
const requestPayload = generateCategories();

// Example usage:
var url = "https://parse-server.liara.run/parse/classes/Category";
// console.log(requestPayload[0])
for (var data of requestPayload) {
  console.log(data);
  const res = await postData(url, data, (error, responseData) => {
    if (error) {
      console.error("Error:", error);
    } else {
      console.log("Response:", responseData);
    }
  });
  console.log(res);
}
console.log(requestPayload);

// var url = "http://localhost:1337/parse/classes/Category";
// const res = await getData(url);
// console.log(
//   res.results.map((o) => ({
//     objectId: o.objectId,
//     __type: "Pointer",
//     className: "Category",
//   }))
// );
// console.log(getRandom(category));
