
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

/*	CLASS NAME:	HSNCtoolpth
	SUBCLASS OF:	Root
	ABSTRACT:	Defines the NC toolpath display-list object for
			  shaded hidden surface display.
	CHANNELS DECLARED:	tpmgr - channel to the object of class
				  HSNCtoolpmgr, the "super" object that
				  manages all objects of this class.
	MESSAGES DECLARED:	add_disp_list - adds another display
				  list "command" to the end of the
				  current display list, and increases the
				  number of commands and the quad word
				  count accordingly.
				change_disp_list - changes the number of
				  display list "commands", the entire
				  display list itself, and the quad word
				  count.
				read_disp_list - returns the number of
				  display list "commands", the entire
				  display list itself, and the quad word
				  count.
	CHANGE HISTORY:    DH    07/05/88    :  Design date
			   KMJ	 07/25/88    :  Took num_commands out
						added read_num_quadwords
-------------------------------------------------------------------------
		C L A S S   D E S C R I P T I O N
-------------------------------------------------------------------------
*/
class specification HSNCtoolpth (1:0) of Root;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "hsncdef.h"
#include "growner.h"
#include "gr.h"

instance HSNCtoolpth
{
   variable	IGRdouble	disp_list[HSNC_DISP_LIST_SIZE];
   IGRint		num_quadwords;
   channel {(many_to_one)} tpmgr;
   IGRint                      num_bg_objenvs;
   struct GRobj_env            background_objenv;
   variable struct GRobj_env   background_objenvs[1];
   IGRint                      num_part_objenvs;
   struct GRobj_env            part_objenv;
   variable struct GRobj_env   part_objenvs[1];
   struct GRid                 gragad;
};

/* MESSAGES */
override debug;

message my_construct ();

message add_to_disp_list (IGRdouble *command; IGRint *num_quadwds);

message change_disp_list (IGRdouble *disp_list; IGRint *num_quadwds);

message read_disp_list (IGRdouble *disp_list);

message read_num_quadwords (IGRint *num_quadwds);

message set_object_env ( int num_bg_objenvs; 
                       struct GRobj_env *bg_obj_envs;
                       int num_part_objenvs;
                       struct GRobj_env *part_obj_envs;
                       struct GRid      *gragad);

message get_object_env ( int *num_bg_objenvs; 
                       struct GRobj_env **bg_obj_envs;
                       int *num_part_objenvs;
                       struct GRobj_env **part_obj_envs;
                       struct GRid      *gragad);

end specification HSNCtoolpth;
