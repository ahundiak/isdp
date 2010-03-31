/* ###################   APOGEE COMPILED   ################## */
/*
  ARGUMENTS
     
     Input:

     *env	  GRmd_env	 environment information
     old_obj	  struct GRid	 Object id & os of calling object
     *classname   IGRchar	 array for classname
     *properties  unsigned 	 common property bits
		  IGRshort
     *geometry	  IGRchar	 pointer to the geometry in 
				    internal format
     *chan_flag	  IGRshort	 flag to indicate whether or not 
				    channel linkages are to be
				    preserved:
				    0 = do not preserve
				    1 = preserve linkages    
     *del_flag	  IGRshort	 flag to indicate whether or not 
				    delete the input object:
				    0 = do not delete
				    1 = delete the old object

     Output:

     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSINARG classname incorrect
				    - MSFAIL if error occured
     *new_objid	  GRobjid	 new object id

  HISTORY

    MAS	05/16/86 : Creation date.
    SS  10/31/86 : Modified
    DLB 02/17/87 : added move_chan for to_loopset channnel
    gupta 03/20/87 : modified to move to_association channel
    rlw 04/07/87 : dlb forget to check if the object was a surface before
                   moving the loopset channel
    rlw 05/26/87 : gupta forget to check if the object was a surface before
                   moving the association channel
    gupta 10/21/87: removed association stuff for new system
    dhm   01/26/88: changed argument my_id to be struct GRid old_obj
    pp    05/30/88: moving the notification channel to the new object.
    SS    10/12/89: Added the notification stuff.
    DLB	   9/22/91  Removed GRgraphics.owners send.  Crashed on SUN but
		    is an EXNUC bug.  Chan was removed prior to 1.1.0!!
*/

class implementation GRvg;

#include "EMS.h"
#include "igrdef.h"
#include "msdef.h"
#include "emsdef.h"

from EMSsurface import EMpostgeomod, EMpostdelete;

IGRlong EMchgclass(msg, env, old_obj, classname,  properties,
		   geometry, chan_flag, del_flag, new_objid)


    IGRlong 	*msg; 			/* return message		*/
    struct GRmd_env *env; 		/* environment information	*/
    struct GRid	old_obj;			/* objects id & os      */
    IGRchar 	*classname; 		/* classname to construct	*/
    IGRushort *properties;	/* object properties		*/
    IGRchar 	*geometry; 		/* the new geometry		*/
    IGRshort	*chan_flag; 		/* indicator of whether channel
					   linkages should be maintained*/
    IGRshort	*del_flag;		/* indicator of whether the old
					               object old_obj should be deleted */
    GRobjid 	*new_objid;		/* the new object-id		*/

{
	IGRboolean	notify;		/* to notify or not to notify */
	IGRlong		msg2;		/* local message		*/
	IGRlong		OMmsg;		/* OM return code		*/

	GRclassid	classid;	/* classid needed by OM		*/

	OM_S_CHANSELECT chan_sel;
    OM_S_CHANSELECT to_loopset;

	IGRchar *es;
	struct GRsymbology symb;	/* symbology			*/
        struct IGResbc esbc;
        struct IGResbs esbs;
        struct GRprops geomprops;
	struct GRvg_construct arglist;	/* construct argument list	*/
        struct IGRbsp_curve *curve;	/* curve pointer		*/


	*msg = MSSUCC;			/* initialize to success	*/
	OMmsg = OM_S_SUCCESS;
	curve = (struct IGRbsp_curve *)geometry;

        notify = EMcheck_inhibit_postproc();

					/* get classid from OM		*/
        OMmsg = om$get_classid(classname = classname,
                               p_classid = &classid);

	if (! (1 & OMmsg))		/* get classid failed		*/
	{
	    *msg = MSINARG;
	    goto wrapup;
	}
					/* get symbology for construct	*/
 	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetsymb(&msg2,&symb),
                         senderid = NULL_OBJID,
                         targetid = old_obj.objid,
                         targetos = old_obj.osnum);

	if (! (1 & OMmsg & msg2))	/* get symbology failed		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
					/*set up arguments for construct*/
	arglist.level = symb.level;
	arglist.properties = *properties;

	arglist.name = 0;		/* new object will not be named	*/
	arglist.display = &(symb.display_attr);

               
 	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgeomprops (&msg2, 
                 &env->md_env.matrix_type,env->md_env.matrix, &geomprops),
                         senderid = NULL_OBJID,
                         targetid = old_obj.objid,
                         targetos = old_obj.osnum);

	if (! (1 & OMmsg & msg2))	/* get props failed		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}

        if (geomprops.type == GRSURFACE)
          es = (IGRchar *) &esbs;
        else
          es = (IGRchar *) &esbc;
 	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetattr (&msg2, es),
                         senderid = NULL_OBJID,
                         targetid = old_obj.objid,
                         targetos = old_obj.osnum);

	if (! (1 & OMmsg & msg2))	/* get props failed		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
	arglist.class_attr = es;	/*** at some point this will 
					     change		    *****/
	arglist.newflag = FALSE;
	arglist.msg = &msg2;
	arglist.geometry = geometry;
					/* set up new environment info	*/
	arglist.env_info = env;

	OMmsg = om$construct(osnum = old_obj.osnum,
                             classid = classid,
			     msg=message GRgraphics.GRconstruct(&arglist),
                             p_objid = new_objid,
                             neighbor = OM_GS_NULL_NEIGHBOR);

	if ( !(1 & OMmsg))		/* the construct failed		*/
	{
            *msg = MSFAIL;
	    goto wrapup;
        }

	if (*chan_flag)			/* channel linkages maintained	*/
	{	    
	    chan_sel.type = OM_e_name;
	    chan_sel.u_sel.name = "GRconnector.to_owners";

	    om$send (mode = OM_e_wrt_object,
		     msg = message Root.move_chan(
				chan_sel,old_obj.objid,old_obj.osnum,
				chan_sel),
		     senderid = NULL_OBJID,
		     targetid = *new_objid,
             targetos = old_obj.osnum);

/**************************DLB 9/22/91 - No such channel - crash on SUN
	    chan_sel.u_sel.name = "GRgraphics.owners";

	    om$send (mode = OM_e_wrt_object,
		     msg = message Root.move_chan(
				chan_sel,old_obj.objid,old_obj.osnum,
				chan_sel),
		     senderid = NULL_OBJID,
		     targetid = *new_objid,
             targetos = old_obj.osnum);
************************************************************************/

            chan_sel.u_sel.name = "GRnotify.notification";

	    om$send (mode = OM_e_wrt_object,
		     msg = message Root.move_chan(
				chan_sel,old_obj.objid,old_obj.osnum,
				chan_sel),
		     senderid = NULL_OBJID,
		     targetid = *new_objid,
            targetos = old_obj.osnum);

            if (geomprops.type == GRSURFACE) /* rlw's correction to dlb */
             {
        /**dlb's addition**/
              OMmsg = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
               if (! (1 & OMmsg)){*msg = MSFAIL; goto wrapup;}
              OMmsg = om$send (mode = OM_e_wrt_object,
    		     msg = message Root.move_chan(
    				to_loopset,old_obj.objid,old_obj.osnum,
    				to_loopset),
    		     senderid = NULL_OBJID,
			     targetid = *new_objid,
                 targetos = old_obj.osnum);
               if (! (1 & OMmsg)){*msg = MSFAIL; goto wrapup;}

              if (notify)
                {
                om$send (msg = message EMSsurface.EMpostgeomod (&msg2, NULL,
                 env, NULL, NULL), targetid = *new_objid,
                 senderid = NULL_OBJID, targetos = old_obj.osnum);
                notify = FALSE;
                }
             }
	}
	
	if (*del_flag)			/* delete old object		*/
	{
	    OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRgraphics.GRdelete(&msg2,env),
                            senderid = NULL_OBJID,
                            targetid = old_obj.objid,
                            targetos = old_obj.osnum);

	    if (! (1 & OMmsg & msg2))
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
	    }
            else if (notify)
            {
            om$send (msg = message EMSsurface.EMpostdelete (&msg2, NULL,
             env, NULL, NULL), targetid = old_obj.objid, senderid = NULL_OBJID,
             targetos = old_obj.osnum);
            notify = FALSE;
            }

	}

 wrapup:
	EMrestore_postproc();
	return (OMmsg);

}

end implementation GRvg;

