# Alertwatcher :
               File parser for specific pattern which identifies newer appearance of pattern inside file.
               Initial this was created for alert.log monitor for Oracle database

# Configuration file format :
              full path to file location, How many lines after match to send(n), How many lines before match send(n), match position, mail subject, recipients list

# example :
         /rootfolser/subfolder/.../some_file_to_monitor:20:10:0:any word in here as subject for e-mail:recipient1@somemail.com,recipient2@somemail.com,recipient3@somemail.com

# DO NOT USE ":" INSIDE OF PARAMETERS.  ":" IS SEPARATOR


#  Real examples :

/opt/apps/dbInfra/diag/rdbms/example/EXAMPLEDB/trace/alert_EXAMPLEDB.log:1:1:14332:ALERT IN:
/opt/apps/dbInfra/diag/rdbms/example/EXAMPLEDB/trace/alert_EXAMPLEDB.log:1:30:14332:ALERT dIN:recipient1@somemail.com,recipient2@somemail.com,recipient3@somemail.com

