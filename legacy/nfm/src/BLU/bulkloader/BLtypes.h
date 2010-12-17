/* BLtypes.h
  
   Purpose:
        This module defines the data structures used by the bulkload program.

   History:
     Date   Programmer          Change
   ---------------------------------------------------------------------------
   06/10/91    WRW         Initial Release
   06/28/91    WRW         Added declarations for NFM copy operation
   08/06/91    WRW         Added 'synonym' to attr_type for catalog creation
   08/21/91    WRW         Added declarations for NFM add set operation
   08/23/91    WRW         Added declarations for NFM add to project operation
   09/20/91    WRW         Added more flags to the flag structure.
                             *flag.ris_load - to indicate a ris file to 
                                              pre-load.
                             *flag.no_mail  - to indicate that user wants to
                                              supress mail.
   12/03/91    wrw         Added more flags to the flag structure.
                             *flag.developer - to allow the printing of the 
                                               password in the debug file.
   01/31/92    wrw         Added more flags to the flag structure.
                             *flag.sts       - to print out the new .sts file
                             *flag.output    - to write files to given directory
                             *flag.nofork    - to not fork the process
                             *flag.nocheck   - to not check database before
                                               checkin. (Blind checkin)
   02/02/92    wrw         Re-worked the way records from .blk are stored.
	06/14/92    wrw         Added ftr operations and mode.
   09/02/94    wrw         Added set checkin and out stuff
*/

/* data structure for storing attributes and corresponding data */
struct attr_type {
   char *name;        /* attribute name */
   int   alloc_size;  /* size of space allocated for each data element */
   int   alloc_num;   /* number of data elements allocated */
   int   stored;      /* number of data elements now held */
   char **data;       /* user supplied data to go in attribute */
   };

/* data structure for storing all parameter that are supplied on operations */
struct params_type {
   char *catalog_name;   /* param for: catalog */
   int   catalog_type;   /* param for: catalog type (NFM_CAT, RIS_CAT) */
   char *item_name;      /* param for: add, checkin, checkout, delete */
   char *item_rev;       /* param for: add, checkin, checkout, delete */
   int   acl_no;         /* param for: add */
   char *set_catalog;    /* param for: set, create_set */
   char *set_name;       /* param for: set, create_set */
   char *set_rev;        /* param for: set, create_set */
   char *set_mode;       /* param for: set */
   int   set_acl_no;     /* param for: create_set */
   char *project_name;   /* param for: project */
   char *project_type;   /* param for: project */
	char *ftr_coll;       /* parameter for: ftr_index */
   char *ftr_file;       /* parameter for: ftr_index */
   char *filter_list;    /* parameter for: ftr_index */
   int   co_file_index;  /*    location of co_file attribute */
   int   ci_file_index;  /*    location of ci_file attribute */
   int   cosa_index;     /*    location of cosa attribute */
   int   cisa_index;     /*    location of cisa attribute */
   int   type_index;     /*    location of file type attribute */
   int   co_comm_index;  /*    location of co comment attribute */
   };

/* data structure for operation and status flags; 1-on 0-off */
struct flags_type {
   int dbg;              /* if running in debug mode */
   int timer;            /* if running in timed debug mode */
   int nfm_mode;         /* if running in NFM mode */
	int ftr_mode;         /* if running in ftr mode */
   int ris_load;         /* if there is a file to ris pre-load */
   int no_mail;          /* if user wants to suppress mail */
   int sts;              /* print our the .sts file */
   int output;           /* print output in given location */
   int nofork;           /* do not fork the process */
   int nocheck;          /* do not check database on checkin */
   int developer;        /* if the user wants to print the password in the dbg*/
   int ops_found;        /* if at least one operation needs performing */
   int catalog;          /* need to perform catalog */
   int add;              /* need to perform add */
   int delete;           /* need to perform delete */
   int checkin;          /* need to perform checkin */
   int checkout;         /* need to perform checkout */
   int copy;             /* need to perform copy */
   int create_set;       /* need to perform create set */
	int setin;            /* need to perform checkin set */
	int setout;           /* need to perform checkout set */
   int project;          /* need to perform add to project */
   int modify;           /* need to perform modify */
   int set;              /* need to perform set */
   int RISinsert;        /* need to perform RISinsert */
   int RISdelete;        /* need to perform RISdelete */
   int ftr_index;        /* need to perform ftr_index */
   };

/* data structure for counting operations found and performed */
struct count_type {
   int records_found;          /* total data records read in */
   int records_performed;      /* total data records that were ok */
   int adds_found;             /* total add operations found */
   int adds_performed;         /* total add operations successful */
   int modifys_found;          /* total modify operations found */
   int modifys_performed;      /* total modify operations successful */
   int deletes_performed;      /* total delete operations successful */
   int deletes_found;          /* total delete operations found */
   int checkins_found;         /* total checkin operations found */
   int checkins_performed;     /* total checkin operations successful */
   int checkouts_found;        /* total checkout operations found */
   int checkouts_performed;    /* total checkout operations successful */
   int setins_found;           /* total set checkin operations found */
   int setins_performed;       /* total set checkin operations successful */
   int setouts_found;          /* total set checkout operations found */
   int setouts_performed;      /* total set checkout operations successful */
   int copys_found;            /* total copy operations found */
   int copys_performed;        /* total copy operations successful */
   int sets_found;             /* total set operations found */
   int sets_performed;         /* total set operations successful */
   int c_sets_found;           /* total set operations found */
   int c_sets_performed;       /* total set operations successful */
   int projects_found;         /* total add to project operations found */
   int projects_performed;     /* total add to project operations successful */
   int RISinserts_found;       /* total RISinsert operations found */
   int RISinserts_performed;   /* total RISinsert operations successful */
   int RISdeletes_found;       /* total RISdelete operations found */
   int RISdeletes_performed;   /* total RISdelete operations successful */
   int ftr_indexs_found;       /* total ftr_index operations found */
   int ftr_indexs_performed;   /* total ftr_index operations successful */
   };


/* data structure for timing elements */
struct time_type {
   int   count;     /* count of the items timed so far */
   float times[5];  /* array of time values */
   float low_avg;   /* lowest average time reached */
   float curr_avg;  /* current average time */
   };
