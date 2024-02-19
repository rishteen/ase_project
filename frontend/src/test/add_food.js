import { postData, getData, getRandom, genRandomNumber } from "../utils.js";
const restaurant_data = await getData(
  "http://localhost:1337/parse/classes/Restaurant"
);
const restaurant_objects = restaurant_data.results.map((o) => ({
  objectId: o.objectId,
  __type: "Pointer",
  className: "Restaurant",
}));
const persianFood = [
  "Kabab Koobideh",
  "Joojeh Kabab",
  "Ghormeh Sabzi",
  "Fesenjan",
  "Dizi",
  "Zereshk Polo",
  "Tahchin",
  "Baghali Polo",
  "Khoresh Bademjan",
  "Ashe Reshteh",
  "Mirza Ghasemi",
  "Gheimeh",
  "Ash-e Doogh",
  "Ash-e Anar",
  "Lubia Polo",
  "Mast-o-Khiar",
  "Kookoo Sabzi",
  "Abgoosht",
  "Khoresht-e Karafs",
  "Dolma",
  "Halim Bademjan",
  "Khoresht-e Bamieh",
  "Sabzi Polo",
  "Tachin Morgh",
  "Kalam Polo",
  "Aloo Mosamma",
  "Kufteh Tabrizi",
  "Baghali Ghatogh",
  "Halva",
  "Naz Khatoon",
  "Sholeh Zard",
  "Bastani Sonnati",
  "Shirin Polo",
  "Kuku",
  "Yatimcheh",
  "Ash-e Mast",
  "Morasa Polo",
  "Khagineh",
  "Tahdig",
  "Kalam Polo Mahicheh",
  "Khoresh-e Beh",
  "Shirin Adas",
  "Gondi",
  "Morgh-e Torsh",
  "Shami Kabab",
  "Khoresht-e Gheymeh Nesar",
  "Khoresh-e Karafs",
  "Kookoo Sibzamini",
  "Khoresh-e Beh",
  "Adas Polo",
  "Khagineh Gorgan",
  "Shirin Laboo",
  "Khoresh-e Loobia Sabz",
  "Khoresh-e Morgh Ba Zireh",
  "Baghali Polo ba Morgh",
  "Khoresht-e Gheymeh",
  "Khoresh-e Kardeh",
  "Khoresht-e Torsh",
  "Sheer Khurma",
  "Salad Shirazi",
  "Koloocheh",
  "Bastani Akbar Mashti",
  "Khagineh Yazdi",
  "Samanu",
  "Halva Ardeh",
  "Khoresht-e Alu Esfenaj",
  "Khoresh-e Maast",
  "Dizi Sara",
  "Khoresh-e Nokhodchi",
  "Ash-e Miveh",
  "Khagineh Kashan",
  "Halva Shekari",
  "Moraba-ye Beh",
  "Khoresh-e Karafs-e Holu",
  "Khoresh-e Mast",
  "Khoresh-e Anar",
  "Torshe Tareh",
  "Moraba-ye Anar",
  "Khoresh-e Sabzi",
  "Faloodeh",
  "Khoresh-e Baamieh",
  "Baghali Polo ba Goosht",
  "Moraba-ye Gerdoo",
  "Shirin Yazdi",
  "Khoresh-e Chelo",
  "Khoresh-e Havij",
  "Khoresh-e Gerdoo",
  "Sirabi",
  "Haleem",
  "Khoresh-e Kadoo",
  "Khoresh-e Gandom",
  "Khoresh-e Havij ba Morgh",
  "Nan-e Barbari",
  "Khoresh-e Haleem",
  "Khagineh Birjand",
  "Dizi Tabrizi",
  "Khoresht-e Gheimeh Sibzamini",
  "Moraba-ye Anar Daneh",
  "Khoresh-e Fesenjan",
  "Khagineh Tabriz",
];

const generateFoods = () => {
  const foods = [];
  for (var i = 0; i < 1000; i++) {
    var restaurant_id = getRandom(restaurant_objects);
    var name = getRandom(persianFood);
    var price = genRandomNumber(10,1000)*1000;
    var type_of_food=getRandom(["irani","sonati"])
    foods.push({
      restaurant_id,
      name,
      price,
      type_of_food
    });
  }
  return foods;
};

const requestPayload = generateFoods();

// Example usage:
var url = "http://localhost:1337/parse/classes/Food";
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
