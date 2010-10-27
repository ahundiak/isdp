/* $Id: VDRvItmUpd.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdannot/cmd/VDRvItmUpd.I
 *
 * Description:
 *      Implementation file for VDCmdRvItem.
 *      Methods :
 *                      VDupdateHighlight
 *                      VDupdatePfxList
 *                      VDupdateItemList
 *
 * Dependencies:
 *
 * Revision History:
 *
 *      12/14/94        R. Manem        Creation for OPE enhancements
 *	12/22/94	R. Manem	Check for ASsource and ACpretend
 *					parent, for fit object(6/29/95)
 *	12/29/94	R. Manem	Fit object with a factor of 2
 *	11/01/95	R. Manem	Fix for TR 179524352 :
 *					Highlight the correct item number when
 *					the displayed list is not the same as
 *					the complete list of item numbers for
 *					that table.
 *	06/29/95	Ad/Y.Zhu        Modify VDupdateHighlight to display
 *                                      item object with leader line on ref 
 *                                      file, 
 *      07/20/95        Y.Zhu           Modify VDupdateHighlight and 
 *                                      VDupdateItemList for items without
 *                                      ballon 
 * -------------------------------------------------------------------*/


class implementation VDCmdRvItem;

#include <stdio.h>
#include <string.h>

#include "OMparameters.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "ex.h"
#include "exdef.h"
#include "grio.h"
#include "griodef.h"
#include "griomacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "AS_status.h"
#include "asbox.h"
#include "nddef.h"
#include "dimdef.h"

#include "grdpbmacros.h"
#include "grerr.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "vdsmacros.h"

#include "VDSannot.h"
#include "FI.h"
#include "VDmsg.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define VD_FP        me^^CEO.forms[0].form_ptr

/*
#define DEBUG
*/

extern	GRclassid	OPP_ACncpx_class_id,	
			OPP_DMsrc_class_id,
			OPP_ASsourcein_class_id,
			OPP_ACpretendin_class_id,
			OPP_ACpretend_class_id,
			OPP_VDdrw2d_class_id,
			OPP_ASsource_class_id;

from 	VDitemSet	import	VDgetSetInfo;
from	ACcpx		import	find_macro;
from	ACcpx_defn	import	ACgive_name;
from	NDmacro         import  ACreturn_foot; 
from	NDnode		import	NDget_objects;
from	NDnode		import	ASreturn_go;
from    GRcontext       import  GRgetinstance;
/*+me
 -------------------------------------------------------------------------
  Public Message getWindow

  Abstract
	Gets and stores the window for fitting object

  Arguments
        long    *sts           O       Completion code

  Status
      status    OM_S_SUCCESS    if success

  Return Code
      sts
                VD_ERROR        if error

 -------------------------------------------------------------------------
-me*/

method getWindow( long *sts )
{
    IGRchar		winPrompt[] = "Identify window to fit object";
    IGRlong		msg;
    struct GRevent	event;

    SetProc( getWindow ); Begin
    *sts = MSSUCC;

    if( me->windowId.objid != NULL_OBJID )
        return OM_S_SUCCESS;

    /* erase the form */

    FIf_erase( VD_FP );

    while( 1 )
    {
        while(!co$getevent( msg			= &msg,
			    event_mask		= ( GRm_DATA ),
			    prompt		= winPrompt,
			    response		= me->response,
			    response_data	= me->response_data,
			    event		= &event ) )
	    ;
			    
        if( ( msg&1 ) && (*me->response == EX_DATA) )
        {
            me->windowId.objid = event.event.button.objid;
            me->windowId.osnum = event.event.button.osnum;
            break;
        }
    }

    /* restore the prompt */

    ex$message( msgnumb	= VD_P_DgEntPmFm );
       
    /* restore the form */

    FIf_display( VD_FP );

    End
    return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDupdateHighlight

  Abstract
	Updates the highlighing of objects and item numbers, based on the
	current options.

  Arguments
        long    *sts           O       Completion code

  Status
      status    OM_S_SUCCESS    

  Return Code
      sts       MSSUCC  

 -------------------------------------------------------------------------
-me*/

method VDupdateHighlight( long *sts )
{
    IGRint		row, pos, sel, index, 
			nb, nbItems, count,
			found, i,i1,i0;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    IGRchar		*c, buffer[100];
    GRobjid		*itemIds = NULL;
    OMuword		*itemOs = NULL;
    struct GRobj_env	parent ;
    struct GRid		objSrc, obj, obj1, obj2, macro, part, part1;
    GRclassid           obj_class;
    struct GRmd_env	objEnv;
    struct GRmd_env     modEnvObj;
    IGRint              nret,
                        size;
    IGRint              NbPrtnd, NbDrw2d;
    OM_S_CHANSELECT     to_child, to_prtnd;
    struct GRid         *Prtnd = NULL,
                        *Drw2d = NULL;
    struct GRid         ModelId;
    IGRint              ir;
    IGRchar             *buf,len;

  
    SetProc( VDCmdRvItem.VDupdateHighlight); Begin 
    *sts = MSSUCC;

    dp$erase_hilite( msg = &msg );

    /* empty name */
    if(me->curTblName[0]  == '\0') { 
      goto quit;
    }

    status =om$make_chanselect(channame  = "GRnotify.notification",
                                 p_chanselect  = &to_prtnd);

    status =om$make_chanselect(channame  = "NDchildren.children",
                                 p_chanselect  = &to_child);


    /* 
     * if highlight option = all nos,
     *     highlight all
     * else
     *     get active row and highlight it
     */

    if( me->highlightOpt ) {  /* highlight one */
    
        __DBGpr_com(" highlight one ");

        /* get active row */
        FIfld_get_active_row( VD_FP, VD_ITM_LIST_FLD, &row, &pos );
        FIfld_get_text( VD_FP, VD_ITM_LIST_FLD, row, 0, 100,
				(unsigned char *)buffer, &sel, &pos );
        if( !sel )
            goto quit;

        __DBGpr_str("buffer ", buffer );

        if( !me->ballonTog ) {  /* with ballon */ 

           __DBGpr_com(" highlight one with ballon ");
           index = me->tables[me->curTblIndex].startIndex;
           nbItems = me->tables[me->curTblIndex].nbItems;

           found = 0;
           i = index + row;
           if( i < index + nbItems ) 
                found = 1;
               
           if( !found )
            goto quit;
           
           /* for reduced list case */

           buf = &buffer[1];
           len = strlen( buf);
           buf[len-1] = '\0';
	   __DBGpr_str(" buf", buf);
           
           for ( ir = index; ir < index + nbItems; ir++ ) {

              if (!strcmp(buf, me->items[ir].itemStr)) {
                   i = ir;
                   break;
              }
           }
                 

           /* first fit object if necessary */
	   parent.obj_id.objid = NULL_OBJID ;

           if( me->fitObjOpt ) {
    
            __DBGpr_com(" Fit object ");
            __DBGpr_int("  OM_K_MAXINT ",  OM_K_MAXINT);


            if( me->fit3DObject ) { /* fit vddrw2d object */ 
            
            __DBGpr_com(" Fit vddrw2d object ");
            __DBGpr_obj(" itemId ", me->items[i].itemId);

            found = 0;
            for( index = 0 ; index < OM_K_MAXINT && !found ; index = index+1 ){

               status = om$get_objid_at_index(objid = me->items[i].itemId.objid,
                                    osnum = me->items[i].itemId.osnum,
                                    index = index,
                                    p_chanselect = &ND_father,
                                    objidaddr = &part.objid,
                                    osnumaddr = &part.osnum);
               if(!(status&1)) break;

               __DBGpr_obj( " Part object in VDitem father channal", part);

               status = om$get_classid(objid = part.objid,
                                       osnum = part.osnum,
                                       p_classid = &obj_class);
               if(!(status&1)) continue;

               __DBGpr_int( " obj_class", obj_class);

               
               if ( om$is_ancestry_valid(subclassid = obj_class,
                                       superclassid = OPP_ACpretendin_class_id) 
                     != OM_S_SUCCESS &&
                    om$is_ancestry_valid(subclassid = obj_class,
                                       superclassid = OPP_ASsourcein_class_id) 
                     != OM_S_SUCCESS )
                             continue;

               status = om$send( msg = message NDnode.ASreturn_go( &part1,
                                                &modEnvObj.md_env.matrix_type,
                                                modEnvObj.md_env.matrix ),
                                targetid= part.objid,
                                targetos= part.osnum,
                                senderid = NULL_OBJID);

               if( !(status & 1) ) break;

               __DBGpr_obj( " Part object in ACpretendin ", part1);
 
                /*
                 * Special case to handle VRCorrection/VRComponent objects
                 * properly . First get the owner of the VRComponent ==>> i
                 * VRCorrection ...
                 */

               status = VDitem_VRCorr_to_VRComp (&part1);

               /*
                * Get the ACpretendin's / ASsourcein's on the notification
                * channel Both are subclassed from NDnodein
                */

               NbPrtnd = 0;

               status = VDGetGridsFromChan_of_Class ( &msg, part1,
                                             &AS_notification,
                                             -OPP_NDnodein_class_id
                                               /*OPP_ACpretendin_class_id*/,
                                             &NbPrtnd, &Prtnd );

               if( !(status & msg & 1)) continue;

               __DBGpr_int( " NbPrtnd ", NbPrtnd );

               for ( i1 = 0; i1 < NbPrtnd; i1++ ) {

                    NbDrw2d = 0;

                    status = VDGetGridsFromChan_of_Class ( &msg, Prtnd[i1],
                                            &to_child,
                                            OPP_VDdrw2d_class_id,
                                            &NbDrw2d, &Drw2d);

                    if( !(status & msg & 1)) continue;

                    __DBGpr_int( " NbDrw2d ", NbDrw2d);

                    /* get env of Drw2d */

                    for ( i0 = 0; i0 < NbDrw2d; i0++ ) {

                      status =
                      _VD_SEND_OBJN(   Drw2d[i0],
                          NDmacro.ACreturn_foot(
                                                &msg,
                                                "",
                                                &Drw2d[i0],
                                                &modEnvObj.md_env.matrix_type,
                                                modEnvObj.md_env.matrix ));

                      if( !(status&msg&1) ) continue ;

                      __DBGpr_mat(" matrix", modEnvObj.md_env.matrix);
                      __DBGpr_int(" matrix type", modEnvObj.md_env.matrix_type);
                      __DBGpr_obj(" Drw2d", Drw2d[i0]);

                      modEnvObj.md_id.osnum = Drw2d[i0].osnum;

                      found = 1;
         
                      parent.obj_id   = Drw2d[i0];
               
                      parent.mod_env  = modEnvObj;
           
                      break;
  
                    }  /* for i0 */

                    _FREE( Drw2d );
                     Drw2d = NULL;
                    
                    if( found ) break;
                }  /* for i1 */
               
                _FREE( Prtnd );
                Prtnd = NULL;

             }  /* for index */
               if( !found ) 
               FIfld_set_text( VD_FP, 10, 0, 0, "No VDdrw2d Objects", FALSE);
          }
          else { /* fit 3d object */ 
   
            __DBGpr_com(" Fit 3d object ");
	    
            objSrc.objid = NULL_OBJID ;
	    status =
	    _VD_SEND_OBJ(	me->items[i].itemId,
				NDnode.NDget_objects(	ND_ROOT,
							&objSrc,
							1, NULL,
							DIM_ROOT_LOC,
							DIM_ROOT_LOC,
							&count));
	    if( ( !(status&1) ) || ( objSrc.objid == NULL_OBJID )){
			goto quit ;
	    }
            __DBGpr_obj(" itemId ", me->items[i].itemId);
            __DBGpr_obj(" root of itemId: objSrc ", objSrc);

	    /*
	     * Check if the parent is the source objects.
	     */
	    if( vd_$is_ancestry_valid(object = &objSrc,
				      classid = OPP_DMsrc_class_id )){
	        /*
	         * get ACpretend
	         */
		    found = 0 ;
		    for( index=0; index<10 && !found ; index++){

  			status =
			om$get_objid_at_index(	objid = objSrc.objid,
                      				osnum = objSrc.osnum,
                                 		index = index,
                                 		p_chanselect = &ND_father,
                                 		objidaddr = &obj.objid,
                                 		osnumaddr = &obj.osnum);
			if(!(status&1)) break; /* nothing left */

                        __DBGpr_obj(" father of objSrc:obj", obj);

                        status =
			_VD_SEND_OBJ(	obj,
					NDmacro.ACreturn_foot( 
						&msg,
						"",
						&obj1,
						&objEnv.md_env.matrix_type,
						objEnv.md_env.matrix ));
                        if( !(status&msg&1) ) continue ;
                        __DBGpr_obj(" foot of obj:obj1", obj1);

			ASget_as_owner( &obj1, &obj );
                        __DBGpr_obj(" owner of obj1:obj", obj);

                        status =
			_VD_SEND_OBJ(	obj,
					NDmacro.ACreturn_foot( 
						&msg,
						"",
						&obj1,
						&objEnv.md_env.matrix_type,
						objEnv.md_env.matrix ));
                        if( !(status&msg&1) ) continue ;
                        __DBGpr_obj(" foot of obj:obj1", obj1);

			parent.obj_id	= obj1 ;
			parent.mod_env	= objEnv ;

			found = 1;

                /*
                 * test on objects for macro src_obj.
                 */
			macro.objid = NULL_OBJID ;
			status =
			om$send(msg = message ACcpx.find_macro(&macro),
                       		targetid = obj1.objid,
                      		targetos = obj1.osnum );

			if( macro.objid == NULL_OBJID ) break ;
                        __DBGpr_obj(" macro of obj1:", macro);

	                status =
       		        om$send(msg = message ACcpx_defn.ACgive_name( &c ),
       		                 targetid = macro.objid,
       		                 targetos = macro.osnum);
       		        as$status();
                        __DBGpr_str(" macro name", c);

			if( strcmp( c, "src_obj" ) == 0 ){

				/*
				 * Get the parent object. (index=0 );
				 */
				status =
				_VD_SEND_OBJ( obj1,
					NDnode.NDget_objects(	ND_ROOT,
								&obj2,
								1, NULL,
								0,0,&count ));
                                __DBGpr_obj(" root of obj1 -- obj2", obj2);
                       		status =
				_VD_SEND_OBJ(	obj2,
					NDmacro.ACreturn_foot( 
						&msg,
						"",
						&obj1,
						&objEnv.md_env.matrix_type,
						objEnv.md_env.matrix ));
                       		 if( !(status & 1) ) continue ;
                                __DBGpr_obj(" foot of obj2 -- obj1", obj1);

/* test 1/4/96 for TR179600006 */
                       		status =
				_VD_SEND_OBJ(	obj1,
					NDmacro.ACreturn_foot( 
						&msg,
						"",
						&obj1,
						&objEnv.md_env.matrix_type,
						objEnv.md_env.matrix ));

                       	        if( !(status & 1) ) continue ;
                                __DBGpr_obj(" foot of obj1 -- obj1", obj1);
/* test 1/4/96 */
                                parent.obj_id	= obj1 ;
				parent.mod_env	= objEnv ;
                                __DBGpr_mat(" matrix ", objEnv.md_env.matrix);
                                __DBGpr_int(" matrix type ", 
                                                   objEnv.md_env.matrix_type);
			} /* if src-obj*/
		    } /* for index ... */
              } /* DMsrc */
            } 
            if( found ) {
                __DBGpr_com( "found 0");
		parent.mod_env.md_id.osnum = parent.obj_id.osnum ;
		status =
		ex$get_modid(	mod_osnum = parent.mod_env.md_id.osnum,
				mod_id	  = &parent.mod_env.md_id.objid) ;

                /* get the window if needed */

                __DBGpr_com( "found 1");
                if( me->windowId.objid == NULL_OBJID )
                {
                    status = om$send( msg		= message VDCmdRvItem.
							getWindow( &msg ),
				      mode		= OM_e_wrt_message,
				      targetid	= my_id );
                }
                __DBGpr_obj(" me->windowId ", me->windowId);
                __DBGpr_obj(" parent.obj_id", parent.obj_id); 
                __DBGpr_obj(" parent.mod_env.md_id", 
                              parent.mod_env.md_id); 
                __DBGpr_com( "found 2");
                status = vd$vw_fit_object(  object      = &parent.obj_id,
                                            md_env      = &parent.mod_env,
                                            ggid        = &me->windowId,
					    factor	= me->fitRatio,
                                            num_ggid    = 1 );
                as$status();
                __DBGpr_com( "found 3");
            } /* if found */
        } /* If me->fitObjOpt */

        /* now highlight item number and object */

        VDdisplayItemsBln( &msg, &me->items[i].itemId.osnum,
			    1, &me->items[i].itemId.objid );
      } /* !me->ballonTog */ 
      else {    /* for me->ballonTog = on( without ballon) */

         __DBGpr_com(" highlight one without ballon ");

         if( me->curTblInSet ) { /* look at table in set */ 

           __DBGpr_com(" look at table in set ");

           index = me->tableNoBln[me->curTblIndex].startIndex;
           nbItems = me->tableNoBln[me->curTblIndex].nbItems;

           found = 0;
           i = index + row;
           if( i < index + nbItems) 
                 found = 1; 
           if( !found )
            goto quit;

           /* for reduced list case */

           buf = &buffer[1];
           len = strlen( buf);
           buf[len-1] = '\0';
           __DBGpr_str(" buf", buf);

           for ( ir = index; ir < index + nbItems; ir++ ) {

              if (!strcmp(buf, me->objItmNoBln[ir].itemStr)) {
                   i = ir;
                   break;
              }
           }


           if( me->fitObjOpt ) {
           
            if( !me->fit3DObject ) {  /* display 3D object */

                /* get current module env */
                __DBGpr_com(" Fit 3d object ");

		modEnvObj.md_id.objid = NULL_OBJID;
                size = sizeof( struct GRmd_env );
                status = gr$get_module_env( msg     = &msg,
                                            sizbuf  = &size,
                                            buffer  = &modEnvObj,
                                            nret    = &nret );
                as$status( action = GOTO_VALUE, value = quit );

                /* get md_env for object */
                __DBGpr_obj(" object with item id ", me->objItmNoBln[i].itemId);
                status =
                _VD_SEND_OBJ(   me->objItmNoBln[i].itemId,
                                NDmacro.ACreturn_foot(
                                                &msg,
                                                "",
                                                &obj1,
                                                &modEnvObj.md_env.matrix_type,
                                                modEnvObj.md_env.matrix ));

                        __DBGpr_obj(" obj1 ", obj1);
                        __DBGpr_mat(" matrix ", objEnv.md_env.matrix);
                        __DBGpr_int(" matrix type ",
                                                   objEnv.md_env.matrix_type);
                if( !(status &msg & 1) )
                       found = 0;
                else {
/*
                       status =
                       _VD_SEND_OBJ(   obj1,
                                NDmacro.ACreturn_foot(
                                                &msg,
                                                "",
                                                &obj1,
                                                &modEnvObj.md_env.matrix_type,
                                                modEnvObj.md_env.matrix ));

                        __DBGpr_obj(" obj1 ", obj1);
                        __DBGpr_mat(" matrix ", objEnv.md_env.matrix);
                        __DBGpr_int(" matrix type ",
                                                   objEnv.md_env.matrix_type);
 */  
                        modEnvObj.md_id.osnum =  
                            me->objItmNoBln[i].itemId.osnum;
                        found = 1;
                }
                if(found) {
                   modEnvObj.md_id.objid = NULL_OBJID;

                   /* get the window if needed */
                   if( me->windowId.objid == NULL_OBJID ) {
                    status = om$send( msg               = message VDCmdRvItem.
                                                          getWindow( &msg ),
                                      mode              = OM_e_wrt_message,
                                      targetid  = my_id );
                   }
                   status = vd$vw_fit_object(
                            object      = &me->objItmNoBln[i].itemId,
                            md_env      = &modEnvObj,
                            ggid        = &me->windowId,
                            factor      = me->fitRatio,
                            num_ggid    = 1 );
                   as$status();
                } /* if found */
              }
              else { /* fit VDraw2d object */

               __DBGpr_com(" Fit VDdrw2d object in set  ");

                status = om$make_chanselect(channame = "NDchildren.children",
                                            p_chanselect  = &to_child);


                ModelId = me->objItmNoBln[i].itemId; 
                __DBGpr_obj(" Fit model id ", ModelId);
                status = VDitem_VRCorr_to_VRComp (&ModelId);
                __DBGpr_obj("after VDitem_VRCorr_to_VRComp model id ", ModelId);

                /*
                 * Get the ACpretendin's / ASsourcein's on the notification 
                 * channel.  Both are subclassed from NDnodein
                 */

               NbPrtnd = 0;

     	       status = VDGetGridsFromChan_of_Class ( &msg, ModelId,
                                             &AS_notification,
                                             -OPP_NDnodein_class_id
                                               /*OPP_ACpretendin_class_id*/,
                                             &NbPrtnd, &Prtnd );
	       if( !(status & msg & 1)){
                 FIfld_set_text( VD_FP, 10, 0, 0, "No VDdrw2d Object", FALSE);
                 goto quit;
               }

     	       __DBGpr_int( " NbPrtnd ", NbPrtnd );

               if( !NbPrtnd )
               FIfld_set_text( VD_FP, 10, 0, 0, "No VDdrw2d Object", FALSE);

     	       for ( i1 = 0; i1 < NbPrtnd; i1++ ) {

        	  NbDrw2d = 0;

                  status = VDGetGridsFromChan_of_Class ( &msg, Prtnd[i1],
                                            &to_child,
                                            OPP_VDdrw2d_class_id,
                                            &NbDrw2d, &Drw2d);
                  if( !(status & msg & 1))  continue;

                  __DBGpr_int( " NbDrw2d ", NbDrw2d);

                  for ( i0 = 0; i0 < NbDrw2d; i0++ ) {
 
                  status =
                  _VD_SEND_OBJN(   Drw2d[i0],
                           NDmacro.ACreturn_foot(
                                                &msg,
                                                "",
                                                &Drw2d[i0],
                                                &modEnvObj.md_env.matrix_type,
                                                modEnvObj.md_env.matrix ));

                  if( !(status&msg&1) ) continue ;
                  
                  __DBGpr_mat(" matrix", modEnvObj.md_env.matrix);

                  modEnvObj.md_id.osnum = Drw2d[i0].osnum;
                  modEnvObj.md_id.objid = NULL_OBJID;

                   /* get the window if needed */
                   if( me->windowId.objid == NULL_OBJID ) {
                    status = om$send( msg               = message VDCmdRvItem.
                                                          getWindow( &msg ),
                                      mode              = OM_e_wrt_message,
                                      targetid  = my_id );
                   }
                   status = vd$vw_fit_object(
                            object      = & Drw2d[i0],
                            md_env      = &modEnvObj,
                            ggid        = &me->windowId,
                            factor      = me->fitRatio,
                            num_ggid    = 1 );
                   as$status();
   
                 }  /* for i0 */

           		_FREE( Drw2d );
           		Drw2d = NULL;
              }  /* for i1 */
           	_FREE( Prtnd );
           	Prtnd = NULL;
            }
           } /* me->fitObjOpt */

           /* now highlight item number and object */
           VDdisplayItemsNoBln( &msg, &me->objItmNoBln[i].itemId.osnum,
                            1, &me->objItmNoBln[i].itemId.objid );
         }
         else { /* look at table not in set */

           __DBGpr_com(" look at table not in set ");

           index = me->tableNoSet[me->curTblIndex].startIndex;
           nbItems = me->tableNoSet[me->curTblIndex].nbItems;

           found = 0;
           i = index + row;
           if( i < index + nbItems)
                 found = 1;
           if( !found )
            goto quit;

           /* for reduced list case */
           buf = &buffer[1];
           len = strlen( buf);
           buf[len-1] = '\0';
           __DBGpr_str(" buf", buf);

           for ( ir = index; ir < index + nbItems; ir++ ) {

              if (!strcmp(buf, me->objItmNoBlnNoSet[ir].itemStr)) {
                   i = ir;
                   break;
              }
           }

           if( me->fitObjOpt ) {
            
             if( !me->fit3DObject ) {  /* display 3D object */
                /* get current module env */
                __DBGpr_com(" Fit 3d object ");

                modEnvObj.md_id.objid = NULL_OBJID;
                size = sizeof( struct GRmd_env );
                status = gr$get_module_env( msg     = &msg,
                                            sizbuf  = &size,
                                            buffer  = &modEnvObj,
                                            nret    = &nret );
                as$status( action = GOTO_VALUE, value = quit );

                /* get md_env for object */
                status =
                _VD_SEND_OBJ(   me->objItmNoBlnNoSet[i].itemId,
                                NDmacro.ACreturn_foot(
                                                &msg,
                                                "",
                                                &obj1,
                                                &modEnvObj.md_env.matrix_type,
                                                modEnvObj.md_env.matrix ));

                if( !(status &msg & 1) )
                       found = 0;
                else {
                        modEnvObj.md_id.osnum =
                            me->objItmNoBlnNoSet[i].itemId.osnum;
                        found = 1;
                }
                if(found) {
                   modEnvObj.md_id.objid = NULL_OBJID;

                   /* get the window if needed */
                   if( me->windowId.objid == NULL_OBJID ) {
                    status = om$send( msg               = message VDCmdRvItem.
                                                          getWindow( &msg ),
                                      mode              = OM_e_wrt_message,
                                      targetid  = my_id );
                   }
                   status = vd$vw_fit_object(
                            object      = &me->objItmNoBlnNoSet[i].itemId,
                            md_env      = &modEnvObj,
                            ggid        = &me->windowId,
                            factor      = me->fitRatio,
                            num_ggid    = 1 );
                   as$status();
                } /* if found */
              }
              else {     /* fit VDraw2d objects */

     		/*
                 * Special case to handle VRCorrection/VRComponent objects 
                 * properly . First get the owner of the VRComponent ==>> i
                 * VRCorrection ...
                 */

               ModelId = me->objItmNoBlnNoSet[i].itemId;
               __DBGpr_obj(" model id in set ", ModelId);

               status = VDitem_VRCorr_to_VRComp (&ModelId);
               __DBGpr_obj(" after VDitem_VRCorr_to_VRCom pmodel id ", ModelId);

               /*
                * Get the ACpretendin's / ASsourcein's on the notification 
                * channel Both are subclassed from NDnodein
                */

     	       NbPrtnd = 0;

               status = VDGetGridsFromChan_of_Class ( &msg, ModelId,
                                             &AS_notification,
                                             -OPP_NDnodein_class_id
                                               /*OPP_ACpretendin_class_id*/,
                                             &NbPrtnd, &Prtnd );


                if( !(status & msg & 1)) {
                      FIfld_set_text( VD_FP, 10,0,0,"No VDdrw2d Object",FALSE);
                        goto quit;
                }
                __DBGpr_int( " NbPrtnd ", NbPrtnd );

                if( !NbPrtnd )
                      FIfld_set_text( VD_FP, 10,0,0,"No VDdrw2d Object",FALSE);


               status = om$make_chanselect(channame = "NDchildren.children",
                                            p_chanselect  = &to_child);


               for ( i1 = 0; i1 < NbPrtnd; i1++ ) {

                  NbDrw2d = 0;

                  status = VDGetGridsFromChan_of_Class ( &msg, Prtnd[i1],
                                            &to_child,
                                            OPP_VDdrw2d_class_id,
                                            &NbDrw2d, &Drw2d);
                  if( !(status & msg & 1)) continue;

                  __DBGpr_int( " NbDrw2d ", NbDrw2d);
                
                  if( !NbDrw2d ) 
                      FIfld_set_text( VD_FP, 10,0,0,"No VDdrw2d Object",FALSE);

                  /* get env of Drw2d */
                  for ( i0 = 0; i0 < NbDrw2d; i0++ ) {

                  status =
                  _VD_SEND_OBJN(   Drw2d[i0],
                           NDmacro.ACreturn_foot(
                                                &msg,
                                               "",
                                                &Drw2d[i0],
                                                &modEnvObj.md_env.matrix_type,
                                                modEnvObj.md_env.matrix ));
                 if( !(status&msg&1) ) continue ;

                  __DBGpr_mat(" matrix", modEnvObj.md_env.matrix);

                  modEnvObj.md_id.osnum = Drw2d[i0].osnum;
                  modEnvObj.md_id.objid = NULL_OBJID;

                   /* get the window if needed */
                   if( me->windowId.objid == NULL_OBJID ) {
                    status = om$send( msg               = message VDCmdRvItem.
                                                          getWindow( &msg ),
                                      mode              = OM_e_wrt_message,
                                      targetid  = my_id );
                   }
                   status = vd$vw_fit_object(
                            object      = & Drw2d[i0],
                            md_env      = &modEnvObj,
                            ggid        = &me->windowId,
                            factor      = me->fitRatio,
                            num_ggid    = 1 );
                   as$status();

                 }  /* for i0 */
                        _FREE( Drw2d );
                        Drw2d = NULL;
              }  /* for i1 */
                _FREE( Prtnd );
                Prtnd = NULL;
            }
           } /* me->fitObjOpt */

           /* now highlight item number and object */
           VDdisplayItemsNoBln( &msg, &me->objItmNoBlnNoSet[i].itemId.osnum,
                            1, &me->objItmNoBlnNoSet[i].itemId.objid );
         }
      } /* else  without ballon */
    } /* me->highlightOpt != 0 : high light one */
    else {       /* highlight all the numbers */  
     
     if( !me->ballonTog ) { /* with  ballon */
    
        __DBGpr_com(" highlight all with ballon ");

        nb = me->tables[me->curTblIndex].nbItems;
        index = me->tables[me->curTblIndex].startIndex;

        if(!nb) { 
              FIfld_set_text( VD_FP, 10, 0, 0, "Can not find objects", FALSE);
              goto quit;
        }      

        /* set up list of item ids */
        itemIds = _MALLOC(nb, GRobjid );
        if( !itemIds )
        {
            printf("\nERROR : Dynamic Allocation\n");
            goto quit;
        }
        itemOs = _MALLOC(nb,  OMuword );
        if( !itemOs )
        {
            printf("\nERROR : Dynamic Allocation\n");
            goto quit;
        }
        
        nbItems = 0;
        for( i = index ; i < nb+index ; i++ )
        {
            if( !ASmatchRE( me->itemRegExpr, me->items[i].itemStr ) )
                continue;
            itemIds[nbItems] = me->items[i].itemId.objid;
            itemOs[nbItems]  = me->items[i].itemId.osnum;

            __DBGpr_obj("items object", me->items[i].itemId);

            nbItems++;
        }

        VDdisplayItemsBln( &msg,  itemOs, nbItems, itemIds );

      } /* if( !me->ballonTog ) */
      else { /* without ballon  */

       if( me->curTblInSet) {  /* look at table in the set */

        __DBGpr_com(" highlight all with ballon in tableNoBln ");

        __DBGpr_int(" curTblIndex", me->curTblIndex);

        nb = me->tableNoBln[me->curTblIndex].nbItems;
        __DBGpr_int(" nbItems ", nb);

        index = me->tableNoBln[me->curTblIndex].startIndex;
        __DBGpr_int(" startIndex ", index);

        if(!nb) {
              FIfld_set_text( VD_FP, 10, 0, 0, "Can not find objects", FALSE);
              goto quit;
        }

        /* set up list of item ids */
        itemIds = _MALLOC(nb, GRobjid );
        if( !itemIds )
        {
            printf("\nERROR : Dynamic Allocation\n");
            goto quit;
        }
        itemOs = _MALLOC( nb,  OMuword );
        if( !itemOs )
        {
            printf("\nERROR : Dynamic Allocation\n");
            goto quit;
        }

        nbItems = 0;
        for( i = index ; i < nb+index ; i++ )
        {
            if( !ASmatchRE( me->itemRegExpr, me->objItmNoBln[i].itemStr ) )
                continue;
        
            __DBGpr_str(" itemStr", me->objItmNoBln[i].itemStr);
            itemIds[nbItems] = me->objItmNoBln[i].itemId.objid;
            itemOs[nbItems] = me->objItmNoBln[i].itemId.osnum;

            __DBGpr_obj( "objItmNoBlnNoSet", me->objItmNoBln[i].itemId);

            nbItems++;
        }
        __DBGpr_int(" nbItems", nbItems);

        VDdisplayItemsNoBln( &msg, itemOs, nbItems, itemIds );
       }
       else { /* look at table not in the set */

        __DBGpr_com(" highlight all with ballon in tableNoSet ");

        __DBGpr_int(" curTblIndex", me->curTblIndex);
        nb = me->tableNoSet[me->curTblIndex].nbItems;

        __DBGpr_int(" nbItems ", nb);
        index = me->tableNoSet[me->curTblIndex].startIndex;

        __DBGpr_int(" startIndex ", index);
        if(!nb) {
              FIfld_set_text( VD_FP, 10, 0, 0, "Can not find objects", FALSE);
              goto quit;
        }

        /* set up list of item ids */
        itemIds = _MALLOC(nb,  GRobjid );
        if( !itemIds )
        {
            printf("\nERROR : Dynamic Allocation\n");
            goto quit;
        }
        itemOs = _MALLOC( nb,  OMuword );
        if( !itemOs )
        {
            printf("\nERROR : Dynamic Allocation\n");
            goto quit;
        }

        nbItems = 0;
        for( i = index ; i < nb+index ; i++ )
        {
            if( !ASmatchRE( me->itemRegExpr, me->objItmNoBlnNoSet[i].itemStr ) )
                continue;

            itemIds[nbItems] = me->objItmNoBlnNoSet[i].itemId.objid;
            itemOs[nbItems] = me->objItmNoBlnNoSet[i].itemId.osnum;

            __DBGpr_obj( "objItmNoBlnNoSet", me->objItmNoBlnNoSet[i].itemId);
            nbItems++;
        }

        __DBGpr_int(" nbItems", nbItems);

        VDdisplayItemsNoBln( &msg, itemOs, nbItems, itemIds );
       }
    } /* else   without ballon  */
  } /* else : highlight all the numbers */
            
quit :
    _FREE( itemIds );
    _FREE( itemOs );
    _FREE( Drw2d );
    _FREE( Prtnd );
    End
    return OM_S_SUCCESS;
} /* VDupdateHighlight */


/*+me
 -------------------------------------------------------------------------
  Public Message VDupdatePfxList

  Abstract
        Updates the associative list of prefixes in the form.  
	These are the list of search strings for item numbers.

  Arguments
        long    *sts           O       Completion code

  Status
      status    OM_S_SUCCESS    if success
                OM_E_NODYNMEM   no dynamic memory
                OW_W_ABORT      some other error

 -------------------------------------------------------------------------
-me*/

method VDupdatePfxList( long *sts )
{

    IGRint		i,
			nret,
			nrows,
			size,
			nbSets;

    IGRlong		msg,
			status = OM_S_SUCCESS;

    IGRchar		*tblName = NULL;

    OM_S_OBJECT_LINKAGE	*setList = NULL;

    struct GRid		mgrId;
    struct GRmd_env	mod_env;

    *sts = MSSUCC;

    /* initialize list */

    FIfld_set_list_num_rows( VD_FP, VD_ITM_EXPR_FLD, 0, 1 );
    VDfld_set_list_text( VD_FP, VD_ITM_EXPR_FLD, 0, 0, 
				(unsigned char *)"*", FALSE );

    nrows = 1;

    /*
     * get the item manager id
     */

    /* get current module */

    size = sizeof( struct GRmd_env );

    status = gr$get_module_env( msg     = &msg,
                                sizbuf  = &size,
                                buffer  = &mod_env,
                                nret    = &nret );
    as$status( action = GOTO_VALUE, value = quit );

    /* get item manager */

    status = ex$get_super(      mod_id          = mod_env.md_id.objid,
                                mod_osnum       = mod_env.md_id.osnum,
                                super_name      = "ItemMgr",
                                create          = 0,
                                super_class     = "VDitemMgr",
                                super_id        = &mgrId.objid,
                                super_osnum     = &mgrId.osnum );
    as$status( action = GOTO_VALUE, value = quit );

#ifdef DEBUG
    printf("\nItem manager id = %d,%d", mgrId.objid, mgrId.osnum );
#endif

    /*
     * get all the VDitemSet objects connected to the manager
     */

    status = om$get_channel_count( objid        = mgrId.objid,
                                   osnum        = mgrId.osnum,
                                   p_chanselect = &AS_to_comp,
                                   count        = (OMuint *) &nbSets );

    as$status( action = GOTO_VALUE, value = quit );

#ifdef DEBUG
    printf("\nNo of objects on channel : %d", nbSets );
#endif

/*
    size = sizeof( OM_S_OBJECT_LINKAGE ) * nbSets;
    setList = ( OM_S_OBJECT_LINKAGE *)om$malloc( size = size );
*/
    setList = _MALLOC(nbSets, OM_S_OBJECT_LINKAGE );
    if( !setList )
    {
        printf( "\nERROR : Dynamic Allocation\n");
        status = OM_E_NODYNMEM;
        goto quit;
    }

    status = om$get_channel_objects( objid              = mgrId.objid,
                                     osnum              = mgrId.osnum,
                                     p_chanselect       = &AS_to_comp,
                                     size               = nbSets,
                                     list               = setList,
                                     count              = (OMuint *) &nbSets );

    as$status( action = GOTO_VALUE, value = quit );

    /* for each set, if tblName matches, add the prefix to the list */

    for( i = 0 ; i < nbSets ; i++ )
    {
        /* get the table name, and prefix */

        status = om$send( msg           = message VDitemSet.VDgetSetInfo(
                                                                &msg,
                                                                &tblName ),
                          targetid      = setList[i].S_objid,
                          targetos      = setList[i].osnum );
        as$status();

#ifdef DEBUG
    printf("\ntblName = %s", tblName );
#endif

        if( !strcmp( me->curTblName, tblName ) )
        {
            /* must add this prefix to the list */

            FIfld_set_list_num_rows( VD_FP, VD_ITM_EXPR_FLD, 0, nrows+1 );

//            VDfld_set_list_text( VD_FP, VD_ITM_EXPR_FLD, nrows, 0, 
//					(unsigned char *)pfxBuf, FALSE );
            
            nrows++;
        }
        
        _FREE( tblName );
        tblName = NULL;
    }


    goto quit;

quit :

    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDupdateItemList

  Abstract
	Updates the list of item numbers in the instance data and 
	in the form

  Arguments
        long    *sts           O       Completion code

  Status
      status    OM_S_SUCCESS    

  Return Code
      sts       MSSUCC         

 -------------------------------------------------------------------------
-me*/

method VDupdateItemList( long *sts )
{
    IGRint		i,num,
			nrows = 0,
			nbItems,
			index;

    IGRlong		status = OM_S_SUCCESS;
    IGRchar             buf[100]; 

    SetProc( VDCmdRvItem.VDupdateItemList); Begin
    *sts = MSSUCC;

    __DBGpr_str( " me->curTblName", me->curTblName );

    /* for empty name */
    if(me->curTblName[0]  == '\0') {  /* empty name */

      FIfld_get_num_rows( VD_FP, VD_ITM_LIST_FLD, &num);

      for ( i = 0; i < num; i++ ) {
        FIfld_set_text( VD_FP, VD_ITM_LIST_FLD, i, 0, "", FALSE);
      }   

      FIfld_set_num_rows( VD_FP, VD_ITM_LIST_FLD, 0 );

      goto wrapup;
    }

    /* with bollon */ 
    if(me->ballonTog == FALSE) {  

      index = me->tables[me->curTblIndex].startIndex;

      nbItems = me->tables[me->curTblIndex].nbItems;

      __DBGpr_int( " start index in tables :", index );
      __DBGpr_int( " # of items in tables:", nbItems);
      __DBGpr_str( " itemRegExpr :", me->itemRegExpr);

      FIfld_set_num_rows( VD_FP, VD_ITM_LIST_FLD, 0 );

      for( i = index ; i < nbItems+index ; i++ ) {

        __DBGpr_str( " item str :",  me->items[i].itemStr);

        if( !ASmatchRE( me->itemRegExpr, me->items[i].itemStr ) )
            continue;

        buf[0] = '\0';

        strcat(buf,"'");
        strcat(buf,me->items[i].itemStr);
        strcat(buf,"'");

        FIfld_set_num_rows( VD_FP, VD_ITM_LIST_FLD, nrows+1 );
        FIfld_set_text( VD_FP, VD_ITM_LIST_FLD, nrows, 0, buf, FALSE);

        nrows++;
      }
    } 
    else { /* for objects with itemnumber but no ballon */
    
     if ( me->curTblInSet ) { /* look at table tableNoBln ( in set ) */  

      index = me->tableNoBln[me->curTblIndex].startIndex;

      nbItems = me->tableNoBln[me->curTblIndex].nbItems;

      __DBGpr_int( " start index in tableNoBln :", index );
      __DBGpr_int( " # of items in tableNoBln:", nbItems);
      __DBGpr_str( " itemRegExpr :", me->itemRegExpr);

      FIfld_set_num_rows( VD_FP, VD_ITM_LIST_FLD, 0 );

      for( i = index ; i < nbItems+index ; i++ ) {

        /* for same item number we may have several objects, 
         * list it all for time being
         */
        __DBGpr_str( " item str :",  me->objItmNoBln[i].itemStr);

        if( !ASmatchRE( me->itemRegExpr, me->objItmNoBln[i].itemStr ) )
            continue;

        buf[0] = '\0';

        strcat(buf,"'");
        strcat(buf,me->objItmNoBln[i].itemStr);
        strcat(buf,"'");

        FIfld_set_num_rows( VD_FP, VD_ITM_LIST_FLD, nrows+1 );
        FIfld_set_text( VD_FP, VD_ITM_LIST_FLD, nrows, 0, buf, FALSE);

        nrows++;
      }
     }
     else { /* look at table tableNoSet */

      index = me->tableNoSet[me->curTblIndex].startIndex;

      nbItems = me->tableNoSet[me->curTblIndex].nbItems;

      __DBGpr_int( " start index in tableNoSet :", index );

      __DBGpr_int( " # of items in tableNoSet :", nbItems);

      __DBGpr_str( " itemRegExpr :", me->itemRegExpr);


      FIfld_set_num_rows( VD_FP, VD_ITM_LIST_FLD, 0 );

      for( i = index ; i < nbItems+index ; i++ ) {
        /* for same item number we may have several objects,
         * list it all for time being
         */

        __DBGpr_str( " item str :",  me->objItmNoBlnNoSet[i].itemStr);

        if( !ASmatchRE( me->itemRegExpr, me->objItmNoBlnNoSet[i].itemStr ) )
            continue;
        buf[0] = '\0';

        strcat(buf,"'");
        strcat(buf,me->objItmNoBlnNoSet[i].itemStr);
        strcat(buf,"'");

        FIfld_set_num_rows( VD_FP, VD_ITM_LIST_FLD, nrows+1 );
        FIfld_set_text( VD_FP, VD_ITM_LIST_FLD, nrows, 0, buf, FALSE);

        nrows++;
      }
    }
  }
wrapup:
  End
  return status;
}

end implementation VDCmdRvItem;
