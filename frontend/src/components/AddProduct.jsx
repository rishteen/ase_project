import React, { useState, useEffect, useRef } from 'react';
import Navbar from './NavBar'; // Adjust import paths as necessary
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

const LocationPicker = ({ onLocationSelect }) => {
  useMapEvents({
    click(e) {
      onLocationSelect(e.latlng);
    },
  });

  return null;
};

const AddProduct = () => {
  const [title, setTitle] = useState("");
  const [file, setFile] = useState("");
  const [preview, setPreview] = useState("");
  const [latitude, setLatitude] = useState(45.4); // Default latitude
  const [longitude, setLongitude] = useState(-75.7); // Default longitude
  const [markerPosition, setMarkerPosition] = useState(null);
  const [mapLoaded, setMapLoaded] = useState(false);
  const navigate = useNavigate();
  const searchInputRef = useRef(null);

  useEffect(() => {
    navigator.geolocation.getCurrentPosition(function(position) {
      setLatitude(position.coords.latitude);
      setLongitude(position.coords.longitude);
      setMarkerPosition([position.coords.latitude, position.coords.longitude]);
      setMapLoaded(true);
    }, function() {
      setMapLoaded(true); // Load map with default location if access is denied
    });
  }, []);

  useEffect(() => {
    const searchBox = new window.google.maps.places.SearchBox(searchInputRef.current);
    searchBox.addListener('places_changed', () => {
      const selectedPlace = searchBox.getPlaces()[0];
      if (selectedPlace) {
        const lat = selectedPlace.geometry.location.lat();
        const lng = selectedPlace.geometry.location.lng();
        setLatitude(lat);
        setLongitude(lng);
        setMarkerPosition([lat, lng]);
      }
    });
  }, []);

  const loadImage = (e) => {
    const image = e.target.files[0];
    setFile(image);
    setPreview(URL.createObjectURL(image));
  };

  const handleLocationSelect = (latlng) => {
    setLatitude(latlng.lat);
    setLongitude(latlng.lng);
    setMarkerPosition(latlng);
  };

  const saveProduct = async (e) => {
    e.preventDefault();
    const formData = new FormData();
    formData.append("file", file);
    formData.append("title", title);
    formData.append("latitude", latitude);
    formData.append("longitude", longitude);

    try {
      const res = await axios.post("http://localhost:5080/products", formData, {
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
      toast.error("An error occurred while saving the product.", {
        position: "top-right",
        autoClose: 5000,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
      });
    }
  };

  return (
    <>
      <Navbar />
      <div className="container">
        <div className="columns mt-5">
          <div className="column is-half">
            <form onSubmit={saveProduct}>
              <div className="field">
                <label className="label">اسم محصول</label>
                <div className="control">
                  <input
                    type="text"
                    className="input"
                    name="title"
                    onChange={(e) => setTitle(e.target.value)}
                  />
                </div>
              </div>
              <div className="field">
                <label className="label">عکس</label>
                <div className="control">
                  <input
                    type="file"
                    className="input"
                    onChange={loadImage}
                  />
                </div>
                {preview && (
                  <figure className="image is-128x128">
                    <img src={preview} alt="Preview" />
                  </figure>
                )}
              </div>

              {mapLoaded && (
                <div className="field">
                  <label className="label">Select Location on Map</label>
                  <MapContainer center={markerPosition || [35.70392058, 51.40836328]} zoom={13} style={{ height: 400, width: "100%" }}>
                    <TileLayer
                      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    />
                    {markerPosition && <Marker position={markerPosition}></Marker>}
                    <LocationPicker onLocationSelect={handleLocationSelect} />
                  </MapContainer>
                </div>
              )}
              <div className="field">
                <div className="control">
                  <button type="submit" className="button is-success">
                    ذخیره
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </>
  );
};

export default AddProduct;
