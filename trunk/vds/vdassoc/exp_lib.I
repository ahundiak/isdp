/* $Id: exp_lib.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / exp_lib.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: exp_lib.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.2  1995/11/03  17:17:24  pinnacle
# Replaced: ./vdassoc/exp_lib.I for:  by azuurhou for vds.240
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
  Filename : exp_lib.I

  09/26/94    rmn    Introduced kludge to fix bug in directory 
                     commands form regarding improper 
                     display of expressions
 */

class implementation expression;

#include "string.h"
#include <OMminimum.h>
#include <OMmacros.h>
#include "exmacros.h"
#include "AS_status.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "expression.h"
#include "expmacros.h"
#include "asmacros.h"
#include "asbox.h"
#include "godef.h"

#define AS_DEBUG 1
#define DEBUG 0
extern  GRclassid  OPP_ACpretend_class_id,
		   OPP_ASsource_class_id,
		   OPP_ACrg_collect_class_id;

from ACpretend    import   ACgive_downscan;
from ASnode       import   ACgive_path;
from ACdiowner    import   ACgive_path;

EXP_rec_untranslate(objid,osnum,name)
OM_S_OBJID objid;
GRspacenum osnum;
char *name;
/*.EXP_rec_untranslate*/
{
 struct GRid tmp_grid,owner;
 int status,sts,msg;
 int len, n;
 char loc_name[DI_PATH_MAX];
 OM_S_MESSAGE mess;
 struct 
      {int *succ;struct GRid *go_obj; char *footname;} tmp;
 GRclassid classid;

 /* Perform if necessary a recursive untranslate */
 tmp_grid.objid = objid;
 tmp_grid.osnum = osnum;
 
 /*" initial %d\n",objid */
/* status = om$send(msg = message NDnode.ASreturn_go(&tmp_grid,NULL,NULL),
/* 		  senderid = NULL_OBJID,
/*		  targetid = objid,
/*		  targetos = osnum);
/* if(!(status&1))
/*   {
/*    tmp_grid.objid = objid;
/*    tmp_grid.osnum = osnum;
/*   }
/******/

 status = om$get_classid( objid = objid,
			  osnum = osnum,
			  p_classid = &classid);

 if(om$is_ancestry_valid(superclassid = OPP_ACpretend_class_id,
			 subclassid = classid) == OM_S_SUCCESS)
  {
   /*| The object is a pretend */
   /*| Get the macro and its name */
   status = DIR_W_NAME_NOT_FOUND; 
   sts = om$get_objid_at_index(objid     = objid,
                           osnum          = osnum,
                           p_chanselect   = &ND_father,
                           index          = 0,
                           osnumaddr      = &owner.osnum,
                           objidaddr      = &owner.objid);
   if(sts&1)
    {
     status = di$untranslate(objid = owner.objid,
                             osnum = owner.osnum,
                             objname = name);
     if(status == DIR_S_SUCCESS)
       {
	len = strlen(name);
	name[len]=':';
        sts=om$send(msg = message ACpretend.ACgive_downscan(name+len+1),
		      senderid = NULL_OBJID,
		      targetid = objid,
		      targetos = osnum);
        if(!(sts&1)) status = DIR_W_NAME_NOT_FOUND;
       }
    }

  }
  else 
  {
/* START VDS CORRECTION */
     struct GRid      current_obj;
/* END   VDS CORRECTION */

    status = om$get_objid_at_index ( objid     = objid,
      osnum 	     = osnum,
      p_chanselect   = &AS_to_owner,
      index          = 0,
      osnumaddr      = &owner.osnum,
      objidaddr      = &owner.objid );
    /*
     * Make sure the owner is not a save set
     */
    if (status == OM_S_SUCCESS)
    {
      extern GRclassid OPP_GRsvset_class_id;
      GRclassid        classid;
      
      status = om$get_classid ( objid = owner.objid,
        osnum = osnum, p_classid = &classid );
      if (om$is_ancestry_valid(superclassid = OPP_GRsvset_class_id,
            subclassid = classid) == OM_S_SUCCESS)
        status = OM_W_ABORT;
    }
    
    if (status == OM_S_SUCCESS)
    {
      /* The object is in a macro or is an associative attribute */
    
      owner.objid = objid;
      owner.osnum = osnum;
      status = DIR_W_NAME_NOT_FOUND;
      while(1)
      {

/* START VDS CORRECTION */
        current_obj.objid = owner.objid;
        current_obj.osnum = owner.osnum;
/* END   VDS CORRECTION */

        /*| get and translate its owner */
        sts = om$get_objid_at_index( objid     = current_obj.objid,
            osnum     = current_obj.osnum,
            p_chanselect   = &AS_to_owner,
            index          = 0,
            osnumaddr      = &owner.osnum,
            objidaddr      = &owner.objid);
        if(!(sts&1)) break;

        status = di$untranslate(objid = owner.objid, 
            osnum = owner.osnum,
            objname = name);

        if(status != DIR_S_SUCCESS ) continue;
    
        /*| Get the name of the element in the owner */
    
        tmp.footname = &loc_name[1];
        tmp.go_obj = &tmp_grid;
        tmp.succ = &msg;
        status = om$get_classid( objid = owner.objid,
            osnum = owner.osnum,
            p_classid = &classid);
        status = om$make_message( classid = classid,
            methodname = "ACgive_path",
            size = sizeof(tmp),
            p_arglist = &tmp,
            p_msg = &mess);
	if( !(status & 1)) break ;
    
        status = om$send(msg = &mess,   
            targetid = owner.objid,
            targetos = owner.osnum,
            senderid = NULL_OBJID);
    
        if(status & msg&1)
        {
          loc_name[0]=':';
          /*"name %s loc_nane %s\n",name,loc_name*/
          strcat(name,loc_name);
          status = DIR_S_SUCCESS;
          break;
        }

/* START VDS CORRECTION */
        /* 
         * KLUDGE ----- (code below) --------      rmn
         * (Only if the above code fails will the kludge be executed)

         * This kludge has been introduced to fix the directory commands bug.
         * The expressions were being displayed by objid, instead of by name
         * for those expressions which were contents of rg_collector 
         * which was in turn the foot of an associative complex.  
         * i.e for nested rg_collector contents, the display was improper.
         *
         * This was because the rg_collector foot of an associative complex
         * is not a named element, as a result of which the di$untranslate
         * being called on it failed.  The above code would trace to
         * the ACncpx owner, to send ACgive_path, instead of to the 
         * immediate rg_collector owner.  ACgive_path would fail on the
         * complex for the expression object, and the status returned would be
         * DIR_W_NAME_NOT_FOUND
         *
         * To fix this problem, the following kludge is introduced.
         * If the owner object is an rg_collector, then, get the name 
         * (by sending ACgive_path) of the collector from its owner, 
         * ie the associative complex object.
         * Then get the name (ACgive_path) of the expression from the
         * rg_collector object (immediate owner).  strcat appropriately the
         * two names and return DIR_S_SUCCESS.
         */

        /* check if the current class is ACrg_collect */

        status = om$get_classid( objid = current_obj.objid,
                                 osnum = current_obj.osnum,
                                 p_classid = &classid);
        
        if( om$is_ancestry_valid( superclassid = OPP_ACrg_collect_class_id,
                                  subclassid = classid) == OM_S_SUCCESS )
        {
           /*
            * if rg_collector, then get the name of the collector 
            * from the owner 
            */

           status = 
           om$send( msg = message ASnode.ACgive_path(  &msg,
                                                       &current_obj,
                                                       &loc_name[1] ),
                    senderid = NULL_OBJID,
                    targetid = owner.objid,
                    targetos = owner.osnum );

           if( !( status & msg & 1) )
           {
              status = DIR_W_NAME_NOT_FOUND;
              break;
           }

           loc_name[0] = ':';
           len = strlen(loc_name);
           loc_name[len] = ':';

           tmp_grid.objid = objid;
           tmp_grid.osnum = osnum;

           /* now get the name of the expression from the rg_collector owner */

           status = 
           om$send( msg = message ACdiowner.ACgive_path( (IGRlong *)&msg,
                                                         &tmp_grid,
                                                         &loc_name[len+1] ),
                    senderid = NULL_OBJID,
                    targetid = current_obj.objid,
                    targetos = current_obj.osnum );

           if( !(status & msg &1) )
           {
              status = DIR_W_NAME_NOT_FOUND;
              break;
           }
           
           /* concatenate to get the full path name */

           n = DI_PATH_MAX - ( strlen(name) + 1 );
           strncat( name, loc_name, n);
           name[DI_PATH_MAX-1] = '\0';

           status = DIR_S_SUCCESS;
           break;
        }

/* END  VDS CORRECTION */

      }
    }
    else
    {
      status = om$get_classid( objid = objid,
          osnum = osnum,
          p_classid = &classid);
      if(om$is_ancestry_valid(superclassid = OPP_ASsource_class_id,
          subclassid = classid) == OM_S_SUCCESS)
      {
        OM_S_OBJECT_LINKAGE    list [1];
        OMuint                 count;
        extern OM_S_CHANSELECT AS_listeners;
        /*
          * We get the child of the ASsource
          */
        om$get_channel_objects ( objid = objid, 
            osnum = osnum,
            p_chanselect = &AS_listeners, 
            list = list,
            size = 1,
            count = &count );
        osnum = list [0].osnum;
        objid = list [0].S_objid;
      }
    
      /*" %d %d is a regular expression\n",objid,osnum */
      status = di$untranslate(objid = objid, 
          osnum = osnum,
          objname = name);
      /*"name %s\n",name */
    }
  }
 
  if(status != DIR_S_SUCCESS)
  {
   name[0] = '\0';
  } 
  
  return(status);
}
end implementation expression;
