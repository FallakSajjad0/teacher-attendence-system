require('dotenv').config();
const http=require('http'),app=require('./src/app'),{connectDatabase}=require('./src/config/database'),{initializeSocket}=require('./src/sockets/socketHandler'),{startScheduler}=require('./src/services/schedulerService');
const PORT=process.env.PORT||5000;
(async()=>{try{if(!process.env.DATABASE_URL)throw new Error('DATABASE_URL is missing in backend/.env');if(!process.env.JWT_SECRET)throw new Error('JWT_SECRET is missing in backend/.env');await connectDatabase();const server=http.createServer(app);initializeSocket(server);startScheduler();server.listen(PORT,()=>console.log(`Teacher Attendance API running at http://localhost:${PORT}`));}catch(e){console.error('Failed to start:',e.message);process.exit(1)}})();
