import { Sequelize } from "sequelize";
import { config as dotenvConfig } from 'dotenv';

dotenvConfig();


const db = new Sequelize(process.env.DB_CONNECTION);

export default db;

/*  (
     async() =>{
     await db.sync();
   }
 )();  */