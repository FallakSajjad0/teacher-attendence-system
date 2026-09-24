const {pool}=require('../config/database');
const Attendance={
 async byId(id){return (await pool.query(`SELECT a.*,c.subject,c.room,c.start_time,c.end_time,c.classroom_latitude,c.classroom_longitude,c.radius_meters,u.name teacher_name,u.email teacher_email FROM attendance a JOIN classes c ON c.id=a.class_id JOIN users u ON u.id=a.user_id WHERE a.id=$1`,[id])).rows[0]||null;},
 async byTeacher(userId){return (await pool.query(`SELECT a.*,c.subject,c.room,c.start_time,c.end_time FROM attendance a JOIN classes c ON c.id=a.class_id WHERE a.user_id=$1 ORDER BY c.start_time DESC`,[userId])).rows;},
 async byClass(classId){return (await pool.query(`SELECT a.*,u.name teacher_name,u.email teacher_email,c.subject,c.start_time FROM attendance a JOIN users u ON u.id=a.user_id JOIN classes c ON c.id=a.class_id WHERE a.class_id=$1 ORDER BY a.created_at DESC`,[classId])).rows;},
 async ensure(classId,userId){let r=await pool.query('SELECT * FROM attendance WHERE class_id=$1 AND user_id=$2',[classId,userId]);if(r.rows[0])return r.rows[0];r=await pool.query('INSERT INTO attendance(class_id,user_id,status) VALUES($1,$2,$3) RETURNING *',[classId,userId,'pending']);return r.rows[0];},
 async update(id,fields){const entries=Object.entries(fields).filter(([,v])=>v!==undefined);const vals=entries.map(([,v])=>v);const sets=entries.map(([k],i)=>`${k}=$${i+1}`).join(',');vals.push(id);return (await pool.query(`UPDATE attendance SET ${sets},updated_at=NOW() WHERE id=$${vals.length} RETURNING *`,vals)).rows[0]||null;},
 async pending(){return (await pool.query(`SELECT a.*,c.subject,c.room,c.start_time,u.name teacher_name,u.email teacher_email,p.url photo_url FROM attendance a JOIN classes c ON c.id=a.class_id JOIN users u ON u.id=a.user_id LEFT JOIN photos p ON p.id=a.photo_id WHERE a.status IN ('evidence_submitted','arrived') ORDER BY c.start_time`)).rows;}
};
module.exports=Attendance;
