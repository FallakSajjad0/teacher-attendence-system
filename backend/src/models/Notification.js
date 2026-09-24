const {pool}=require('../config/database');
module.exports={
 async create(x){return (await pool.query(`INSERT INTO notifications(user_id,class_id,type,title,body,status,scheduled_at,sent_at,data) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,[x.userId,x.classId||null,x.type,x.title,x.body,x.status||'sent',x.scheduledAt||new Date(),x.sentAt||new Date(),x.data||{}])).rows[0];},
 async list(userId,{unreadOnly=false,limit=50}={}){const q=`SELECT n.*,c.subject,c.start_time FROM notifications n LEFT JOIN classes c ON c.id=n.class_id WHERE n.user_id=$1 ${unreadOnly?"AND n.status <> 'read'":''} ORDER BY n.created_at DESC LIMIT $2`;return (await pool.query(q,[userId,Math.min(Number(limit)||50,100)])).rows;},
 async unreadCount(userId){return Number((await pool.query(`SELECT COUNT(*) count FROM notifications WHERE user_id=$1 AND status <> 'read'`,[userId])).rows[0].count);},
 async read(id,userId){return (await pool.query(`UPDATE notifications SET status='read',read_at=NOW() WHERE id=$1 AND user_id=$2 RETURNING *`,[id,userId])).rows[0]||null;},
 async readAll(userId){await pool.query(`UPDATE notifications SET status='read',read_at=NOW() WHERE user_id=$1 AND status <> 'read'`,[userId]);},
 async byClass(classId){return (await pool.query('SELECT * FROM notifications WHERE class_id=$1 ORDER BY created_at DESC',[classId])).rows;}
};
