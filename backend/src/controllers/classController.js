const ClassModel=require('../models/Class'),Attendance=require('../models/Attendance');
exports.getClasses=async(req,res,next)=>{try{const classes=await ClassModel.list({teacherId:req.query.teacherId||undefined,from:req.query.from,to:req.query.to});res.json({success:true,classes})}catch(e){next(e)}};
exports.getTodayClasses=async(req,res,next)=>{try{const now=new Date(),start=new Date(now);start.setHours(0,0,0,0);const end=new Date(start);end.setDate(end.getDate()+1);res.json({success:true,classes:await ClassModel.list({teacherId:req.user.role==='teacher'?req.user.id:undefined,from:start,to:end})})}catch(e){next(e)}};
exports.getClassById=async(req,res,next)=>{try{const c=await ClassModel.findById(req.params.id);if(!c)return res.status(404).json({success:false,message:'Class not found'});res.json({success:true,class:c})}catch(e){next(e)}};
exports.createClass=async(req,res,next)=>{try{const c=await ClassModel.create(req.body);await Attendance.ensure(c.id,c.teacher_id);res.status(201).json({success:true,class:c})}catch(e){next(e)}};
exports.updateClass=async(req,res,next)=>{try{res.json({success:true,class:await ClassModel.update(req.params.id,req.body)})}catch(e){next(e)}};
exports.deleteClass=async(req,res,next)=>{try{await ClassModel.delete(req.params.id);res.json({success:true,message:'Class deleted'})}catch(e){next(e)}};
