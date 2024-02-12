import path from "path";
import fs from "fs";
import Restaurant from "../models/restaurantModel.js";

export const getRestaurants = async(req, res) => {
     try {
          const response = await Restaurant.findAll();
          res.json(response)
     } catch (error) {
          console.log(error.message)
     }
}

export const getRestaurant = async(req,res)=> {
     try {
          const response = await Restaurant.findOne({
               where: {
                    id: req.params.id
               }
          });
          res.json(response)
     } catch (error) {
          res.json(error)
     }
}

export const getRestaurantByCategory = async(req,res)=> {
     try {
          const response = await Restaurant.findAll({
               where: {
                    category_id: req.params.id
               }
          });
          res.json(response)
     } catch (error) {
          res.json(error)
     }
}



export const saveRestaurant = (req, res) => {
     if(req.files == null) return res.json({msg: "عکسی انتخاب نکردید"})
     const name = req.body.title;
     const file = req.files.file;
     const { 
          latitude, longitude,deliver, 
          takeaway, serving, phone,
          facebook, instagram, whatsapp,
          email, web, city, district,
          street, avenue, postal_code,
          opening_time, closing_time,
          working_days,category_id } = req.body;
     const fileSize = file.data.length;
     const ext = path.extname(file.name)
     let dateNow = Math.round(Date.now());
     const fileName = dateNow + ext;
     const url = `${req.protocol}://${req.get("host")}/images/${fileName}`
     const allowedType = ['.png','.jpg','.jpeg'];

     if(!allowedType.includes(ext.toLowerCase())){
          return res.json({msg: "png jpg jpeg عکس معتبر نیست * فرمت های مجاز "});
     }
     if(fileSize > 5000000) return res.json({msg: "حجم عکس نباید بیشتر از 5 مگابایت باشد."})

     file.mv(`./public/images/${fileName}`, async(err)=> {
          if(err) return res.json({msg: err.message})

          try {
               await Restaurant.create({
                    name: name, category_id:category_id,image: fileName, url:url, 
                    latitude: latitude, longitude: longitude, 
                    takeaway:takeaway, deliver:deliver,
                    serving:serving, phone:phone,
                    facebook:facebook, instagram:instagram,
                    whatsapp:whatsapp, email:email, 
                    web:web, city:city, district:district, 
                    street:street, avenue:avenue, 
                    postal_code:postal_code, opening_time:opening_time,
                    closing_time:closing_time, working_days:working_days});
               res.json({msg: "رستوران با موفقیت افزوده شد."})
          } catch (error) {
               console.log(error.message)
          }
     })

}


export const updateRestaurant = async(req, res)=> {
     const restaurant = await Restaurant.findOne({
          where: {
               id: req.params.id
          }
     })
     if(!restaurant) return res.json("رستورانی پیدا نشد");

     let fileName = "";
     if(req.files === null){
          fileName = restaurant.image;
     }else{
          const file = req.files.file;
          const fileSize = file.data.length;
          const ext = path.extname(file.name)
          let dateNow = Math.round(Date.now());
          fileName = dateNow + ext; 
          const allowedType = ['.png','.jpg','.jpeg'];
          if(!allowedType.includes(ext.toLowerCase())){
               return res.json({msg: "png jpg jpeg عکس معتبر نیست * فرمت های مجاز "});
          }
          if(fileSize > 5000000) return res.json({msg: "حجم عکس نباید بیشتر از 5 مگابایت باشد."})

          const filePath = `./public/images/${restaurant.image}`
          fs.unlinkSync(filePath)

          file.mv(`./public/images/${fileName}`, async(err)=> {
               if(err) return res.json({msg: err.message})
          })
     }

     const name = req.body.title;
     const url = `${req.protocol}://${req.get("host")}/images/${fileName}`
     const { latitude, longitude } = req.body;

     try {
          await Restaurant.update({name: name, image: fileName, url:url, latitude: latitude, longitude: longitude}, {
               where: {
                    id: req.params.id,
               }
          });
          res.json({msg: "رستوران با موفقیت ویرایش شد"})
     } catch (error) {
          res.json(error)
     }
}





export const deleteRestaurant = async(req,res)=> {
     const restaurant = await Restaurant.findOne({
          where: {
               id: req.params.id
          }
     })

     if(!restaurant) return res.json({msg: "رستورانی پیدا نشد"});

     try {
          const filePath = `./public/images/${restaurant.image}`
          fs.unlinkSync(filePath)
          await Restaurant.destroy({
               where: {
                    id : req.params.id
               }
          })

          res.json({msg: "رستوران با موفقیت حذف شد."})

     } catch (error) {
          res.json(error)
     }

}