import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { Grid, GridItem, Show } from "@chakra-ui/react";
import NavBar from "./components/NavBar";
import RestaurantGrid from "./components/RestaurantGrid";
import AddRestaurant from "./components/AddRestaurant";
import CategpryList from "./components/CategpryList";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import CategoryListAsSideMenu from "./components/CategoryListAsSideMenu";
function App() {
  return (
    <BrowserRouter>
      <Grid
        templateAreas={{
          base: `"nav" "main"`,
          lg: `"nav nav" "aside main"`,
        }}
      >
        <GridItem area="nav">
          <NavBar />
        </GridItem>
        <Show above="lg">
          <GridItem area="aside">
            <CategoryListAsSideMenu />
          </GridItem>
        </Show>
        <GridItem area="main">
          <Routes>
            <Route path="/" element={<RestaurantGrid />} />
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
