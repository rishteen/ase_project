import { useNavigate } from "react-router-dom";

import {
  Box,
  Button,
  Checkbox,
  FormControl,
  FormLabel,
  Input,
  Select,
  SimpleGrid,
} from "@chakra-ui/react";

function RestaurantForm() {
  const navigate = useNavigate();
  const categories = [
    "ایتالیایی",
    "میکزیکی",
    "چینی",
    "ژاپنی",
    "فست فود",
    "ایرانی",
    "افغانی",
  ];
  const handleCancel = () => {
    // Navigate back to home page
    navigate("/"); // Adjust the path as needed
  };
  return (
    <Box p={4}>
      <form>
        <SimpleGrid columns={[1, null, 2]} spacing={4}>
          {/* Name */}
          <FormControl isRequired>
            <FormLabel htmlFor="name">اسم رستوران</FormLabel>
            <Input id="name" type="text" />
          </FormControl>

          {/* Image File Input */}
          <FormControl>
            <FormLabel htmlFor="image">عکس</FormLabel>
            <Input id="image" type="file" />
          </FormControl>

          {/* Latitude */}
          <FormControl isRequired>
            <FormLabel htmlFor="latitude">Latitude</FormLabel>
            <Input id="latitude" type="text" />
          </FormControl>

          {/* Longitude */}
          <FormControl isRequired>
            <FormLabel htmlFor="longitude">Longitude</FormLabel>
            <Input id="longitude" type="text" />
          </FormControl>

          {/* Phone */}
          <FormControl>
            <FormLabel htmlFor="phone">شماره تماس</FormLabel>
            <Input id="phone" type="tel" />
          </FormControl>

          {/* Email */}
          <FormControl>
            <FormLabel htmlFor="email">آدرس الکترونیکی</FormLabel>
            <Input id="email" type="email" />
          </FormControl>

          {/* Facebook */}
          <FormControl>
            <FormLabel htmlFor="facebook">فیسبوک</FormLabel>
            <Input id="facebook" type="text" />
          </FormControl>

          {/* Instagram */}
          <FormControl>
            <FormLabel htmlFor="instagram">اینستاگرام</FormLabel>
            <Input id="instagram" type="text" />
          </FormControl>

          {/* WhatsApp */}
          <FormControl>
            <FormLabel htmlFor="whatsapp">شماره واتس آپ</FormLabel>
            <Input id="whatsapp" type="text" />
          </FormControl>

          {/* Web */}
          <FormControl>
            <FormLabel htmlFor="web">ویب</FormLabel>
            <Input id="web" type="url" />
          </FormControl>

          {/* City */}
          <FormControl>
            <FormLabel htmlFor="city">شهر</FormLabel>
            <Input id="city" type="text" />
          </FormControl>

          {/* District */}
          <FormControl>
            <FormLabel htmlFor="district">منطقه</FormLabel>
            <Input id="district" type="text" />
          </FormControl>

          {/* Street */}
          <FormControl>
            <FormLabel htmlFor="street">خیابان</FormLabel>
            <Input id="street" type="text" />
          </FormControl>

          {/* Avenue */}
          <FormControl>
            <FormLabel htmlFor="avenue">کوچه</FormLabel>
            <Input id="avenue" type="text" />
          </FormControl>

          {/* Postal Code */}
          <FormControl>
            <FormLabel htmlFor="postal_code">کد پستی</FormLabel>
            <Input id="postal_code" type="text" />
          </FormControl>

          {/* Opening Time */}
          <FormControl>
            <FormLabel htmlFor="opening_time">ساعت شروع سرویس</FormLabel>
            <Input id="opening_time" type="time" />
          </FormControl>

          {/* Closing Time */}
          <FormControl>
            <FormLabel htmlFor="closing_time">ساعت ختم سرویس</FormLabel>
            <Input id="closing_time" type="time" />
          </FormControl>

          {/* Working Days */}
          <FormControl>
            <FormLabel htmlFor="working_days">روز های کاری</FormLabel>
            <Input id="working_days" type="text" />
          </FormControl>

          {/* Deliver */}
          <FormControl>
            <Checkbox id="deliver">خدمات درب منزل</Checkbox>
          </FormControl>

          {/* Takeaway */}
          <FormControl>
            <Checkbox id="takeaway">خدمات سرپایی</Checkbox>
          </FormControl>

          {/* Currently Serving */}
          <FormControl>
            <Checkbox id="serving">سرویس سرو داخلی</Checkbox>
          </FormControl>

          {/* Category */}
          <FormControl>
            <FormLabel htmlFor="category">دسته بندی</FormLabel>
            <Select id="category" placeholder="انتخاب دسته بندی">
              {categories.map((category) => (
                <option key={category} value={category}>
                  {category}
                </option>
              ))}
            </Select>
          </FormControl>
        </SimpleGrid>

        {/* Submit and Cancel Buttons */}
        <Box display="flex" justifyContent="space-between" mt={4}>
          <Button colorScheme="blue" type="submit">
            ثبت رستوران
          </Button>
          <Button colorScheme="red" onClick={handleCancel}>
            بازگشت به صفحه اصلی
          </Button>
        </Box>
      </form>
    </Box>
  );
}

export default RestaurantForm;
