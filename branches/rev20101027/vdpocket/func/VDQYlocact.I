/* $Id: VDQYlocact.I,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/func / VDQYlocact.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDQYlocact.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
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
# Revision 1.2  1995/08/30  15:40:12  pinnacle
# Replaced: vdpocket/func/VDQYlocact.I for:  by yzhu for vds.240
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

class implementation Root;


#define NOT_SHARABLE
#define NOT_COSHARABLE

#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "exdef.h"
#include "lcdef.h"
#include "OMerrordef.h"
#include "codef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "lc.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "igrmacros.h"
#include "VDmem.h"
#include "v_dbgmacros.h"


IGRint VDQYlocact( args, new_entry, locate_args, action )

struct LC_action_args		*locate_args;
enum   GRlocate_action		*action;
IGRchar				*args;
struct GRlc_info		*new_entry;

{
    IGRchar                class_name[80];
    IGRint                 i;
    OMuint                 count;
    IGRint                 status = OM_S_SUCCESS,
                           string_status;
    IGRboolean             di_exists;
    struct GRid            di_grid;
    OM_S_CHANSELECT        to_comp_chandef;
    OM_S_OBJECT_LINKAGE   *channel_list = NULL;

    SetProc(VDQYlocact); Begin
    switch (*action)
    {
       case end_transition:
       case start_transition:
       case post_object:
       case check_object:
          status = OM_S_SUCCESS;   /* reject transition */
          goto quit;

       default:
          /* 
           * Otherwise add the object to the stack
           * and check conditions
           */

           status = om$get_classname( classname = class_name,
                                      objid = new_entry->located_obj.objid,
                                      osnum = new_entry->located_obj.osnum );

           /*
            *  check the classname
            */
           status = om$is_ancestry_valid( subclassname = class_name,
                                          superclassname = "GRgrgrp" );

           string_status = strcmp( class_name, "GRgrgrp" ) == 0;

           if (! ((status == OM_I_INVANCESTRY) && (!string_status)) )
           {
              status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                          p_chanselect = &to_comp_chandef );
              status = om$get_channel_count(
                                      objid = new_entry->located_obj.objid,
                                      osnum = new_entry->located_obj.osnum,
                                      p_chanselect = &to_comp_chandef,
                                      count = &count);
/*
              channel_list = (OM_S_OBJECT_LINKAGE *)om$malloc(size = 
                                    (sizeof(OM_S_OBJECT_LINKAGE)) * count);
*/
              channel_list = _MALLOC(count, OM_S_OBJECT_LINKAGE); 
              /*
               * Get objid and object space number of GO
               */
              status = om$get_channel_objects(
                                      objid = new_entry->located_obj.objid,
                                      osnum = new_entry->located_obj.osnum,  
                                      p_chanselect = &to_comp_chandef,
                                      list  =  channel_list,
                                      size  =  count,
                                      count = &count);

              di_exists = FALSE;    /* initialize index and flag */
              i = 0;

              while( (!di_exists) && (i < count) )
              {
                 di_grid.osnum = OM_Gw_current_OS;
                 di_grid.objid = NULL_OBJID;

                 status = om$get_classname( classname = class_name,
                                            objid = di_grid.objid,
                                            osnum = di_grid.osnum );
                 /*
                  *  check the classname
                  */
                 status = om$is_ancestry_valid( subclassname = class_name,
                                                superclassname = "IGRdir" );

                 string_status = strcmp( class_name, "IGRdir" ) == 0;

                 if ( (!(status == OM_I_INVANCESTRY)) && (string_status) )
                 {
                    di_exists = TRUE;
                 }

                 i++; /* increment chan_list index */
              }                			   

              _FREE(channel_list);

              /* If no di exists then none of the elements is a directory.
               * Therefore the graphic group is ineligible for being located.
               * If an error is returned the locate will not find another
               * GO/group, therfore we pass back a success message so the
               * locate code will attempt to find another object.
               */
              if( !di_exists )
              {
                 status = OM_S_SUCCESS;
                 goto quit;
              }
          }
          else   /* we have a GO not a graphic set or graphic group. */
          {
             di_grid.osnum = OM_Gw_current_OS;
             di_grid.objid = NULL_OBJID;

             status = om$get_classname( classname = class_name,
                                        objid = di_grid.objid,
                                        osnum = di_grid.osnum );
             /*
              *  check the classname
              */
             status = om$is_ancestry_valid( subclassname = class_name,
                                            superclassname = "IGRdir" );

             string_status = strcmp( class_name, "IGRdir" ) == 0;

             if ( (status == OM_I_INVANCESTRY) && (!string_status) )
             {
                 return( status );
             }
          }
          /*
           *    call LCptlocact
           */
          status = LCptlocact( args, new_entry, locate_args, action );
       break;
    }

 quit:
    End
    return( status  );
}

end implementation Root;
