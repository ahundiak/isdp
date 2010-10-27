/* $Id: SMCoUtil.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMCoUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCoUtil.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
    File             SMCOUtil.I;
    Creation Date    September 92
    Auteur           Jean Jasinczuk (ISDC)

    Some utilities for command objects

    History
*/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#define AS_DEBUG	1
#include "AS_status.h"

from GRgraphics import GRgetname,GRputname,GRchgname; 

 /* Given an element and his new split name */
 /* Change the name of the object with respect to the old directory */
 /* If the old name of the object doesn't exist simply put the name */
 /*  It return  : */
 /*  1  Previous name found and possible change name */
 /*  2  No previous name found but change made */
 /*  3  New name and old name are same */
 /*  0  Change name fail */
SMChgElemName(obj,new_name,mod_env)
struct GRid *obj;
IGRchar *new_name;
struct GRmd_env *mod_env;
{
  IGRlong status,msg;
  char old_name[DI_PATH_MAX];
  char *pt;

  if(new_name == NULL) return 0;
 
  old_name[0] = '\0';
  status = om$send(msg = message GRgraphics.GRgetname(&msg,old_name),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum);
  if(!(status & msg & 1) || old_name[0] == '\0')
   {
     status = om$send(msg = message GRgraphics.GRputname(&msg,new_name),
		      senderid = NULL_OBJID,
		      targetid = obj->objid,
		      targetos = obj->osnum);
     if(!(status & msg & 1)) return 0;
     return 2;
   }

  /* Old name exists */

  if(new_name[0] == ':') /* Absolute path given */
   {
     if(strcmp(new_name,old_name) == 0) return 3; /* Name not change */
     status = om$send(msg = message GRgraphics.GRchgname(&msg,mod_env,new_name),
		      senderid = NULL_OBJID,
		      targetid = obj->objid,
		      targetos = obj->osnum);
     if(!(status & msg & 1)) return 0;
     return 1;
   }

  /* Relative path */
  pt = strrchr(old_name,':');
  if(pt)
   {
     if(strcmp(pt + 1,new_name) == 0) return 3; /* Name not change */
     *pt = '\0'; 
    {
      DIstmcat(old_name,new_name,NULL); /* name contains complete path */
      status = om$send(msg = message GRgraphics.GRchgname
		       (&msg,mod_env,old_name),
		       senderid = NULL_OBJID,
		       targetid = obj->objid,
		       targetos = obj->osnum);
      if(!(status & msg & 1)) return 0;
      else return 1;
    }
   }
  return 0;
}

 /* Test if we can change the  name of an element */
 /*  with respect to the previous directory */
 /* If NULL_OBJID given, simply verify that name doesn't already exists */ 
 /*  It return  : */
 /*  1        Previous name found and possible change name */
 /*  2        No previous name found but change possible */
 /*  3        New name and old name are same */
 /*  0        No permission to change name */
SMCanChgElemName(obj,new_name)
struct GRid *obj;
IGRchar *new_name;
{
  IGRlong     status,msg;
  char        name[DI_PATH_MAX],dir_name[DI_PATH_MAX],cur_dir[DI_PATH_MAX];
  char        *pt;
  struct GRid tmp_obj;

  if(new_name == NULL) return 0;
 
  name[0] = '\0';
  status = om$send(msg = message GRgraphics.GRgetname(&msg,name),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum);
  if(!(status & msg & 1) || name[0] == '\0')
   {
     if(di$translate(objname = new_name,p_objid = &tmp_obj.objid)
	== DIR_S_SUCCESS)
       return 0;   /* Name already exist */
     
     if(new_name[0] == ':') /* It's an absolute name */
      {
	di$split (pathname = new_name, dirname  = dir_name);
	if(di$translate(objname = dir_name, p_objid = &tmp_obj.objid)
	   != DIR_S_SUCCESS)
	  return 0;   /* Directory doesn't exists */       
	else return 2; /* No previous name found but change possible */
      }
     
     /* User want add in working directory */
     pt = strrchr(new_name,':');
     if(pt == NULL)
       return 2;  /* Should be improve to see  if write access */
    
     /* Relative path given */
     di$pwd(dirname = cur_dir);
     DIstmcat(cur_dir,new_name,NULL);
     pt = strrchr(cur_dir,':');
     *pt = '\0';

     if(di$translate(	objname = cur_dir,
			p_objid = &tmp_obj.objid) != DIR_S_SUCCESS)
       return 0;   /* Directory doesn't exists */       
     else return 2; /* No previous name found but change possible */
   }


  if(new_name[0] == ':') /* It's an absolute name */
   {
     if(strcmp(new_name,name) == 0) return 3; /* New and old name egal */
     di$split (pathname = new_name, dirname  = dir_name);
     if(di$translate(objname = dir_name, p_objid = &tmp_obj.objid)
	!= DIR_S_SUCCESS)
       return 0;    /* Directory doesn't exists */       
     else return 1; /* Previous name found and change possible */
   }

  pt = strrchr(name,':');
  if(pt)
   {
     if(strcmp(pt + 1,new_name) == 0) return 3;  /* New and old name egal */
     *pt = '\0'; 
    {
      DIstmcat(name,new_name,NULL); /* name contains complete path */
      if(di$translate(objname = name,p_objid = &tmp_obj.objid)
	 == DIR_S_SUCCESS)
	return 0;    /* Name already exists */
      
      di$split (pathname = name, dirname  = dir_name);
      if(di$translate(objname = dir_name,p_objid = &tmp_obj.objid)
	 != DIR_S_SUCCESS) 
	return 0;    /* Directory doesn't exists */     
      return 1;      /* Previous name found and change possible */
    }
   }
  return 0; /* Unknown error */
}

end implementation Root;



