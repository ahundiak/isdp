#ifndef igrdir
/*
   ABSTRACT :
   --------

   This file contains usefull definitions for the directory stuff.

   HISTORY :
   -------
   06/22/1987 : HGB - Design Date
   09/09/1987 : HGB - Trailers Support
   12/11/1987 : HGB - Upgrade to 1.1


   DEPENDANCE :
   ----------

   This file depends on the following files : IGRdirdef.h
*/

#define igrdir

/* GLOBALS */

/* The directory delimiter character */
extern char DIR_G_car_dir;
extern char DIR_G_str_dir [2];

/* The current directory name and id */
extern char        DIR_G_cur_dir_name [DIR_MAX_LENGTH];
extern OM_S_OBJID  DIR_G_cur_dir_id;
extern OMuword     DIR_G_cur_dir_os;

/* The previous current directory name and id */
extern char        DIR_G_prev_cur_name [DIR_MAX_LENGTH];
extern OM_S_OBJID  DIR_G_prev_cur_id;

/* The home directory */
extern char DIR_G_home_name [DIR_MAX_LENGTH];

/* The master directory id */
extern OM_S_OBJID DIR_G_master_id;

/* The hash table id */
extern OM_S_OBJID DIR_G_hash_id;

/* The last accessed name and its objid */
extern OM_S_OBJID DIR_G_last_id, DIR_G_last_dir;
extern char       DIR_G_last_name [PATH_MAX_LENGTH];

/* The Current Reference File Name */
extern char DIR_G_prefix [PATH_MAX_LENGTH];

/* The trailers */
extern int  DIR_G_trailer_ids [TRAILER_MAX], DIR_G_trailer_index;
extern char *DIR_G_trailers [TRAILER_MAX];

/* To save the result of a di$start_ls */
extern char **DIR_G_ls_lines;
extern int  DIR_G_ls_count;

/* To save the result of a di$start_find */
extern char **DIR_G_find_lines;
extern int  DIR_G_find_count;
#endif
