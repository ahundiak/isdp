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


IGRint QYlocact( args, new_entry, locate_args, action )

    struct LC_action_args  *locate_args;
    enum   GRlocate_action *action;
    IGRchar                *args;
    struct GRlc_info       *new_entry;

{
    IGRchar                class_name[80];
    IGRint                 i;
    OMuint                 count;
    IGRlong                msg,
                           status = OM_S_SUCCESS,
                           string_status;
    IGRboolean             di_exists;
    struct GRid            di_grid;
    OM_S_CHANSELECT        to_comp_chandef,
                           to_own_chandef;
    OM_S_OBJECT_LINKAGE   *channel_list = NULL;

    switch (*action)
    {
       case end_transition:
       case start_transition:
       case post_object:
       case check_object:
          status = OM_S_SUCCESS;   /* reject transition */
          goto quit;
       break;

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
              channel_list = (OM_S_OBJECT_LINKAGE *)om$malloc(size = 
                                    (sizeof(OM_S_OBJECT_LINKAGE)) * count);

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

              om$dealloc(ptr = channel_list);

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
    return( status  );
}

end implementation Root;
