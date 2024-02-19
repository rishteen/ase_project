import { postData, getData, getRandom, genRandomNumber } from "../utils.js";

const usernames = [
  "coolUser123",
  "awesomeCoder",
  "webMaster",
  "techExplorer",
  "codeNinja",
  "user1234",
  "codingPro",
  "devGuru",
  "javascriptLover",
  "geekyCoder",
  "ArtisticSoul",
  "FitnessFreak123",
  "SunnyDayz",
  "MysterySolver",
  "HappyHarmony",
  "RainbowChaser",
  "MoonlightDreamer",
  "StarStruck89",
  "WonderWoman78",
  "CaptainMarvel22",
  "PixelPioneer",
  "EagleEye22",
  "NightOwl76",
  "OceanExplorer",
  "RocketMan47",
  "CookieMonster",
  "MagicMinds",
  "TigerLily88",
  "DreamCatcher",
  "SilverSurfer99",
  "GoldenHeart22",
  "EternalOptimist",
  "PandaPilot",
  "SailingSerenity",
  "GuitarGuru77",
  "CosmicVoyager",
  "ZephyrZodiac",
  "WhimsicalWanderer",
  "AquaAdventurer",
];

const generateUsers = () => {
  const users = [];
  var conuter = 0;
  for (var username of usernames) {
    var email = username + "@gmail.com";
    var password = "1234";
    var is_restaurant_owner = false;
    if (conuter <= 10) {
      is_restaurant_owner = true;
      conuter++;
    }
    var is_admin = false;
    var name=username;
    var lastname=name;
    var firstname=name;

    users.push({
      username,
      email,
      password,
      is_restaurant_owner,
      is_admin,
      name,
      lastname,
      firstname,
    });
  }
  return users;
};
const generateAdminUsers = () => {
  const users = [];
  var conuter = 0;
  for (var username of ["ali","ahmad","ramin","azin","karim","mohammad"]) {
    var email = username + "@gmail.com";
    var password = "1234";
    var is_restaurant_owner = false;
    
    var is_admin = true;
    var name=username;
    var lastname=name;
    var firstname=name;

    users.push({
      username,
      email,
      password,
      is_restaurant_owner,
      is_admin,
      name,
      lastname,
      firstname,
    });
  }
  return users;
};

// const requestPayload = generateUsers();
const requestPayload = generateAdminUsers();

// Example usage:
var url = "http://localhost:1337/parse/classes/_User";
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
