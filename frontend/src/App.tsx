import React, { useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { Grid, GridItem, Show } from "@chakra-ui/react";
import NavBar from "./components/NavBar";
import RestaurantGrid from "./components/RestaurantGrid";
import AddRestaurant from "./components/AddRestaurant";
import CategpryList from "./components/CategpryList";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import CategoryListAsSideMenu from "./components/CategoryListAsSideMenu";
import { Category } from "./hooks/useCategory";
function App() {
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(
    null
  );
  return (
    <BrowserRouter>
      <Grid
        templateAreas={{
          base: `"nav" "main"`,
          lg: `"nav nav" "aside main"`,
        }}
        templateColumns={{
          base: "1fr",
          lg: "200px 1fr",
        }}
      >
        <GridItem area="nav">
          <NavBar />
        </GridItem>
        <Show above="lg">
          <GridItem area="aside" paddingX={3} paddingY={6}>
            <CategoryListAsSideMenu
              onSelectCategory={(category) => setSelectedCategory(category)}
            />
          </GridItem>
        </Show>
        <GridItem area="main">
          <Routes>
            <Route
              path="/"
              element={<RestaurantGrid selectedCategory={selectedCategory} />}
            />
            <Route path="/addrestaurant" element={<AddRestaurant />} />
            <Route path="/categories" element={<CategpryList />} />
            {/* Add more routes as needed */}
          </Routes>
        </GridItem>
      </Grid>
      <ToastContainer />
    </BrowserRouter>
  );
}

export default App;
