const bcrypt=require('bcryptjs'),User=require('../models/User');const safe=u=>{if(!u)return null;const{password_hash,...x}=u;return x};
exports.getUsers=async(req,res,next)=>{try{res.json({success:true,users:await User.list(req.query)})}catch(e){next(e)}};
exports.getTeachers=async(req,res,next)=>{try{res.json({success:true,users:await User.list({role:'teacher'})})}catch(e){next(e)}};
exports.getUserById=async(req,res,next)=>{try{const u=await User.findById(req.params.id);if(!u)return res.status(404).json({success:false,message:'User not found'});res.json({success:true,user:safe(u)})}catch(e){next(e)}};
exports.updateUser=async(req,res,next)=>{try{const data={...req.body};if(data.password){data.password_hash=await bcrypt.hash(data.password,12);delete data.password;}const u=await User.update(req.params.id,data);res.json({success:true,user:safe(u)})}catch(e){next(e)}};
exports.deleteUser=async(req,res,next)=>{try{await User.delete(req.params.id);res.json({success:true,message:'User deleted'})}catch(e){next(e)}};
