#ifndef diglob
/*
   ABSTRACT :
   --------

   This file contains usefull definitions for the directory stuff.

   HISTORY :
   -------
   06/22/1987 : HGB - Design Date
   09/09/1987 : HGB - Trailers Support
   12/11/1987 : HGB - Upgrade to 1.1
   18/03/1988 : HGB - Move to OM
   05/14/1992 : EMS - Change PATH_MAX to DI_PATH_MAX

   DEPENDANCE :
   ----------

   This file depends on the following files : DIdef.h
*/

#define diglob

/* GLOBALS */

/* Directory sub-system initialized or not ?	*/
extern DIint  DIR_G_init;

/* The directory delimiter character */
extern DIchar DIR_G_car_dir;
extern DIchar DIR_G_str_dir [2];

/* The current directory name and id */
extern DIchar      DIR_G_cur_dir_name [DI_PATH_MAX];
extern DIobjid     DIR_G_cur_dir_id;
extern DIspacenum  DIR_G_cur_dir_os;
extern DIchar      *DIR_G_cur_mem;

/* The previous current directory name and id */
extern DIchar     DIR_G_prev_cur_name [DI_PATH_MAX];
extern DIobjid    DIR_G_prev_cur_id;
extern DIspacenum DIR_G_prev_cur_os;

/* The home directory */
extern DIchar DIR_G_home_name [DI_PATH_MAX];

/* The master directory id */
extern DIobjid    DIR_G_master_id;
extern DIspacenum DIR_G_master_os;

/* The root directory id */
extern DIobjid    DIR_G_root_id;
extern DIspacenum DIR_G_root_os;

/* The hash table id */
extern DIobjid DIR_G_untrees [];

/* To save the result of a di$start_ls */
extern DIchar **DIR_G_dump_lines;
extern DIgrid *DIR_G_dump_grids;
extern DIint  DIR_G_dump_count;

/* To save the result of a di$start_find */
extern DIchar **DIR_G_find_lines;
extern DIgrid *DIR_G_find_grids;
extern DIint  DIR_G_find_count;

/* To save the result of an untranslate */
extern DIchar **DIR_G_untr_dirnames;
extern DIchar **DIR_G_untr_objnames;
extern DIint  DIR_G_untr_count;

/* The trailers */
extern DIint  DIR_G_trailer_ids [TRAILER_MAX], DIR_G_trailer_index;
extern DIchar *DIR_G_trailers [TRAILER_MAX];

/* Primitives */
#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern DIint DIadd_name __((DIchar *full_name, DIchar *target_name, DIgrid target_grid, DIchar *base_name, DIobjid base_objid, DIchar *new_name, DIobjid *p_objid, DIspacenum *p_osnum));
extern DIint DImkdir __((DIchar *full_name, DIchar *target_name, DIgrid target_grid, DIchar *base_name, DIobjid base_objid, DIchar *class_name, DIobjid *p_dirid, DIspacenum *p_osnum));
extern DIint DIrename __((DIchar *full_name, DIchar *target_name, DIgrid target_grid, DIchar *base_name, DIobjid base_objid, DIchar *new_name, DIobjid *p_objid, DIspacenum *p_osnum));
extern DIint DIrmdir __((DIchar *full_name, DIchar *target_name, DIgrid target_grid, DIchar *base_name, DIobjid base_objid, DIchar *new_name, DIobjid *p_dirid, DIspacenum *p_osnum));
extern DIint DItranslate __((DIchar *full_name, DIchar *target_name, DIgrid target_grid, DIchar *base_name, DIobjid base_objid, DIchar *new_name, DIobjid *p_objid, DIspacenum *p_osnum));

#if defined(__cplusplus)
}
#endif

/* The classids */
extern DIclassid DIR_G_IGRdir_clid;
extern DIclassid DIR_G_DIrectory_clid;
extern DIclassid DIR_G_DIlink_clid;
extern DIclassid DIR_G_DImaster_clid;
extern DIclassid DIR_G_DIroot_clid;

/* The cd path (search path for cd */
extern DIchar DIR_G_cdpath [DI_PATH_MAX];

#endif
