module.exports = {
  ROLES:{ADMIN:'admin',MANAGEMENT:'management',FACULTY:'faculty',TEACHER:'teacher'},
  ATTENDANCE_STATUS:{PENDING:'pending',AVAILABLE:'available',NOT_AVAILABLE:'not_available',ARRIVED:'arrived',EVIDENCE_SUBMITTED:'evidence_submitted',VERIFIED:'verified',ABSENT:'absent'},
  NOTIFICATION_TYPES:{AVAILABILITY_CHECK:'availability_check',ARRIVAL_CONFIRMATION:'arrival_confirmation',ABSENCE_ALERT:'absence_alert',LATE_ALERT:'late_alert',VERIFICATION_COMPLETE:'verification_complete'},
  NOTIFICATION_STATUS:{PENDING:'pending',SENT:'sent',DELIVERED:'delivered',FAILED:'failed',READ:'read'},
  VERIFICATION_STATUS:{PENDING:'pending',VERIFIED:'verified',REJECTED:'rejected'},
  SOCKET_EVENTS:{ATTENDANCE_UPDATE:'attendance_update',NEW_ALERT:'new_alert',NOTIFICATION_RECEIVED:'notification_received'},
  ROOMS:{MANAGEMENT:'management',ADMIN:'admin',FACULTY:'faculty'}
};
