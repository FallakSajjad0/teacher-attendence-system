const {pool}=require('../config/database');
module.exports={
 async create(x){return (await pool.query(`INSERT INTO photos(user_id,class_id,attendance_id,url,filename,mime_type,size_bytes,captured_at,latitude,longitude,verification_status,notes) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) RETURNING *`,[x.userId,x.classId,x.attendanceId,x.url,x.filename,x.mimeType||'image/jpeg',x.size||0,x.capturedAt||new Date(),x.latitude||null,x.longitude||null,x.verificationStatus||'pending',x.notes||null])).rows[0];},
 async byId(id){return (await pool.query(`SELECT p.*,u.name teacher_name,c.subject FROM photos p JOIN users u ON u.id=p.user_id JOIN classes c ON c.id=p.class_id WHERE p.id=$1`,[id])).rows[0]||null;},
 async byClass(classId){return (await pool.query('SELECT * FROM photos WHERE class_id=$1 ORDER BY created_at DESC',[classId])).rows;},
 async pending(){return (await pool.query(`SELECT p.*,u.name teacher_name,c.subject FROM photos p JOIN users u ON u.id=p.user_id JOIN classes c ON c.id=p.class_id WHERE p.verification_status='pending' ORDER BY p.created_at`)).rows;}
};
