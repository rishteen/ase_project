import { Sequelize } from "sequelize";

const db=new Sequelize("uploader", "root", "!@#ABCcba#@2023",{
    host:"localhost",
    dialect:"mysql"
});

export default db;

/*  (
     async() =>{
     await db.sync();
   }
 )(); */