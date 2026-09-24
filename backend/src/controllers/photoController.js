const Photo=require('../models/Photo');
exports.getPendingPhotos=async(req,res,next)=>{try{res.json({success:true,photos:await Photo.pending()})}catch(e){next(e)}};
exports.getPhotosByClass=async(req,res,next)=>{try{res.json({success:true,photos:await Photo.byClass(req.params.classId)})}catch(e){next(e)}};
exports.getPhotoById=async(req,res,next)=>{try{const p=await Photo.byId(req.params.id);if(!p)return res.status(404).json({success:false,message:'Photo not found'});res.json({success:true,photo:p})}catch(e){next(e)}};
