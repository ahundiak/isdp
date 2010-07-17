/* $Id: VSjnsdlfunk.I,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsjoint/VSjnsdlfunk.I
 *
 * Description: Implementation of Joint related STRDEL functions.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnsdlfunk.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  2000/01/19  22:25:18  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/12/26  10:44:20  pinnacle
# Created: vsjoint/VSjnsdlfunk.I by rchennup for struct
#
 * Revision 1.1  1997/11/19  10:14:20  pinnacle
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/26/97	Rama Rao	File Creation
 *
 ***************************************************************************/

class implementation VSfeature;

#include <string.h>
#include "ACrg_collect.h"
#include "nddef.h"
#include "macro.h"
#include "vsjoint.h"
#include "vsiomacros.h"
#include "vsjntmacros.h"
#include "vsdrwapi.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"

#define vsDEBUG    1
#define vserrDEBUG 1

extern  GRclassid	OPP_VSplate_class_id;

from	VSplate		import	VSgetSupports;
from	ACcpx_defn	import	ACgive_feet_desc;
from    VSjoint		import  VScstPlPlJoint, VScstPlBmJoint, VScstBmBmJoint ;
from	ACpretend	import	ACgive_downscan;
from	ACrg_collect	import	ACget_named_attribute,ACmod_list_attribute;

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, get_element ) {

     IGRint	elem_num;
     IGRlong 	msg=xfSUCCESS;

	SetProc( VSdrwFUNCTIONget_element ); Begin

        res->type       = VS_object ;

	CHECK_ARGCOUNT( 1 )

	elem_num = VSdrwIntVal( &arglist->arg ) ;
	if ( elem_num > 2 )  return xfFAILURE;

	res->_oval.obj_id  = inp->toBeDrawn.elmList[elem_num-1];
	res->_oval.mod_env = *inp->drwInfo.drwEnv;

	End
	return msg ? xfSUCCESS : xfFAILURE ;
}

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_same_object ) {

   struct GRobj_env elem1, elem2;

	SetProc( VSdrwFUNCTIONis_elem_connected ); Begin

        res->type       = VS_int ;
	res->_ival 	= 0;

	elem1 = arglist->arg.v.oval;
	elem2 = arglist->next->arg.v.oval;

	if( elem1._objid == elem2._objid &&
	    elem1._osnum == elem2._osnum    )
	{
	   res->_ival = 1;
	}

	End
	return xfSUCCESS;
}

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_elem_connected ) {
	
     IGRint		i, j, nb_fts;
     IGRlong		sts, msg=xfSUCCESS;
     IGRchar		ft_name[10];
     struct GRid	srf_id, macro_id, feat_list[2];
     struct GRobj_env 	elem, *ft_objs=NULL, cons_plate, plate;

	SetProc( VSdrwFUNCTIONis_elem_connected ); Begin

        res->type       = VS_int ;
	res->_ival 	= 0;

	elem = arglist->arg.v.oval;

	__DBGpr_obj( " Input Element ", elem.obj_id );

        if( vs$is_ancestry_valid ( object  = &elem.obj_id,
                                   classid = OPP_VSplate_class_id ) ) {

   	   __DBGpr_com(" Input element is a Plate class");

       	   sts = om$send(  msg      = message NDnode.NDget_objects( 
					ND_ROOT, &srf_id, 1, NULL,
						0, 0, &i ),
                         senderid = NULL_OBJID,
                         targetid = elem._objid,
                         targetos = elem._osnum );
        	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

           sts = om$send(  msg      = message NDnode.NDget_objects( 
						ND_ROOT, &macro_id, 1, NULL,
						0, 0, &i ),
                         senderid = NULL_OBJID,
                         targetid = srf_id.objid,
                         targetos = srf_id.osnum );
           __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );
	   __DBGpr_obj( " Macro Id ", macro_id );

           sts = om$send(  msg      = message NDnode.NDget_objects( 
						ND_ROOT, feat_list, 2, NULL,
						0, 2, &i ),
                         senderid = NULL_OBJID,
                         targetid = macro_id.objid,
                         targetos = macro_id.osnum );
           __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	   for( i=0; i<2; ++i )
	   {
		cons_plate.obj_id = feat_list[i];

		VDatGetConsumingChild( &cons_plate, &plate );
		
		feat_list[i] = plate.obj_id;

		for( j=0; j<2; ++j )
		{
		   if( feat_list[i].objid == inp->toBeDrawn.elmList[j].objid 
		    && feat_list[i].osnum == inp->toBeDrawn.elmList[j].osnum )
		   break;
		}
	        if( j!=2 ) break;
	   }

	   if( i==2 ) goto wrapup;

	   sprintf( ft_name, "jnt%d*", i );
	   __DBGpr_str( " Foot Name ", ft_name );

	   sts = VD_findMatchFtNameSlSfInMacro( &msg, &macro_id,
			inp->drwInfo.drwEnv, ft_name, TRUE,
			&ft_objs, &nb_fts );
	   if( nb_fts ) res->_ival = 1;
	}
wrapup:
	End
	return msg ? xfSUCCESS : xfFAILURE ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VS, joint_geom ) {
        long                    sts, msg ;      /* OM return code       */
	struct GRid		joint_id, OutPut;
        struct GRvg_construct   cst ;           /* My construction list */
        struct GRobj_env        features[3] ;   /* Virtual parents      */
        int                     i,              /* Loop index           */
				*purpose, weldSide, jType;
        VSdspRep                myRep ;         /* My representation    */
        struct GRsymbology      mySymb ;        /* My symbology         */
        VSpartAttr              part ;
        VSjointAttr             jnAttr ;
	const char              *type = xData->parsedElmDesc ;

	joint_id = inp->toBeDrawn.elmList[inp->toBeDrawn.elmCount-1];

	purpose = (IGRint *) inp->appData;

        /*
         * Fill construction list.
         */
        sts = om$send(  msg     = message GRvg.GRgetsymb( &msg, &mySymb ),
                        mode    = *purpose & VS_K_InitialPlacement
                                        ? OM_e_wrt_message
                                        : OM_e_wrt_object,
			senderid = joint_id.objid,
                        targetid = joint_id.objid,
			targetos = joint_id.osnum   );
        __CheckRC( sts, msg, "GRvg.GRgetsymb", wrapup ) ;

        vs$fill_cnst_list(      Msg		= &msg,
				Env_info        = inp->drwInfo.drwEnv,
                                Display         = &mySymb.display_attr,
                                Level           = mySymb.level,
                                Cnst_list       = cst ) ;

        for( i = 0 ; i < inp->toBeDrawn.elmCount-1 ; i++ ) {
                sts = VSgetVirtualInfo( &msg, inp->toBeDrawn.elmList+i, 
				&features[i].mod_env, &features[i]._grid ) ;
                __CheckRC( sts, msg, "VSgetVirtualInfo", wrapup ) ;
        }

        sts = vs$getJunctionType(       msg             = &msg,
                                        elToJoin1       = &features[0],
                                        elToJoin2       = &features[1],
                                        junctionType    = &jType ) ;
        __CheckRC( sts, msg, "vs$getJunctionType", wrapup ) ;

        sts = om$send(  msg     = message ACncpx.ACget_NV_rep( &myRep ),
			senderid = joint_id.objid,
                        targetid = joint_id.objid,
			targetos = joint_id.osnum );

        part.Iwant = VS_m_All ;
        part.specific = ( void *) &jnAttr ;
        sts = om$send(  msg     = message GRvg.GRgetattr( &msg,
                                                        (char *) &part ),
			senderid = joint_id.objid,
                        targetid = joint_id.objid,
                        targetos = joint_id.osnum );
         __CheckRC( sts, msg, "GRvg.GRgetattr", wrapup ) ;

        weldSide = jnAttr.weldAttr.side ;

        /*
         * Rep needs to be fixed if an expanded macro graph is being computed.
         */
        sts = vs$fixIfNoRep( inRep = myRep, 
			     objid = joint_id.objid,
			     osnum = joint_id.osnum,
			     outRep = &myRep 		) ;

	if(    !strcmp( type, "Joint-Plate-Plate"  ) ) {
                vs$dotsInStsFld() ;
                sts = om$send(  msg     = message VSjoint.VScstPlPlJoint(
                                                                &msg,
                                                                features,
                                                                myRep,
                                                                &cst,
                                                                weldSide,
                                                                &OutPut    ),
			senderid = joint_id.objid,
                        targetid = joint_id.objid,
                        targetos = joint_id.osnum );
                __CheckRC( sts, msg, "VSjoint.VScstPlPlJoint", wrapup ) ;
	}
	else if(    !strcmp( type, "Joint-Plate-Beam"  ) ) {
                vs$dotsInStsFld() ;
                sts = om$send(  msg     = message VSjoint.VScstPlBmJoint(
                                                                &msg,
                                                                features,
                                                                myRep,
                                                                &cst,
                                                                jType,
                                                                weldSide,
                                                                &OutPut   ),
			senderid = joint_id.objid,
                        targetid = joint_id.objid,
                        targetos = joint_id.osnum );
                __CheckRC( sts, msg, "VSjoint.VScstPlBmJoint", wrapup ) ;
	}
	else if(    !strcmp( type, "Joint-Beam-Beam"  ) ) {
                vs$dotsInStsFld() ;
                sts = om$send(  msg     = message VSjoint.VScstBmBmJoint(
                                                                &msg,
                                                                features,
                                                                myRep,
                                                                &cst,
                                                                weldSide,
                                                                &OutPut    ),
			senderid = joint_id.objid,
                        targetid = joint_id.objid,
                        targetos = joint_id.osnum );
                __CheckRC( sts, msg, "VSjoint.VScstBmBmJoint", wrapup ) ;
	}

        res->type          = VS_object ;
	res->_oval.obj_id  = OutPut ;
	res->_oval.mod_env = *(cst.env_info);

wrapup :
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTjoint_geom */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VS, get_conn_geom ) {
	
     IGRint			i, j, idx=0, feet_num,nb_fts;
     IGRlong			sts, msg=xfSUCCESS;
     IGRchar			ft_name[10];
     struct GRid		srf_id, macro_id, mac_def, ft_gr, feat_list[2];
     struct GRobj_env 		elem1, elem2, *ft_objs=NULL, cons_plate, plate;
     struct myfeet		*feet;
     IGRchar			*col_ptr=NULL;
     GRname 		     	name;

	elem1 = arglist->arg.v.oval;
	elem2 = arglist->next->arg.v.oval;

	__DBGpr_obj( " Input Element 1", elem1.obj_id );
	__DBGpr_obj( " Input Element 2", elem2.obj_id );

       	sts = om$send(  msg      = message NDnode.NDget_objects( 
					ND_ROOT, &srf_id, 1, NULL,
					0, 0, &i ),
                         senderid = NULL_OBJID,
                         targetid = elem1._objid,
                         targetos = elem1._osnum );
        __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	sts = om$send(  msg      = message ACpretend.ACgive_downscan( name ),
                         senderid = NULL_OBJID,
                         targetid = srf_id.objid,
                         targetos = srf_id.osnum );
        __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );
        __DBGpr_str( " Downscan Name 1", name );

	col_ptr = (IGRchar *) strchr( name, ':' );
	if( col_ptr ) col_ptr[0] = '\0';
        __DBGpr_str( " Downscan Name 2", name );

        sts = om$send(  msg      = message NDnode.NDget_objects( 
						ND_ROOT, &macro_id, 1, NULL,
						0, 0, &i ),
                         senderid = NULL_OBJID,
                         targetid = srf_id.objid,
                         targetos = srf_id.osnum );
        __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );
	__DBGpr_obj( " Macro Id ", macro_id );

   	sts = om$send( msg = message ACcpx.find_macro(&mac_def),
                         senderid = NULL_OBJID,
                         targetid = macro_id.objid,
                         targetos = macro_id.osnum );
        __CheckRC( sts, 1, "ACcpx.find_macro", wrapup );

  	sts = om$send( msg = message ACcpx_defn.ACgive_feet_desc(
							&feet_num, &feet),
			senderid = NULL_OBJID,
                      	targetid=mac_def.objid,
			targetos=mac_def.osnum );
	__CheckRC( sts, 1, "ACcpx_defn.ACgive_feet_desc", wrapup );

	if( feet_num )
	{
	      for(i=0; i<feet_num; i++)
	      if( !strcmp( feet[i].name, name ) )
	      {
		idx = i;
	      }
	}

        sts = om$send(  msg      = message NDnode.NDget_objects( 
					ND_ROOT, feat_list, 2, NULL,
					0, 2, &i ),
                      senderid = NULL_OBJID,
                      targetid = macro_id.objid,
                      targetos = macro_id.osnum );
        __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

  	for( i=0; i<2; ++i )
	{
	   cons_plate.obj_id = feat_list[i];

	   VDatGetConsumingChild( &cons_plate, &plate );

	   feat_list[i] = plate.obj_id;

	   for( j=0; j<2; ++j )
	   {
	           if(    feat_list[i].objid == elem2._objid 
	       	       && feat_list[i].osnum == elem2._osnum ) break;
	   }
	   if( j!=2 ) break;
	}

	if( i==2 ) goto wrapup;

	sprintf( ft_name, "jnt%d%d*", i, idx );
	__DBGpr_str( " Foot Name ", ft_name );

	sts = VD_findMatchFtNameSlSfInMacro( &msg, &macro_id,
			inp->drwInfo.drwEnv, ft_name, TRUE,
			&ft_objs, &nb_fts );

	if( nb_fts > 1 )
	{
           res->type           = VS_array ;	
	   res->v.aval.size    = nb_fts ;
	   res->v.aval.element = _MALLOC( nb_fts, VSexecRes );
	}
	for( i=0; i<nb_fts; ++i )
	{

  	   sts = om$send(  msg = message NDnode.ASreturn_go(
				  &ft_gr, NULL, NULL ),
                     senderid = NULL_OBJID,
                     targetid = ft_objs[i]._objid,
                     targetos = ft_objs[i]._osnum  );
	   if( !(sts&1) ) ft_gr = ft_objs[i].obj_id;
	   if( nb_fts > 1 )
	   {
	      res->v.aval.element[i].type	   = VS_object;
	      res->v.aval.element[i]._oval.obj_id  = ft_gr;
	      res->v.aval.element[i]._oval.mod_env = *(inp->drwInfo.drwEnv);
	   }
	   else
	   {
	      res->type 	 = VS_object;
	      res->_oval.obj_id  = ft_gr;
	      res->_oval.mod_env = *(inp->drwInfo.drwEnv);
	   }
	}

wrapup :
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTget_conn_geom */

/* -------------------- FCT VLdrwISOFTYPEuserBlock() -----------	*/
/* -------------------- ALIAS userBlock IS OF TYPE  ---------------	*/
#argsused
IMPLEMENT_ISOFTYPE( VS, userBlock ) {

long			sts, msg;
struct	ACrg_coll	attr;

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "NOCLASS" );
	if( DRW_wantType ){

		DRW_elmType = 0;
		inp->constDefName[0] = '\0';
		strcpy( attr.name, "CUR_STATE" );
		sts = om$send(	msg = message ACrg_collect.ACget_named_attribute
					( &msg, &attr ),
				senderid = NULL_OBJID,
				targetid = DRW_elmId->objid,
				targetos = DRW_elmId->osnum );
		if( sts&msg&1 ){

			if( ! strcmp( attr.desc.value.att_txt, DRW_elmDesc )){
				DRW_elmType	= VS_m_SRC_PLATE;
				inp->constDefName[0] = '\0';

				// clean state field
				attr.desc.value.att_txt[0] = '\0';
				sts = om$send(	msg = 
				      message ACrg_collect.ACmod_list_attribute
							( &msg, 1, &attr ),
						senderid = NULL_OBJID,
						targetid = DRW_elmId->objid,
						targetos = DRW_elmId->osnum );
			}
		}
	}
	if( DRW_wantView ){

		DRW_elmView = VSanyViewType ;

	} // end-want-view

}

end implementation VSfeature;
 
