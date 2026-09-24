const N=require('../models/Notification');
exports.getMyNotifications=async(req,res,next)=>{try{const n=await N.list(req.user.id,{unreadOnly:req.query.unreadOnly==='true',limit:req.query.limit});res.json({success:true,notifications:n,pagination:{page:1,limit:n.length,total:n.length,pages:1}})}catch(e){next(e)}};
exports.getUnreadCount=async(req,res,next)=>{try{res.json({success:true,count:await N.unreadCount(req.user.id)})}catch(e){next(e)}};
exports.markAsRead=async(req,res,next)=>{try{const n=await N.read(req.params.id,req.user.id);res.json({success:true,notification:n})}catch(e){next(e)}};
exports.markAllAsRead=async(req,res,next)=>{try{await N.readAll(req.user.id);res.json({success:true})}catch(e){next(e)}};
exports.getNotificationsByClass=async(req,res,next)=>{try{res.json({success:true,notifications:await N.byClass(req.params.classId)})}catch(e){next(e)}};
