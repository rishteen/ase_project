import { useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { Grid, GridItem, HStack, Show } from "@chakra-ui/react";
import NavBar from "./components/NavBar";
import RestaurantGrid from "./components/RestaurantGrid";
import AddRestaurant from "./components/AddRestaurant";
import CategpryList from "./components/CategpryList";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import CategoryListAsSideMenu from "./components/CategoryListAsSideMenu";
import { Category } from "./hooks/useCategory";
import SortSelector from "./components/SortOrderSelector";
import RestaurantHeading from "./components/RestaurantHeading";

export interface RestaurantQuery {
  category: Category | null;
  searchText: string;
  sortOrder: string;
}
function App() {
  const [restaurantQuery, setRestaurantQuery] = useState<RestaurantQuery>(
    {} as RestaurantQuery
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
          <NavBar
            onSearch={(searchText) =>
              setRestaurantQuery({ ...restaurantQuery, searchText })
            }
          />
        </GridItem>
        <Show above="lg">
          <GridItem area="aside" paddingX={3} paddingY={6}>
            <CategoryListAsSideMenu
              selectedCategory={restaurantQuery.category}
              onSelectCategory={(category) =>
                setRestaurantQuery({ ...restaurantQuery, category })
              }
            />
          </GridItem>
        </Show>
        <GridItem area="main">
          <HStack paddingRight={8} marginTop={7}>
            <RestaurantHeading restaurantQuery={restaurantQuery} />
            <SortSelector
              sortOrder={restaurantQuery.sortOrder}
              onSelectSortOrder={(sortOrder) =>
                setRestaurantQuery({ ...restaurantQuery, sortOrder })
              }
            />
          </HStack>
          <Routes>
            <Route
              path="/"
              element={<RestaurantGrid restaurantQuery={restaurantQuery} />}
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
