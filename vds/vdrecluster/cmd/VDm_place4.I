/* $Id: VDm_place4.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/******************************************************************************
 * I/VDS
 *
 * File:        vds240/vdrecluster/cmd/VDm_place4.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDm_place4.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/12/06  16:00:10  pinnacle
# Created: vdrecluster/cmd/VDm_place4.I by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY      AUTHOR    DESCRIPTION
 *
 *	12/05/95	HF	Override of I/EMS Review Macro Library functionality
 *				in order to reduce the memory problems such as
 *				running out of swap space when many large libraries
 *				are attached.
 *
 ******************************************************************************/

class implementation COm_place;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include <limits.h>
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "FI.h"
#include "grclasses.h"
#include "grmsg.h"

#define AS_DEBUG

from IGRdir 	  import translate;
from ACmacro_defn import ACgive_upscan;

extern	IGRboolean	VD_K_libTemplates ;

/* Display in the form the macros contained in osnum */

COm_list_macro(macro_lib,macro_def,fp)
struct GRid  *macro_lib,*macro_def;
char *fp;
{
  int i_lines,nb_lines;
  int status,msg;
  char dir_name[DI_PATH_MAX];
  char **lines = NULL;
  int select,num_row,row;
  char *macro_name,*strrchr();
#define ARGUMENT_LEN 200
  char argument[ARGUMENT_LEN];
  struct GRid macro;
  struct sup *dup;
  int Nb_Max_Temp,i_temp,dummy;
  int len,len_arg;
  GRclassid obj_class;
  extern GRclassid OPP_ACcpx_defn_class_id;
  char *macro_lib_name,*strrchr();

/*| Get contents of selected macro library */

  status = di$give_pathname ( osnum =  macro_lib->osnum,
                              pathname =  dir_name);

  macro_lib_name = strrchr(dir_name,':');
  if (macro_lib_name)
   {
    FIg_erase(fp,MACRO_IN_LIB_TITLE);
    status = FIg_set_text(fp,MACRO_IN_LIB_TITLE,macro_lib_name+1);
    FIg_display(fp,MACRO_IN_LIB_TITLE);
   }


  strcat(dir_name,":constructs:*");

  /*"path_name %s\n",dir_name */

  status = di$ls( regexp = dir_name ,
		  options = NULL,
                  lines = &lines ,
                  ptr = &nb_lines);

  if(!(status&1)) return(OM_S_SUCCESS);

/*"Initialize field : %d lines and selected lines\n",nb_lines */

  FIfld_set_num_rows(fp,MACRO_IN_LIB,0);

  if(nb_lines == 0) return(OM_S_SUCCESS);

/*| Display the macros */

  FIfld_get_num_vis_rows(fp,MACRO_IN_LIB,&num_row);

  row = 0;
  for(i_lines=0;i_lines<nb_lines;i_lines=i_lines+1)
    {
     /*" %d\n",i_lines */
     /*| Get information about macro */

     macro_name = strrchr(lines[i_lines],':');
     if(macro_name != NULL) macro_name = macro_name + 1;
     else		    macro_name = lines[i_lines];
     /*^if(macro_name != NULL)  printf("%s\n",macro_name);*/

     status = om$send ( msg = message IGRdir.translate( &msg, macro_name,
                                                0,NULL,&macro.objid),
                     senderid = NULL_OBJID,
                     targetid = macro_lib->objid,
                     targetos = macro_lib->osnum );
     if(!(status&msg&1)) continue;
     macro.osnum = macro_lib->osnum;

     om$get_classid(objid = macro.objid,
		    osnum = macro.osnum,
		    p_classid = &obj_class);
     if(om$is_ancestry_valid(superclassid = OPP_ACcpx_defn_class_id,
			     subclassid = obj_class) != OM_S_SUCCESS) continue;

     /*"%s --> %d\n",macro_name,macro.objid */

     /*
      * Modification for I/VDS (less memory usage) :
      * Only activated when toggle on form is set to "Display Templates"
      */
     if ( VD_K_libTemplates )
     {
       status = om$send(msg = message ACmacro_defn.ACgive_upscan
                             		       (&Nb_Max_Temp,&dummy,&dup),
                      senderid = NULL_OBJID,
                      targetid = macro.objid,
                      targetos = macro.osnum );
       if(!(status&1)) continue;
     }


     /*| Display Name */

     if(macro_def->objid != macro.objid) select = FALSE;
     else				 select = TRUE;
     FIfld_set_text(fp,MACRO_IN_LIB,row,0,macro_name,select);

     /*
      * Modification for I/VDS (less memory usage) :
      * Only activated when toggle on form is set to "Display Templates"
      */
     if ( VD_K_libTemplates )
     {
      /*| Display Argument descriptions */

      argument[0] = '(';
      len = 1;

      for(i_temp=0 ; i_temp<Nb_Max_Temp ; i_temp++)
      {
       len_arg = strlen(dup[i_temp].prompt);
       if(len_arg > ARGUMENT_LEN -len -3) len_arg = ARGUMENT_LEN -len -3;
       OM_BLOCK_MOVE(dup[i_temp].prompt,argument+len,len_arg);
       len += len_arg;
       /*"argument %d --> len %d\n",i_temp,len*/
       if(len >= ARGUMENT_LEN -3) break;
       if(i_temp<Nb_Max_Temp-1) { argument[len++]=','; }
      }
      argument[len] = ')';
      argument[len+1] = '\0';
      /*"argument %s\n",argument */
      FIfld_set_text(fp,MACRO_IN_LIB,row,1,argument,select);
     }

     /*^ if(select) printf("found in %d\n",i_lines); */

     if(select) FIfld_set_active_row
	     (fp,MACRO_IN_LIB,row, row<num_row-1 ? row : num_row-1);

     row += 1;

    }

  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    if(!(status&1))di$report_error(sts = status);
   }
 return 1;
}

end implementation COm_place;
