const {body,param}=require('express-validator');
const validate=require('express-validator').validationResult;
const run=(req,res,next)=>{const e=validate(req);if(!e.isEmpty())return res.status(400).json({success:false,message:'Validation failed',errors:e.array()});next();};
const loginValidation=[body('email').isEmail(),body('password').isLength({min:6}),run];
const registerValidation=[body('name').trim().notEmpty(),body('email').isEmail(),body('password').isLength({min:6}),run];
const classValidation=[body('subject').trim().notEmpty(),body('teacherId').isUUID(),body('startTime').isISO8601(),run];
const locationValidation=[body('latitude').isFloat(),body('longitude').isFloat(),run];
const mongoIdValidation=[param('id').isUUID().withMessage('id must be a UUID'),run];
module.exports={loginValidation,registerValidation,classValidation,locationValidation,mongoIdValidation};
