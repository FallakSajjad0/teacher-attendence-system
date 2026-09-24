const {pool}=require('../config/database');
const User={
 async findById(id){const r=await pool.query('SELECT * FROM users WHERE id=$1',[id]);return r.rows[0]||null;},
 async findByEmail(email){const r=await pool.query('SELECT * FROM users WHERE lower(email)=lower($1)',[email]);return r.rows[0]||null;},
 async create(data){const r=await pool.query(`INSERT INTO users(name,email,password_hash,role,phone,fcm_token,is_active) VALUES($1,$2,$3,$4,$5,$6,$7) RETURNING *`,[data.name,data.email,data.password_hash,data.role||'teacher',data.phone||null,data.fcm_token||null,data.is_active!==false]);return r.rows[0];},
 async list({role,search}={}){const vals=[];let q='SELECT id,name,email,role,phone,fcm_token,is_active,created_at,updated_at FROM users WHERE 1=1';if(role){vals.push(role);q+=` AND role=$${vals.length}`;}if(search){vals.push(`%${search}%`);q+=` AND (name ILIKE $${vals.length} OR email ILIKE $${vals.length})`;}q+=' ORDER BY name';const r=await pool.query(q,vals);return r.rows;},
 async update(id,data){const keys=Object.keys(data);if(!keys.length)return this.findById(id);const vals=keys.map(k=>data[k]);const sets=keys.map((k,i)=>`${k}=$${i+1}`).join(',');vals.push(id);const r=await pool.query(`UPDATE users SET ${sets},updated_at=NOW() WHERE id=$${vals.length} RETURNING *`,vals);return r.rows[0]||null;},
 async delete(id){await pool.query('DELETE FROM users WHERE id=$1',[id]);}
};
module.exports=User;
