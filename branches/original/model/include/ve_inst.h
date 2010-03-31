
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef ve_inst_include
#define ve_inst_include 1

/*
DESCRIPTION
	Structure definitions used in VE instance data

HISTORY
	S.P. Rogers  02/11/90  Creation Date
*/

/* batch job information */
struct VEjob_info
	{
	IGRchar   results_fname[RESULTS_FNAME_SIZE];  /* results file name */
	IGRchar   server_name[SERVER_SIZE];           /* server name */
	IGRchar   user_name[USER_NAME_SIZE];          /* user name */
	IGRchar   password[PASSWORD_SIZE];            /* password */
	IGRchar   unique_name[UNIQUE_NAME_SIZE];      /* unique name */
	IGRdouble view_origin[3];                     /* view origin used to attach results */
	};

struct VEbatch_info
	{
	IGRint num_jobs;               /* number of batch jobs submitted               */
	struct VEjob_info *job_info;   /* array of size 'num_jobs' containing job info */
	};

#endif
