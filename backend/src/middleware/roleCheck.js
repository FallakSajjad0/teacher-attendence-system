const roles=(...allowed)=>(req,res,next)=>allowed.includes(req.user?.role)?next():res.status(403).json({success:false,message:'Insufficient permissions'});
module.exports={
 isAdmin:roles('admin'), isManagement:roles('admin','management','faculty'),
 isTeacher:roles('teacher'), isFaculty:roles('faculty','admin'),
};
