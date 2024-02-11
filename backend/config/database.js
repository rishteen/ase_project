import { Sequelize } from "sequelize";

const db = new Sequelize('mysql://root:9IbGbVxzkSdBLl5zyR43C0Q3@siah-kaman.liara.cloud:34846/uploader');

export default db;

/*  (
     async() =>{
     await db.sync();
   }
 )(); */