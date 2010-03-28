/* #######################    APOGEE COMPILED   ######################## */
class implementation GRds;

#include "grimport.h"
#include "dsmacros.h"
#include "msdef.h"

from GRdsnew import get_grds, put_grds, del_grds;

/*
 * Function:   _ds_do
 *
 * Purpose:    Constructs and wakes up the drawing sheet manager object
 *             and sends the appropriate message to that object.
 *
 * Returns:    OM_S_SUCCESS - on success
 *             OM_E_ABORT   - on failure 
 *                                 - couldn't construct global data object
 *                                 - message send didn't work
 */
extern IGRint _ds_do      (IGRlong * msg,
                           IGRlong   op,
                           IGRlong   type,
                           IGRchar * buffer1,
                           IGRchar * buffer2)
{
     IGRlong        status;
     OM_S_MESSAGE   *m;
     OM_S_OBJID     mod_id, oid;
     OMuword        mod_osnum;

     status = *msg = OM_S_SUCCESS;
     m = (OM_S_MESSAGE *)NULL;

     /*
      * Create the drawing sheet manager object if it is not already created.
      */
     status = ex$get_cur_mod( id = &mod_id, 
                              osnum = &mod_osnum );

     status = ex$get_super( mod_id = mod_id, 
                            mod_osnum = mod_osnum,
                            super_name = DS_SUPER_NAME,
                            create = FALSE,
                            super_class = "GRdsnew",
                            super_id = &oid );

     if (!(status & 1) || (oid == NULL_OBJID))
     {
         struct GRid    super_id;

         /*
          * See if the old super is still around ...
          */
         status = ex$get_super( mod_id = mod_id, 
                               mod_osnum = mod_osnum,
                               super_name = "DSMgr",
                               create = FALSE,
                               super_class = "GRds",
                               super_id = &oid );

         if ((status & 1) && (oid != NULL_OBJID))
         {
	     /*
	      * Convert the old super to the new super, this will delete
              * the old super. This is the only place that an autoconversion
              * will take place.
              */
             super_id.objid = NULL_OBJID;
         
             status = om$send (msg = message GRds.auto_convert (msg, &super_id),
                               senderid = NULL_OBJID,
                               targetid = oid,
                               targetos = mod_osnum);

             if (!(status & *msg & 1) || (super_id.objid == NULL_OBJID))
             {
                 *msg = MSFAIL;
                 goto quit;
             }
         
             oid = super_id.objid;
         }
	 else /* There is no super either old or new, so create a new one */
	 {
	     status = ex$get_super( mod_id = mod_id, 
        	                    mod_osnum = mod_osnum,
	                            super_name = DS_SUPER_NAME,
	                            create = TRUE,
	                            super_class = "GRdsnew",
	                            super_id = &oid );

	     if (!(status & 1) || (oid == NULL_OBJID))
             {
	         *msg = MSFAIL;
                 goto quit;
	     }
         }
     }

    
     /*
      * Send the appropriate message to the drawing sheet manager.
      */     
     switch ( op ) 
     {
          case ds_get: 
               m = message GRdsnew.get_grds(msg, type, buffer1);
               break;

          case ds_put: 
               m = message GRdsnew.put_grds(msg, type, buffer1, buffer2);
               break;

          case ds_del: 
               m = message GRdsnew.del_grds(msg, type, buffer1, 0);
               break;
     }

     status = om$send( targetid = oid,
                       targetos = mod_osnum,
                       msg = m,
                       senderid = NULL_OBJID );

 quit:
         
     return status;
}

end implementation GRds;
