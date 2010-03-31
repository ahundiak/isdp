class specification VEretrieve (1:0) of VEedgescmds;



/* structure containing all information about a job */
struct VEretrieve_struct
   {
   struct VEjob_info job_info;        /* job submittal information                         */
   struct GRid       window;          /* GRid of window to which job belongs               */ 
   IGRint            win_sequence_no; /* job number w.r.t. other jobs from the same window */
   };


instance VEretrieve
{
	variable struct VEretrieve_struct jobs[0];   /* array of outstanding jobs    */
	IGRint                            job_index; /* index of job to be retrieved */
	IGRint                            num_jobs;  /* number of outstanding jobs   */
	};


message load_form_data ( long * sts );

message check_for_background_jobs ( long * sts );

override form_notification;

message get_the_files ( long * sts );

message attach_results ( long * sts );

end specification VEretrieve;
