import React, { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom';
import Navbar from './NavBar';
import axios from 'axios';
import { useEffect } from 'react';
import { toast } from 'react-toastify';

const EditProduct = () => {
     const [title, setTitle] = useState("");
     const [file, setFile] = useState("");
     const [preview, setPreview] = useState("");
     const navigate = useNavigate();
     const {id} = useParams();
     const loadImage = (e) => {
          const image = e.target.files[0];
          setFile(image)
          setPreview(URL.createObjectURL(image))
     }

     useEffect(()=> {
          getProductById()
     }, [])
     const getProductById = async()=>{
          const res = await axios.get(`http://localhost:5080/product/${id}`)
          setTitle(res.data.name);
          setFile(res.data.image);
          setPreview(res.data.url)
     }



     const updateProduct = async(e)=> {
          e.preventDefault();
          const formdata = new FormData();
          formdata.append("file", file);
          formdata.append("title", title)
          try {
               const res = await axios.put(`http://localhost:5080/product/${id}`, formdata, {
                    headers: {
                         "Content-Type": "multipart/form-data"
                    }
               })
               navigate("/")
               toast(res.data.msg, {
                    position: "top-right",
                    autoClose: 5000,
                    closeOnClick: true,
                    pauseOnHover: true,
                    theme: "light",
                    });
          } catch (error) {
                    console.log(error);
          }
     }

  return (
     <>
     <Navbar />
    <div className="container">
    <div className="columns  mt-5">
          <div className="column is-half">
               <form onSubmit={updateProduct}>
                    <div className="field">
                         <label className='label'>ویرایش اسم محصول</label>
                         <div className="control">
                              <input type="text" 
                              className='input'
                               name='title'
                               value={title}
                               onChange={e => setTitle(e.target.value)}
                               />
                         </div>
                    </div>
                    <div className="field">
                         <label className='label'>عکس</label>
                         <div className="control">
                              <input type="file"
                               className='input'
                               onChange={loadImage}
                               />
                              <span className='file-cta'>
                                   <span className='file-label'>ویرایش عکس</span>
                              </span>
                         </div>
                    </div>

                    {
                         preview ? (
                              <figure className='image is-128x128'>
                                   <img src={preview} alt="" />
                              </figure>
                         )
                         : 
                         (
                              ""
                         )
                    }

                    <div className="field">
                         <div className="control">
                              <button type='submit' className="button is-success">ذخیره</button>
                         </div>
                    </div>
               </form>
          </div>
     </div>
    </div>
   </>
  )
}

export default EditProduct