/* $Id: ACtmp_defni.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int310 / ACtmp_defni.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACtmp_defni.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *	Initial import to CVS
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 * I/VDS
 *
 * Correction adapted to handle checkin/checkout for invisible modules, which
 * are working during their sleep process with the visible module.
 *
 * adz: 06/03/94 : integrated as dloadable for in I/VDS.
 */

/*
  ACcpx_defni.I
  robert patience
  21_jul_86
*/
class implementation ACtmp_defn;

#include <stdio.h>
#include <string.h>
#include "ctype.h"
#include "ASmacroi.h"
#include "macro.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"
#include "acdef.h"
#include "acmacros.h"

#define AS_DEBUG

from IGRdir import translate;
from OMObjSpace import pass;

extern GRclassid OPP_ACtmp_defn_class_id;

struct ACsymbol_struct
       { struct GRid symb_def ,  /* symbolic definition                       */
                     real_def ;  /* real definition                           */
	 int    used;            /* number of time the symb definition is used*/
       } ;


#ifdef ORIGINAL

  %safe
  IGRint ACnb_symb = 0,         /* number of elements in list */
       ACsize_symb = 0;       /* size of list */

  struct ACsymbol_struct *ACsymbol_def = NULL;
  %endsafe

#endif

extern	IGRint	ACnb_symb, ACsize_symb;
extern	struct	ACsymbol_struct *ACsymbol_def;

/*
 * library globals.
 */
struct ACopen_struct
   {
    int osnum;                     /* open osnum                            */
    int name;                      /* index of name in name_array           */
   };

extern struct ACopen_struct
           *ACopen_info;    /* allocated place for info             */

extern struct GRid *ACpath_grid;   /* list of grid for path directory       */
extern int  *ACpath_in_open;       /* corresponding index in open list      */
extern int   ACpath_gr_number;     /* number of directory in the path       */
extern int   ACpath_gr_total;      /* allocated size of ACpath_grid         */
extern char *ACopen_name_array;    /* allocated space for name              */


/*
#define	DEBUG	1
 */

method ACreturn_real_def(struct GRid *real_def;char *h_table)
{
 struct GRid		my_grid,
			dir;
 IGRchar		*macro_name,
			*file_name,
			*act_name,
			*new_file_name;
 char			*separ,*strchr();
 IGRlong		rc, status;
 IGRchar		full_dir_name[256];
 IGRint			msg;
 IGRint			open_index,
			open_mode;
 char			new_name[256]; 
 int			name_len;

/* return real definition valid for myself */

 new_file_name = NULL;
 act_name = NULL;

 /*" Is this definition %s already in the hcode table\n",me->total_name */
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 if(h_table != NULL) ACret_in_symbol(my_grid,real_def,0);
 else 		     real_def->objid = NULL_OBJID;

 if(IF_NULL_OBJID(real_def->objid))
 {
 /*| no ---> need to mount corresponding file */

   separ  = strchr(me->total_name,',');
   if(!separ) return OM_W_ABORT;
   *separ = '\0';
   macro_name = separ+1;
   file_name = me->total_name;


   rc = di$give_pathname(osnum = my_grid.osnum ,
                      pathname = full_dir_name);

#ifdef	DEBUG
   printf(" MACRO:%s FILE:%s DESIGN: %s\n",macro_name,file_name,full_dir_name);
#endif

   if( strcmp( file_name, &full_dir_name[1] ) == 0 ){

     /*
      * reset the instance values properly for use.
      */
     sprintf(me->total_name, ".,%s", macro_name );
#ifdef	DEBUG
     printf("--- TOTAL_NAME : %s \n", me->total_name );
#endif

     separ  = strchr(me->total_name,',');
     if(!separ) return OM_W_ABORT;
     *separ = '\0';
     macro_name = separ+1;
     file_name = me->total_name;
  }

  if( strcmp(file_name,".") ){
     status =
     ACactivate(file_name,&dir,EX_read_only,&open_index,&open_mode,
						my_grid.osnum);
     if( status&1 ) act_name = file_name;
   }
   else
   {
     char path_name[80];
     ACos_to_path(OM_Gw_current_OS,path_name);
     status = ACactivate(path_name,&dir,EX_read_only,&open_index,&open_mode,
						my_grid.osnum );
     if( status&1 ) act_name = path_name;
   }

/* 
    JLA 11 June 89 : Some dim macros are with the full file name instead of
    the path name relative to the PPL path (I don't know why ....)
*/
   if(!(status&1))
    {
     new_file_name = strrchr(file_name,'/');
     if(new_file_name != NULL)
       {
        new_file_name++ ;

#ifdef	DEBUG
	printf(" new_file_name : %s \n", new_file_name );
#endif

        status = ACactivate(new_file_name,&dir,EX_read_only,&open_index,
					&open_mode, my_grid.osnum );
	if(status&1)
	 {
          *separ = ',';
          strncpy( new_name,new_file_name,256);
	  new_name[255] = '\0';
	  new_file_name = new_name;
          act_name = new_file_name;
         }
	else new_file_name = NULL;
       }
    }

   /*
    * Add the library name in the list of existing macros libraries.
    * This to avoid duplication of research for an on existing 
    * library.
    * The libraries will be freed at the end of the sleep session of
    * the class super_para.
    *
    * Adz: 06/03/94 
    */

   {
   struct GRid	dir;
   IGRint      index, already;
   IGRint      tmp_index;
   IGRchar     *tmp_name;

    if((status&1) && (act_name) && !( AClib_dir( act_name, &dir ) & 1 )){
        
#ifdef	DEBUG
      printf(" ACtmp_defn:  CHECK -> %s \n", act_name );
#endif
      if( act_name[0] == '\0') already =1;
      else{
        already = 0;
        for( index=0 ; index<ACpath_gr_number; index++ ){
          tmp_index = ACpath_in_open[index];
          tmp_name = &ACopen_name_array[ACopen_info[tmp_index].name];
          if(strcmp(tmp_name,act_name) == 0) { already = 1; break; }
        }
      }

      if( ! already ){
 
        if(ACpath_gr_number >= ACpath_gr_total){

          ACpath_gr_total += 10;
          if(ACpath_grid == NULL){
            /*| allocate ACpath_gr */
            ACpath_grid = (struct GRid *)om$malloc(
                    size = ACpath_gr_total*sizeof(struct GRid));
            ACpath_in_open = (IGRint *)om$malloc(
                    size = ACpath_gr_total*sizeof(IGRint));
          }
          else{
            /*| reallocate ACpath_gr */
            ACpath_grid = (struct GRid *)om$realloc(
			ptr = (IGRchar *)ACpath_grid,
                    	size = ACpath_gr_total*sizeof(struct GRid));
            ACpath_in_open = (IGRint *)om$realloc(
			ptr = (IGRchar *)ACpath_in_open,
                    	size = ACpath_gr_total*sizeof(IGRint));
          }
        }
        ACpath_in_open[ACpath_gr_number] = open_index;
        ACpath_grid[ACpath_gr_number++] = dir;
      }
    }
   }

   *separ = ',';

   if(status&1)
     {
      status = om$send( msg = message IGRdir.translate(&msg,macro_name,
						   0,NULL,&real_def->objid),
		     targetid = dir.objid,
		     targetos = dir.osnum);
      real_def->osnum = dir.osnum;
     }
   else
     {
      msg = 0;
     }
   if(msg != DIR_S_SUCCESS)
     {
      /*| Try to find the macro def in the current ACpath */
      status = ac$find_macro_defn(action = ACfind_no_load,
				  macro_name = macro_name,
				  p_macro_defn_id = real_def);
      if(status&1)
       {
	 status = ac$lib_name(osnum = real_def->osnum,
			      name_size = 256,
			      name = new_name,
			      name_len = &name_len);
       }
      if((status&1) && (name_len + strlen(macro_name)+1 < 256))
       {
	/* new_name[255] = '\0'; */
	new_name[name_len-1] = ',';
	strcpy( new_name+name_len, macro_name );
	new_file_name = new_name;

#ifdef	DEBUG
	printf("new info stored %s\n",new_file_name );
#endif
       }
      else status = OM_W_ABORT;
  
      
      if(status&1)
        {
 	 msg = DIR_S_SUCCESS;
        }
     }

/* If the real macro is not found error message only if it is not during
   save
*/

   if(msg != DIR_S_SUCCESS)
     {
      if (h_table == NULL)
       {
	printf("\nMacro %s not found in library %s\n", macro_name,file_name );
	return OM_W_ABORT;
       }
      else
       {
	return OM_S_SUCCESS;
       }
     }

   if(h_table != NULL) ACadd_in_symbol(my_grid,*real_def,0);
  }

  /* JLA 11 June 89 : Correct file name if necessary 
   * check if the name is realy different.
   */

  if(( new_file_name != NULL ) &&
     ( strcmp( me->total_name, new_file_name ) != 0 )) {

    as$status(	sts = 0,
		string=("Macro [%d,%d]: Changed %s -> %s\n",
				my_id, OM_Gw_current_OS,
				me->total_name, new_file_name ));

    status = om$vla_set_dimension(varray = me->total_name,
				 size = strlen(new_file_name)+1);
    as$status(action = RET_STATUS);
    strcpy( me->total_name, new_file_name );
  }
   
  return(OM_S_SUCCESS);
}

end implementation ACtmp_defn;
