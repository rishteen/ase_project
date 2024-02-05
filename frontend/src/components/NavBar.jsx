import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';

const Navbar = () => {
    const [searchTerm, setSearchTerm] = useState('');

    const handleSearch = (event) => {
        event.preventDefault();
        // Implement your search logic here
        console.log(searchTerm); // Example search logic
    };

    return (
        <div className="container mt-2">
            <nav className="navbar" role="navigation" aria-label="main navigation">
                <div className="navbar-brand">
                    <NavLink to="/" className="navbar-item">
                        WQ
                    </NavLink>
                </div>

                <div id="navbarBasicExample" className="navbar-menu">
                    <div className="navbar-end">
                        <NavLink to="/" className="navbar-item" activeClassName="is-active">
                            خانه
                        </NavLink>

                        <NavLink to="/add" className="navbar-item" activeClassName="is-active">
                            افزودن محصول
                        </NavLink>
                    </div>
                </div>

                {/* Search box section below the menu */}
                <div className="navbar-item">
                    <form onSubmit={handleSearch}>
                        <div className="field has-addons">
                            <div className="control is-expanded">
                                <input
                                    className="input"
                                    type="text"
                                    placeholder="جستجو..."
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                />
                            </div>
                            <div className="control">
                                <button type="submit" className="button is-info">
                                    جستجو
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </nav>
        </div>
    );
};

export default Navbar;
