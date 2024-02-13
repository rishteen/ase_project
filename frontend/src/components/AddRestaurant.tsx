import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { FaFacebookF, FaInstagram, FaWhatsapp } from "react-icons/fa";
import { MdEmail, MdWeb, MdPhone } from "react-icons/md"; // Example: Assuming you're using Material Design icons for some
import { toast } from "react-toastify";
import {
  Box,
  Button,
  FormControl,
  FormLabel,
  Input,
  Image,
  VStack,
  Container,
  Text,
  Checkbox,
  SimpleGrid,
  GridItem,
  InputGroup,
  InputLeftElement,
  Select,
} from "@chakra-ui/react";
import {
  MapContainer,
  TileLayer,
  Marker,
  useMapEvents,
  Popup,
} from "react-leaflet";
import L from "leaflet";
import apiClient from "../services/api-client";
import "leaflet/dist/leaflet.css"; // Ensure you have this CSS import for Leaflet's styles

const AddRestaurant = () => {
  const [title, setTitle] = useState("");
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState("");
  const [location, setLocation] = useState({ lat: 0, lng: 0 });
  const [deliver, setDeliver] = useState(false);
  const [takeaway, setTakeaway] = useState(false);
  const [serving, setServing] = useState(false);
  const [phone, setPhone] = useState("");
  const [facebook, setFacebook] = useState("");
  const [instagram, setInstagram] = useState("");
  const [whatsapp, setWhatsapp] = useState("");
  const [email, setEmail] = useState("");
  const [web, setWeb] = useState("");
  const [city, setCity] = useState("");
  const [district, setDistrict] = useState("");
  const [street, setStreet] = useState("");
  const [avenue, setAvenue] = useState("");
  const [postal_code, setPostalCode] = useState("");
  const [opening_time, setOpeningTime] = useState("");
  const [closing_time, setClosingTime] = useState("");
  const [working_days, setWorkingDays] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState("");
  const [categories, setCategories] = useState([]);

  const allDays = [
    "شنبه",
    "یکشنبه",
    "دوشنبه",
    "سه شنبه",
    "چهارشنبه",
    "پنجشنبه",
    "جمعه",
  ];

  const navigate = useNavigate();

  useEffect(() => {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        setLocation({ lat: latitude, lng: longitude });
      },
      () => {
        console.error("Geolocation is not supported or permission was denied.");
        setLocation({ lat: 0, lng: 0 });
      }
    );
  }, []);

  const LocationMarker = () => {
    const map = useMapEvents({
      click(e) {
        setLocation(e.latlng);
        map.flyTo(e.latlng, map.getZoom());
      },
    });

    return location !== null ? (
      <Marker position={location}>
        <Popup>You are here</Popup>
      </Marker>
    ) : null;
  };

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await apiClient.get("/categories"); // Adjust the endpoint as needed
        setCategories(response.data);
      } catch (error) {
        console.error("Failed to fetch categories:", error);
        toast.error("Failed to load categories.", {
          position: "top-right",
          autoClose: 5000,
          closeOnClick: true,
          pauseOnHover: true,
          draggable: true,
        });
      }
    };

    fetchCategories();
  }, []);

  const loadImage = (e) => {
    const image = e.target.files[0];
    setFile(image);
    setPreview(URL.createObjectURL(image));
  };

  const handleDayChange = (day) => {
    if (working_days.includes(day)) {
      setWorkingDays(working_days.filter((d) => d !== day));
    } else {
      setWorkingDays([...working_days, day]);
    }
  };

  const saveRestaurant = async (e) => {
    e.preventDefault();
    const formData = new FormData();
    formData.append("file", file);
    formData.append("title", title);
    formData.append("latitude", location.lat);
    formData.append("longitude", location.lng);
    formData.append("deliver", deliver);
    formData.append("takeaway", takeaway);
    formData.append("serving", serving);
    formData.append("phone", phone);
    formData.append("facebook", facebook);
    formData.append("instagram", instagram);
    formData.append("whatsapp", whatsapp);
    formData.append("email", email);
    formData.append("web", web);
    formData.append("city", city);
    formData.append("district", district);
    formData.append("street", street);
    formData.append("avenue", avenue);
    formData.append("postal_code", postal_code);
    formData.append("opening_time", opening_time);
    formData.append("closing_time", closing_time);
    formData.append("working_days", working_days.join(","));
    formData.append("category_id", selectedCategory);

    try {
      const res = await apiClient.post("/restaurant", formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });
      navigate("/");
      toast.success(res.data.msg, {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
      });
    } catch (error) {
      console.log(error);
      toast.error("An error occurred while saving the restaurant.", {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
      });
    }
  };

  return (
    <Container maxW="container.xl" centerContent>
      <Box
        p={5}
        shadow="md"
        borderWidth="1px"
        flex="1"
        borderRadius="md"
        width="full"
        mt={5}
      >
        <form onSubmit={saveRestaurant}>
          <SimpleGrid columns={{ base: 1, md: 2 }} spacing={10}>
            <VStack spacing={4} align="flex-start">
              {/* Column 1 Form Controls */}
              <FormControl isRequired>
                <FormLabel htmlFor="title">نام رستوران</FormLabel>
                <Input
                  id="title"
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                />
              </FormControl>

              <FormControl isRequired>
                <FormLabel htmlFor="category">دسته بندی</FormLabel>
                <Select
                  id="category"
                  placeholder="انتخاب دسته بندی"
                  value={selectedCategory}
                  onChange={(e) => setSelectedCategory(e.target.value)}
                >
                  {categories.map((category) => (
                    <option key={category.id} value={category.id}>
                      {category.name}
                    </option>
                  ))}
                </Select>
              </FormControl>

              <FormControl isRequired>
                <FormLabel htmlFor="opening_time">ساعت شروع خدمات</FormLabel>
                <Input
                  id="opening_time"
                  type="time"
                  value={opening_time}
                  onChange={(e) => setOpeningTime(e.target.value)}
                />
              </FormControl>

              <FormControl isRequired>
                <FormLabel htmlFor="closing_time">ساعت پایان خدمات</FormLabel>
                <Input
                  id="closing_time"
                  type="time"
                  value={closing_time}
                  onChange={(e) => setClosingTime(e.target.value)}
                />
              </FormControl>

              <FormControl>
                <FormLabel>روزهای کاری</FormLabel>
                {allDays.map((day) => (
                  <Checkbox
                    key={day}
                    isChecked={working_days.includes(day)}
                    onChange={() => handleDayChange(day)}
                  >
                    &nbsp;
                    {day}
                    &nbsp;
                  </Checkbox>
                ))}
              </FormControl>

              <FormControl display="flex" alignItems="center">
                <FormLabel htmlFor="deliver" mb="0">
                  سفارش غیر حضوری
                </FormLabel>
                <Checkbox
                  id="deliver"
                  isChecked={deliver}
                  onChange={(e) => setDeliver(e.target.checked)}
                />
              </FormControl>

              <FormControl display="flex" alignItems="center">
                <FormLabel htmlFor="takeaway" mb="0">
                  بیرون بر
                </FormLabel>
                <Checkbox
                  id="takeaway"
                  isChecked={takeaway}
                  onChange={(e) => setTakeaway(e.target.checked)}
                />
              </FormControl>

              <FormControl display="flex" alignItems="center">
                <FormLabel htmlFor="serving" mb="0">
                  حضور در رستوران{" "}
                </FormLabel>
                <Checkbox
                  id="serving"
                  isChecked={serving}
                  onChange={(e) => setServing(e.target.checked)}
                />
              </FormControl>

              <FormControl isRequired>
                <FormLabel htmlFor="file">عکس</FormLabel>
                <Input
                  id="file"
                  type="file"
                  p={1.5}
                  onChange={loadImage}
                  size="md"
                />
                {preview && (
                  <Image boxSize="128px" src={preview} alt="Preview" mt={2} />
                )}
              </FormControl>

              <FormControl>
                <FormLabel>موقعیت</FormLabel>
                <Text>
                  Latitude: {location.lat.toFixed(4)}, Longitude:{" "}
                  {location.lng.toFixed(4)}
                </Text>
                <Box height="300px" width="100%">
                  <MapContainer
                    center={[location.lat, location.lng]}
                    zoom={13}
                    style={{ height: "100%", width: "100%" }}
                  >
                    <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                    <LocationMarker />
                  </MapContainer>
                </Box>
              </FormControl>
              {/* Repeat similar structure for other inputs in the first column */}
            </VStack>
            <VStack spacing={4} align="flex-start">
              {/* Column 2 Form Controls */}
              <FormControl isRequired>
                <FormLabel htmlFor="city">شهر</FormLabel>
                <Input
                  id="city"
                  type="text"
                  value={city}
                  onChange={(e) => setCity(e.target.value)}
                />
              </FormControl>

              <FormControl>
                <FormLabel htmlFor="district">منطقه</FormLabel>
                <Input
                  id="district"
                  type="text"
                  value={district}
                  onChange={(e) => setDistrict(e.target.value)}
                />
              </FormControl>

              <FormControl>
                <FormLabel htmlFor="street">خیابان</FormLabel>
                <Input
                  id="street"
                  type="text"
                  value={street}
                  onChange={(e) => setStreet(e.target.value)}
                />
              </FormControl>

              <FormControl>
                <FormLabel htmlFor="avenue">کوچه</FormLabel>
                <Input
                  id="avenue"
                  type="text"
                  value={avenue}
                  onChange={(e) => setAvenue(e.target.value)}
                />
              </FormControl>

              <FormControl isRequired>
                <FormLabel htmlFor="postal_code">کد پستی</FormLabel>
                <Input
                  id="postal_code"
                  type="text"
                  value={postal_code}
                  onChange={(e) => setPostalCode(e.target.value)}
                />
              </FormControl>

              <FormControl isRequired>
                <FormLabel htmlFor="phone">شماره تماس</FormLabel>
                <InputGroup>
                  <InputLeftElement pointerEvents="none">
                    <MdPhone color="gray.300" />
                  </InputLeftElement>
                  <Input
                    id="phone"
                    type="tel"
                    placeholder="شماره تماس"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                  />
                </InputGroup>
              </FormControl>

              <FormControl>
                <FormLabel htmlFor="facebook">فیسبوک</FormLabel>
                <InputGroup>
                  <InputLeftElement pointerEvents="none">
                    <FaFacebookF color="gray.300" />
                  </InputLeftElement>
                  <Input
                    id="facebook"
                    placeholder="فیسبوک"
                    value={facebook}
                    onChange={(e) => setFacebook(e.target.value)}
                  />
                </InputGroup>
              </FormControl>

              <FormControl>
                <FormLabel htmlFor="instagram">اینستاگرام</FormLabel>
                <InputGroup>
                  <InputLeftElement pointerEvents="none">
                    <FaInstagram color="gray.300" />
                  </InputLeftElement>
                  <Input
                    id="instagram"
                    placeholder="اینستاگرام"
                    value={instagram}
                    onChange={(e) => setInstagram(e.target.value)}
                  />
                </InputGroup>
              </FormControl>

              <FormControl>
                <FormLabel htmlFor="whatsapp">واتس اپ</FormLabel>
                <InputGroup>
                  <InputLeftElement pointerEvents="none">
                    <FaWhatsapp color="gray.300" />
                  </InputLeftElement>
                  <Input
                    id="whatsapp"
                    type="tel"
                    placeholder="واتس اپ"
                    value={whatsapp}
                    onChange={(e) => setWhatsapp(e.target.value)}
                  />
                </InputGroup>
              </FormControl>

              <FormControl isRequired>
                <FormLabel htmlFor="email">آدرس ایمیل</FormLabel>
                <InputGroup>
                  <InputLeftElement pointerEvents="none">
                    <MdEmail color="gray.300" />
                  </InputLeftElement>
                  <Input
                    id="email"
                    type="email"
                    placeholder="ایمیل آدرس"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                  />
                </InputGroup>
              </FormControl>

              <FormControl>
                <FormLabel htmlFor="web">وب سایت</FormLabel>
                <InputGroup>
                  <InputLeftElement pointerEvents="none">
                    <MdWeb color="gray.300" />
                  </InputLeftElement>
                  <Input
                    id="web"
                    type="url"
                    placeholder="ویب سایت"
                    value={web}
                    onChange={(e) => setWeb(e.target.value)}
                  />
                </InputGroup>
              </FormControl>

              {/* Repeat similar structure for other inputs in the second column */}
            </VStack>
          </SimpleGrid>
          {/* Submit Button and any other controls that should span both columns */}
          <Box textAlign="center" width="full" marginTop="5">
            <Button colorScheme="teal" type="submit" size="md">
              ثبت رستوران
            </Button>
          </Box>
        </form>
      </Box>
    </Container>
  );
};

export default AddRestaurant;
