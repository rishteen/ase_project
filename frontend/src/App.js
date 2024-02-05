import AddProduct from "./components/AddProduct";
import ProductList from "./components/ProductList";
import {BrowserRouter, Routes, Route} from "react-router-dom";
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import EditProduct from "./components/EditProduct";

function App() {
  return  <>
    
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<ProductList/>}/>
        <Route path="/add" element={<AddProduct/>}/>
        <Route path="/edit/:id" element={<EditProduct/>}/>
      </Routes>
      <ToastContainer/>
    </BrowserRouter>
  </>
}

export default App;
