import { postData, getData,getRandom } from "../utils.js";


const category = [
  {
    "__type": "Pointer",
    "className": "Category",
    objectId: "zzCG0AtaNp",
    createdAt: "2024-02-15T21:44:14.462Z",
    updatedAt: "2024-02-15T21:44:14.462Z",
    name: "irani",
    description: "Delicious irani's food",
  },
  {
    "__type": "Pointer",
    "className": "Category",
    objectId: "lrNzJqVkzr",
    createdAt: "2024-02-15T21:44:28.011Z",
    updatedAt: "2024-02-15T21:44:28.011Z",
    name: "farangi",
    description: "Delicious farangi's food",
  },
  {
    "__type": "Pointer",
    "className": "Category",
    objectId: "nD1aOPUIAF",
    createdAt: "2024-02-15T21:44:39.912Z",
    updatedAt: "2024-02-15T21:44:39.912Z",
    name: "fastfood",
    description: "Delicious fastfood food",
  },
  {
    "__type": "Pointer",
    "className": "Category",
    objectId: "csFI7CCFvJ",
    createdAt: "2024-02-15T21:44:50.483Z",
    updatedAt: "2024-02-15T21:44:50.483Z",
    name: "sonati",
    description: "Delicious sonati food",
  },
];


const cities = [
  ...Array(30).fill("Tehran"),
  ...Array(20).fill("Sari"),
  ...Array(30).fill("Isfahan"),
  ...Array(34).fill("Shiraz"),
  ...Array(10).fill("Sari"),
  ...Array(10).fill("Qom"),
  ...Array(10).fill("Yazd"),
  ...Array(40).fill("Mashhad"),
];
const generateNearbyCoordinate = (centerLat, centerLong) => {
  const latOffset = getRandomOffset(0.1); // 0.1 degrees is approximately 11.1 kilometers
  const longOffset = getRandomOffset(0.1);
  const latitude = centerLat + latOffset;
  const longitude = centerLong + longOffset;
  return { latitude, longitude };
};

const getRandomOffset = (range) => {
  return (Math.random() - 0.5) * range * 2; // -range to +range
};
function getRandomRestaurantName() {
  const restaurantNames = [
    "The Hungry Hippo",
    "Savory Spice",
    "Bella Italia",
    "Golden Dragon",
    "The Rusty Spoon",
    "Café Paris",
    "Mama Mia's Pizzeria",
    "Sushi Samurai",
    "Taco Fiesta",
    "Burger Barn",
    "Thai Orchid",
    "Salam Restaurant",
    "Persian Grill",
    "Saffron House",
    "Darya Restaurant",
    "Shiraz Palace",
    "Kebab Corner",
    "Tehran Delight",
    "Caspian Seafood",
    "Kabab Koobideh",
    "Jooje Kabab",
    "Gol-e Reza",
    "Shahrzad Restaurant",
    "Taste of Persia",
    "Yas Restaurant",
    "Parsian Kitchen",
    "Caspian Delight",
    "Koobideh King",
    "Caspian Nights",
    "Behesht Restaurant",
    "Kebab Khazana",
    "Persian Star",
    "Shamshiri Grill",
    "Farsi Restaurant",
    "Saffron Lounge",
    "Persian Spice",
    "Darya Kabab",
    "Kabab Tabei",
    "Shirin Palace",
    "Chelo Kabab",
    "Parsian Delight",
    "Ariana Restaurant",
    "Jasmine Restaurant",
    "Persian Garden",
    "Kebab Palace",
    "Iranian Grill",
    "Shabestan Restaurant",
    "Persian Oasis",
    "Rose Kabab",
    "Tehran Kitchen",
    "Alborz Restaurant",
    "Cafe Nadia",
    "Persian Bazaar",
    "Saffron Bistro",
    "Pars Grill",
    "Saraye Saadat",
    "Shandiz Restaurant",
    "Bam-e Tehran",
    "Shirin Cafe",
    "Behrouz Restaurant",
    "Parsian Grill",
    "Joon Kabab",
    "Persian House",
    "Shabestan Kabab",
    "Yas Restaurant",
    "Persian Feast",
    "Parsian Palace",
    "Kabab Bonanza",
    "Iranian Kitchen",
    "Saffron House",
    "Salam Persian Kitchen",
    "Negin Restaurant",
    "Persian Plate",
    "Saffron Hill",
    "Persian Flavor",
    "Taste of Iran",
    "Rosewater Grill",
    "Parsian Nights",
    "Chahar Bagh Restaurant",
    "Kabab-e Tond",
    "Kababesh",
    "Persian Pearl",
    "Aladdin Restaurant",
    "Parsian Delight",
    "Gol Koochik",
    "Dizi Sara",
    "Zahr Restaurant",
    "Persian Garden",
    "Iranian Kabab",
    "Kabab Barg",
    "Persian Saffron",
    "Shirin Palace",
    "Bam-e Tehran",
    "Behesht Grill",
    "Shiraz Kabab",
    "Fanoos Restaurant",
    "Persian Garden",
    "Salam Kabab",
    "Chelo Kabab",
    "Dizi Sara",
    "Kebab Koobideh",
    "Behesht Grill",
    "Saffron House",
    "Persian Bazaar",
    "Kabab Tabei",
    "Persian Star",
    "Shirin Cafe",
    "Taste of Persia",
    "Saffron Palace",
    "Kebab Khazana",
    "Iranian Grill",
    "Persian Oasis",
    "Peking Palace",
    "La Casa de Tapas",
    "Mighty Steakhouse",
    "Cozy Corner Cafe",
    "Flavors of India",
    "Sizzling Sizzlers",
    "Crispy Crust Pizza",
    "The Spice Route",
    "Pasta Paradise",
    "Smoky BBQ Joint",
    // Add more restaurant names here as needed
  ];

  const randomIndex = Math.floor(Math.random() * restaurantNames.length);
  return restaurantNames[randomIndex];
}

const generateLocations = () => {
  const locations = [];
  for (const city of cities) {
    let centerLat, centerLong;
    switch (city) {
      case "Tehran":
        centerLat = 35.6892;
        centerLong = 51.389;
        break;
      case "Tabriz":
        centerLat = 38.0805;
        centerLong = 46.3014;
        break;
      case "Isfahan":
        centerLat = 32.6546;
        centerLong = 51.6676;
        break;
      case "Shiraz":
        centerLat = 29.5916;
        centerLong = 52.5836;
        break;
      case "Sari":
        centerLat = 36.5633;
        centerLong = 53.0601;
        break;
      case "Qom":
        centerLat = 34.5;
        centerLong = 50.8;
        break;
      case "Yazd":
        centerLat = 31.8;
        centerLong = 54.0;
        break;
      case "Mashhad":
        centerLat = 36.2;
        centerLong = 59.4;
        break;
      default:
        centerLat = 0;
        centerLong = 0;
    }
    const { latitude, longitude } = generateNearbyCoordinate(
      centerLat,
      centerLong
    );
    var name = getRandomRestaurantName();
    var category_id = getRandom(category);
    var is_verified = true;
    var opening_time = getRandom(["8:00", "9:00", "10:00"]);
    var closing_time = getRandom(["18:00", "19:00", "22:00"]);
    var views_rate = Math.random() * 10;
    var working_days = "all days";
    locations.push({
      name,
      city,
      latitude,
      longitude,
      category_id,
      is_verified,
      opening_time,
      closing_time,
      views_rate,
      working_days,
    });
  }
  return locations;
};

const requestPayload = generateLocations();

// Example usage:
var url = "http://localhost:1337/parse/classes/Restaurant";
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
// console.log(requestPayload);

// var url = "http://localhost:1337/parse/classes/Category";
// const res = await getData(url);
// console.log(res);
// console.log(getRandom(category));
