/*
 *  10/30/1997 Art Hundiak Fixed up warnings
 */

/*
  ACinit.I
  robert patience
  21_jul_86
*/
class implementation ACcpx;

#include "ASmacroi.h"
#include "ci.h"
#include "ciexecmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "acmacros.h"

extern struct GRid	*ACpath_grid;
extern struct GRid	 AC_construct_id;
extern int		 ACpath_gr_number;
extern char		 ACwd[];               /* name of the file */

from IGRdir import translate;

#define AS_DEBUG

/* ========================================================================= */
/* 	This function is the one called by the macro ac$find_macro_defn()
/*
/*	Argument descriptiion :
/*	-----------------------
/*
/*	int action		I : flag indicatiing the action to do
/*
/*		#define ACfind_no_load	0 find the macro def
/*		#define ACfind_load	2 if not found try to load it
/*		#define ACfind_connect	4 connect to the found or loaded 
/*					  definition.
/*
/*	struct GRid caller_id	I : Id of the object tha might want 
/*				    to attach to the found or 
/*				    loaded definition
/*
/*	char *macro_name	I : name of the macro to find or load
/*
/*	struct GRid *macro_defn	O : GRid of the definition found or loaded
/*
/*	Return code :
/*	------------
/*
/*		0 : FAILURE to find or to load
/*		1 : SUCCESS
/*
/* ========================================================================= */

#argsused // Fix warnings

int ACfind_macro_defn(action, caller_id, macro_name, osnum,  macro_defn )
int		action;
OM_S_OBJID 	caller_id;
char 		*macro_name;
OMuword 	osnum;
struct GRid 	*macro_defn;
/*.ACfind_macro_defn*/
{
  IGRint 	status, msg, rc;
  OM_S_OBJID    macro_f_id;
  IGRint 	idir;
  int work_in_path;

  /* 10/30/97 Art Hundiak
   * Wonder whose bright idea it was to put a staic global in an
   * include file ???
   */
  if (SCI_fileid);

  rc=1;
   /*^
     printf("macro_name %s action %d osnum %d \n",
		macro_name, action, osnum );
     printf("AC_construct_id.objid %d  AC_construct_id.osnum %d \n",
	AC_construct_id.objid, AC_construct_id.osnum );
  */
  macro_defn->objid = NULL_OBJID;
  macro_defn->osnum = AC_construct_id.osnum;

  if(macro_name[0] == ':')
   {
     rc = di$translate(   objname = macro_name,
                           p_objid = &macro_defn->objid,
                           p_osnum = &macro_defn->osnum );
   }
  else
   {
    work_in_path = 0;
    for(idir=0, msg = OM_S_SUCCESS ; idir<ACpath_gr_number ; idir++)
     {
      /*"search in %d %d\n",ACpath_grid[idir].objid,ACpath_grid[idir].osnum*/
      if(  (ACpath_grid[idir].osnum ==  AC_construct_id.osnum )
         &&(ACpath_grid[idir].osnum ==  AC_construct_id.osnum ))
	 						work_in_path = 1;
      status = om$send ( msg = message IGRdir.translate( &msg, macro_name,
						0,NULL,&(macro_defn->objid)),
		     senderid = NULL_OBJID,
		     targetid = ACpath_grid[idir].objid, 
		     targetos = ACpath_grid[idir].osnum );

      if(msg == DIR_S_SUCCESS)
         {
          /*"%s found in os %d \n",macro_name,ACpath_grid[idir].osnum */
           macro_defn->osnum = ACpath_grid[idir].osnum;
           break;
         }
      }

    if ( (msg != DIR_S_SUCCESS) && (msg != DIR_W_NAME_NOT_FOUND) )
    						di$report_error ( sts = msg );

    /*"macro %s --> %d %d\n",macro_name,macro_defn->objid,macro_defn->osnum */

/*    if(IF_NULL_OBJID(macro_defn->objid))
/*     {
/*      macro_defn->osnum = AC_construct_id.osnum;
/*      status = om$send ( msg = message IGRdir.translate( &msg, macro_name,
/*					      0,NULL,&(macro_defn->objid)),
/*		     senderid = NULL_OBJID,
/*		     targetid = AC_construct_id.objid, 
/*		     targetos = AC_construct_id.osnum );
/******************/

/** Allow a dynamics load only if the working directory is part of the path */

      if(IF_NULL_OBJID(macro_defn->objid))
       {
        char 	name_ext[80];
    
        rc = 0; /* macro not found */
        if(action & ACfind_load)
         {
           if(macro_name[0]=='d' && macro_name[1]=='i')
           {
             int sz = strlen (&macro_name[3]);
             if (sz > 76) sz = 76;
             strncpy(name_ext,&macro_name[3], sz);
           }
           else
           {
             int sz =  strlen (macro_name);
             if (sz > 76) sz = 76;
             strncpy(name_ext, macro_name, sz);
           }
           strcat(name_ext, ".u");

           status = ci$exec( file_name = name_ext,
		     	     sender_id  = NULL_OBJID,
			     file_id	  = &macro_f_id);
           if(!(status&1)) rc=0;
           else
           {
             macro_defn->osnum = AC_construct_id.osnum;
             status=om$send ( msg = message IGRdir.translate( &msg, macro_name,
					         0,NULL,&(macro_defn->objid)),
		     senderid = NULL_OBJID,
		     targetid = AC_construct_id.objid, 
		     targetos = AC_construct_id.osnum );
             if ( msg != DIR_S_SUCCESS)
             {  
               di$report_error ( sts = status );
               rc=0;
	     }
	     else
	       rc=1;
           }
         }
       }
  /*  } */
  }
  /*"macro %d %d \n", macro_defn->objid, macro_defn->osnum */
  /*"rc %d\n", rc */
  return(rc);
}
end implementation ACcpx;
