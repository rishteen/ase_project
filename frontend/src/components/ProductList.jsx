import React, { useEffect, useState } from 'react';
import axios from "axios";
import { toast } from "react-toastify";
import Navbar from "./NavBar";
import { Link } from 'react-router-dom';

const ProductList = () => {
  const [products, setProducts] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedProductId, setSelectedProductId] = useState(null);

  useEffect(() => {
    getProducts();
  }, []);

  const getProducts = async () => {
    try {
      const res = await axios.get("http://localhost:5080/products");
      setProducts(res.data);
    } catch (error) {
      console.error("Error fetching products:", error);
      // Handle error feedback to user here
    }
  };

  const deleteProduct = async () => {
    try {
      const res = await axios.delete(`http://localhost:5080/product/${selectedProductId}`);
      toast(res.data.msg, {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        theme: "light",
      });

      setProducts(currentProducts => currentProducts.filter(product => product.id !== selectedProductId));
      setIsModalOpen(false); // Close modal after deletion
    } catch (error) {
      console.error("Error deleting product:", error);
      // Handle error feedback to user here
    }
  };

  const showDeleteConfirmation = (productId) => {
    setSelectedProductId(productId);
    setIsModalOpen(true);
  };

  const ConfirmationModal = () => (
    <div className={`modal ${isModalOpen ? 'is-active' : ''}`}>
      <div className="modal-background"></div>
      <div className="modal-content">
        <p>?Are you sure you want to delete this product</p>
        <button onClick={deleteProduct} className="button is-danger">Delete</button>&nbsp;
        <button onClick={() => setIsModalOpen(false)} className="button">Cancel</button>
      </div>
      <button className="modal-close is-large" aria-label="close" onClick={() => setIsModalOpen(false)}></button>
    </div>
  );

  return (
    <>
      <Navbar />
      <div className="container mt-5">
        <div className="columns is-multiline">
          {products.map(product => (
            <div className="column is-one-quarter" key={product.id}>
              <div className="card">
                <div className="card-image">
                  <figure className="image">
                    <img className="home-img" src={product.url} alt={product.name} />
                  </figure>
                </div>
                <div className="card-content">
                  <div className="media">
                    <div className="media-content">
                      <p className="title is-size-5">{product.name}</p>
                    </div>
                  </div>
                </div>
                <footer className="card-footer">
                  <Link to={`/edit/${product.id}`}className="card-footer-item">ویرایش</Link>
                  <a onClick={() => showDeleteConfirmation(product.id)} className="card-footer-item">حذف</a>
                </footer>
              </div>
            </div>
          ))}
        </div>
      </div>
      {isModalOpen && <ConfirmationModal />}
    </>
  );
};

export default ProductList;
