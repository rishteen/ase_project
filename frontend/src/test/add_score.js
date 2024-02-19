import { postData, getData, getRandom, genRandomNumber } from "../utils.js";
const users_data = await getData(
  'http://localhost:1337/parse/classes/_User?where={"is_restaurant_owner":false,"is_admin":false}'
);
const users = users_data.results.map((o) => ({
  objectId: o.objectId,
  __type: "Pointer",
  className: "_User",
}));
const restaurant_data = await getData(
  "http://localhost:1337/parse/classes/Restaurant"
);
const restaurant_objects = restaurant_data.results.map((o) => ({
  objectId: o.objectId,
  __type: "Pointer",
  className: "Restaurant",
}));

const generateScore = () => {
  const score = [];
  for (var i = 0; i < 5000; i++) {
    var restaurant_id = getRandom(restaurant_objects);
    var user_id = getRandom(users);
    var employee_behave_score = genRandomNumber(0, 5);
    var restaurant_cleanliness_score = genRandomNumber(0, 5);
    var food_quality_score = genRandomNumber(0, 5);
    var taste_of_food_score = genRandomNumber(0, 5);
    var side_services_score = genRandomNumber(0, 5);

    score.push({
      restaurant_id,
      user_id,
      employee_behave_score,
      restaurant_cleanliness_score,
      food_quality_score,
      taste_of_food_score,
      side_services_score,
    });
  }
  return score;
};

const requestPayload = generateScore();

// Example usage:
var url = "http://localhost:1337/parse/classes/Score";
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
