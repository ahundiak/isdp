/* $Id: VSplnjntfrm.I,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSplnjntfrm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplnjntfrm.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/04/02  10:36:10  pinnacle
# Replaced: vscmd/VSplnjntfrm.I for:  by svkadamb for struct
#
# Revision 1.4  1998/03/12  22:06:08  pinnacle
# New Joints
#
# Revision 1.3  1998/01/02  12:21:24  pinnacle
# Replaced: vscmd/VSplnjntfrm.I for:  by svkadamb for struct
#
# Revision 1.1  1997/11/14  12:20:56  pinnacle
# Created: vscmd/VSplnjntfrm.I by svkadamb for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *           suresh  creation
 * 03/12/98  suresh  TR179800680 Modify New Joint
 ***************************************************************************/

/*
	I/STRUCT
*/
class implementation VSplnjntCmd ;

#include <stdio.h>
#include <FI.h>
#include "OMmacros.h"
#include "VDSsymb_def.h"
#include "vsglobalmsg.h"
#include "vswelddef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsnamemacros.h"
#include "vsjntmacros.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vscmdmacros.h"
#include "vsmiscmacros.h"
#include "vsformmacros.h"
#include "vsjnformdef.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes
 */
/* #include "VX_FIproto.h" */
#include "vsstrngproto.h"
#include "vsioproto.h"
#include "vsformproto.h"

#include "VDweldsym.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*      ********************	GLOBAL VARIABLES  *****************************	*/
/* 	Defined in   :								*/
/*		vdweld/imp/weldtxt.I						*/
/* 	Used also in :								*/
/*		vdweld/cmd/VDweldcmd.I & vdweld/cmd/weldform.I			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern struct VDweld_gadget_sym	sym_char[];

extern int	VDread_weld_sym_char();


#define VS_K_Jnt_Attribute_File		"VSPlJnAttr.fm"
#define VS_K_jn_Dismiss_Execute	1
#define VS_K_jn_Execute		2
#define VS_K_jn_Revert		3
#define VS_K_jn_Dismiss		4
#define VS_K_jnCreate		17
 
#define CODE_BUTTON     36
#define PROC_BUTTON     24
#define SIZE_BUTTON     25

#define VS_K_jn_Weld_Code       12
#define VS_K_jn_Process         16
#define VS_K_jn_Weld_Size       13
 
 
#define CODE_LIST       12
#define PROC_LIST       16
#define SIZE_LIST       13
 
#define PART_MCF        18
 
#define JNT_ATTR        15
 
#define CODE_ALL        27
#define CODE_CLEAR      28
 
#define PROC_ALL        31
#define PROC_CLEAR      30

#define SIZE_ALL        29
#define SIZE_CLEAR      14

#define CODE_COL	2
#define PROC_COL	3
#define SIZE_COL	4

#define VS_K_jn_wldSideSym	16

/*----------------------------------------------------------------------------*/
method VSsetJnts_form_notification( int form_label; int gadget_label; 
					double value; char    *form_ptr )
{
	long		msg ;
	int		i;
	int		rows, fdsp ;
	int     	selFlag = 0;
        char    	*code = NULL, *proc = NULL, *size = NULL ;
	int		response ;
	int		isHere, inModel, writable ;

#define PUT_RESPONSE( value )\
	{ int resp = (value) ; ex$putque( msg = &msg, response = &resp ) ; }

	
	switch( gadget_label ) {

		case VS_K_jn_Dismiss_Execute    :
			/*
			 * Construct beam(s), then exit command.
			 */
			response = TERMINATE ;
			goto EXECUTE ;
 
		case VS_K_jn_Execute            :
			/*
			 * Construct beam, then go to state "start".
			 */
			response = EX_BACK_UP ;
			goto EXECUTE ;
		case VS_K_jnCreate 	:
			response = VS_K_SAME_STATE ;

		EXECUTE :
			vs$isDirUsable(	dirname	= me->Cwd,
					isHere	= &isHere,
					inModel	= &inModel,
					writable= &writable ) ;
			if( !isHere ) {
				VSfi_msgkeySts( form_ptr, VS_gE_NoRowsSel ) ;
				FIg_set_state_off( form_ptr, gadget_label ) ;
				break ;
			} else if( !inModel ) {
				/*
				 * Cannot construct if not in master file.
				 */
				VSfi_msgkeySts( form_ptr, VS_gW_CwdNtInMod ) ;
				FIg_set_state_off( form_ptr, gadget_label ) ;
				break ;
			} else if( !writable ) {
				VSfi_msgkeySts( form_ptr, VS_gW_CwdNotWritable ) ;
				FIg_set_state_off( form_ptr, gadget_label ) ;
				break ;
			}

			om$send(msg = message VSplnjntCmd.construct_joint( 
								&msg,
								form_label,
								form_ptr ),
				targetid= my_id ) ;
			// FIf_erase( form_ptr );
			PUT_RESPONSE( response );
			break ;

		case VS_K_jn_Revert		:
			om$send( msg = message VSplnjntCmd.initForm(
								&msg,
								form_label,
								form_ptr ),
				targetid = my_id );
			if( !(msg & 1 ) ) PUT_RESPONSE ( EX_BACK_UP );
			break ;
		case VS_K_jn_Dismiss            :
			/*
			 * Exit command.
	 		 */
			response = TERMINATE ;
			PUT_RESPONSE( response );
			break ;

		case CODE_ALL :
			FIfld_get_num_rows( 	form_ptr,
						PART_MCF,
						&rows );
			for( i = 0; i < rows ; i++ ) {
				FIfld_set_select( 	form_ptr,
							PART_MCF,
							i,
							CODE_COL,
							TRUE );
			}
			break ;

		case CODE_CLEAR :
			rows = 0;
                        FIfld_get_num_rows( 	form_ptr,
                                                PART_MCF,
                                                &rows );
                        for( i = 0; i < rows ; i++ ) {
                                FIfld_set_select(       form_ptr,
                                                        PART_MCF,
                                                        i,
                                                        CODE_COL,
                                                        FALSE ); 
                        }
                        break ;

		case PROC_ALL :
			rows = 0;
			FIfld_get_num_rows( form_ptr,
                                                PART_MCF,
                                                &rows );
                        for( i = 0; i < rows ; i++ ) {
                                FIfld_set_select(       form_ptr,
                                                        PART_MCF,
                                                        i,
                                                        PROC_COL,
                                                        TRUE ); 
                        }
			break ;

		case PROC_CLEAR :
                        rows = 0;
                        FIfld_get_num_rows(     form_ptr,
                                                PART_MCF,
                                                &rows );
                        for( i = 0; i < rows ; i++ ) {
                                FIfld_set_select(       form_ptr,
                                                        PART_MCF,
                                                        i,
                                                        PROC_COL,
                                                        FALSE );
                        }
                        break ;

		case SIZE_ALL :
			rows = 0;
			FIfld_get_num_rows(	form_ptr,
                                                PART_MCF,
                                                &rows );
                        for( i = 0; i < rows ; i++ ) {
                                FIfld_set_select(       form_ptr,
                                                        PART_MCF,
                                                        i,
                                                        SIZE_COL,
                                                        TRUE ); 
                        }
			break ;

		case SIZE_CLEAR :
                        rows = 0;
                        FIfld_get_num_rows(     form_ptr,
                                                PART_MCF,
                                                &rows );
                        for( i = 0; i < rows ; i++ ) {
                                FIfld_set_select(       form_ptr,
                                                        PART_MCF,
                                                        i,
                                                        SIZE_COL,
                                                        FALSE );
                        }
                        break ;

		case CODE_BUTTON :
                case VS_K_jn_Weld_Code  :

			/* 
                         * This is a set form , hence set all the possible rows
                         * with the weld codes
			 */
                        code = VSfld_get_text( form_ptr, CODE_LIST );
			rows = 0;
                        FIfld_get_num_rows(     form_ptr,
                                                PART_MCF,
                                                &rows );
			for( i = 0; i < rows ; i++ ) {
				FIfld_get_select( form_ptr, PART_MCF, i,
						  CODE_COL, &selFlag );
				if( selFlag ) {
					FIfld_set_text( form_ptr,  
							PART_MCF, 
							i, 
							CODE_COL, 
							code,
							TRUE );
				}
			}	
			_FREE( code )
			break ;

		case PROC_BUTTON :
		case VS_K_jn_Process    :
			/* 
                         * This is a set form, set all the possible rows
                         * with the weld processes 
			 */
                        proc = VSfld_get_text( form_ptr, PROC_LIST );
			rows = 0;
                        FIfld_get_num_rows(     form_ptr,
                                                PART_MCF,
                                                &rows );
			for( i = 0; i < rows ; i++ ) {
				FIfld_get_select( form_ptr, PART_MCF, i,
						  PROC_COL, &selFlag );
				if( selFlag ) {
					FIfld_set_text( form_ptr,  
							PART_MCF, 
							i, 
							PROC_COL, 
							proc,
							TRUE );
				}
			}	
			_FREE( proc )
			break ;	

		case SIZE_BUTTON :
		case VS_K_jn_Weld_Size   :
                        size = VSfld_get_text( form_ptr, SIZE_LIST );
			rows = 0;
                        FIfld_get_num_rows(     form_ptr,
                                                PART_MCF,
                                                &rows );

			for( i = 0; i < rows ; i++ ) {
				FIfld_get_select( form_ptr, PART_MCF, i,
						  SIZE_COL, &selFlag );
				if( selFlag ) {
					FIfld_set_text( form_ptr,  
							PART_MCF, 
							i, 
							SIZE_COL, 
							size,
							TRUE );
				}
			}	
			_FREE( size )
			break ;

		case  JNT_ATTR :
			if ( me->attrForm ) {
				FIf_is_displayed( me->attrForm, &fdsp ) ;
				if ( ! fdsp ) {
					int x_pos , y_pos ;

					FIf_get_location(form_ptr,
							 &x_pos,
							 &y_pos );

					FIf_set_location( me->attrForm,
							  x_pos + 300,
							  y_pos + 200 );

        				FIf_display( me->attrForm ) ;
				}	
			} else {
				int x_pos , y_pos ;

        			VSf_sub_form(   form_ptr,
		               			gadget_label,
						VS_K_Jnt_Attribute_File,
						&me->attrForm ) ;

				FIf_get_location(       form_ptr,
							&x_pos,
							&y_pos );

				FIf_set_location( me->attrForm,
						  x_pos + 300,
						  y_pos + 200 );

				FIg_display( me->attrForm, VS_K_jn_wldSideSym );
				FIf_display( me->attrForm ) ;
			}
 
        		FIg_disable( form_ptr, gadget_label ) ;
 
        		break ;

		default :
			break ;

	}

	return FI_SUCCESS ;

} /* VSsetJnts_form_notification */
/*----------------------------------------------------------------------------*/
method VSpartJnts_form_notification( int form_label; int gadget_label; 
					double value; char *form_ptr )

{
	/*
	 * Notification routine of user-attributes sub-form.
	 */
	switch( gadget_label ) {

		default :
			break ;
	}

	return FI_SUCCESS ;

} /* VSpartJnts_form_notification */
/*----------------------------------------------------------------------------*/
long VSgetActNewJnAttr( msg, actJnAttr )
 
long            *msg ;
VSjointAttr    	*actJnAttr ; {
 
        vs$get_act_pm( msg      = msg,
                     param      = VS_e_dpb_J_weldAttr,
                     p_arg      = &actJnAttr->weldAttr ) ;
        if( !( *msg & 1 ) ) goto wrapup ;

	 vs$get_act_pm(  msg     = msg,
                        param   = VS_e_dpb_J_Allowance,
                        p_arg   = &actJnAttr->allowance ) ;
        if( !( *msg & 1 ) ) goto wrapup ;
 
        vs$getDpbCollAttr(      msg     = msg,
                                name    = VS_K_dpbActJnGrvAng,
                                p_value = &actJnAttr->grooveAngle ) ;
        if( !( *msg & 1 ) ) goto wrapup ;


  	vs$getDpbCollAttr(      msg     = msg,
                                name    = VS_K_dpbActJnPitch,
                                p_value = &actJnAttr->pitch ) ;
        if( !( *msg & 1 ) ) goto wrapup ;
 
        vs$getDpbCollAttr(      msg     = msg,
                                name    = VS_K_dpbActJnIncrLn,
                                p_value = &actJnAttr->incrLength ) ;
        if( !( *msg & 1 ) ) goto wrapup ;

        vs$getDpbCollAttr(      msg     = msg,
                                name    = VS_K_dpbActJnShrkRatio,
                                p_value = &actJnAttr->shrinkage ) ;
        if( !( *msg & 1 ) ) goto wrapup ;

	vs$getDpbCollAttr(      msg     = msg,
				name    = VS_K_dpbActJnWeldSize,
				p_value = &actJnAttr->size ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	vs$getDpbCollAttr(      msg     = msg,
                                name    = VS_K_dpbActJnUsrSym,
                                p_value = actJnAttr->usrSymbol ) ;
        if( !( *msg & 1 ) ) goto wrapup ;

	{
	double		val ;
	vs$getDpbCollAttr(      msg     = msg,
                                name    = VS_K_dpbActJnWeldPos,
                                p_value = &val  ) ;
        if( !( *msg & 1 ) ) goto wrapup ;

	actJnAttr->addWldAttr.position = val ;
		{ 
		int	info ;
		info = actJnAttr->weldAttr.info  ;
		if( info &  & VS_m_wldFieldWeld    ) {
			actJnAttr->addWldAttr.fieldweld = TRUE ;
		} else {
			actJnAttr->addWldAttr.fieldweld = FALSE ;
		}
		}
	}

       wrapup :
                return *msg & 1 ;
}
/*----------------------------------------------------------------------------*/
long VSfillNewJointForm( msg, form, jAttr )
long		*msg ;
char		*form ;
VSjointAttr	*jAttr ; {

	long		sts,
			*list ;
	int		count, cnt1 = 0,cnt2,
			info,
			g,
			s ;
	char		**codeList , **procList;

	codeList = procList = NULL ;

	vs$g_erase_gadgets(	form	= form,
				list	= `VS_K_jn_ArrowSideSym,
					   VS_K_jn_OtherSideSym,
					   VS_K_jn_BothSidesSym` ) ;
	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_Allowance,
				value	= jAttr->size ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_GrooveAngle,
				type	= GRIO_ANGLE,
				value	= jAttr->grooveAngle ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_Pitch,
				value	= jAttr->pitch ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_IncrLength,
				value	= jAttr->incrLength ) ;
	/*
	 * Retrieve list of weld codes from an ASCII file
	 */
	sts = VDread_weld_sym_char( &cnt1 );	// READ FROM "$VDS/config/weld_symbols"
	
	if( !(sts & 1 && cnt1 ) ) {
		/*
		 * Retrieve list of weld codes which are static 
		 * NOTE `list' not to be freed.
		 */
		sts = vs$getWeldCodes( msg	= msg,
				       count	= &count,
				       list	= &list ) ;
		__CheckRC( sts, *msg, "vs$getWeldCodes", wrapup ) ;

		VSfillSelectListAndSetActive(	form,
						VS_K_jn_Weld_Code,
						count,
						list,
						(int) jAttr->weldAttr.code ) ;
	} else {
		/*
		 * Set the list of weld codes from the ASCII file
		 * in the form
		 */
		int	i;

		for ( i = 0; i< cnt1 ; i ++ ) {
			FIfld_set_list_text( form, VS_K_jn_Weld_Code, i, 0,
					     (unsigned char *) sym_char[i].desc,
					     FALSE);
			if( i == (int) jAttr->weldAttr.code )
			{
			  FIfld_set_text( form, VS_K_jn_Weld_Code, 0, 0, sym_char[i].desc, TRUE ) ;
 
			  FIfld_set_list_select( form, VS_K_jn_Weld_Code, i, 0, TRUE ) ;
			}

		}
	}
	/*
	 * Retrieve list of weld processes from an ASCII file
	 */
	sts = vs$getWeldProcASCII (	msg 	= msg,
					count 	= &cnt2,
					list	= &procList );
	if( !(sts & *msg & 1 ) ) {
		/*
		 * Retrieve list of weld processes which are statis. 
		 * NOTE `list' not to be freed.
		 */
		sts = vs$getWeldProcesses(	msg	= msg,
						count	= &count,
						list	= &list ) ;
		__CheckRC( sts, *msg, "vs$getWeldProcesses", wrapup ) ;

		VSfillSelectListAndSetActive(	form,
						VS_K_jn_Process,
						count,
						list,
						(int) jAttr->weldAttr.process );
	} else {
		/*
		 * Set the list of weld code from the ASCII file
		 * in the form
		 */
		int	flag = TRUE ;	
		int	i;

		for ( i = 0; i< cnt2 ; i ++ ) {
			FIfld_set_list_text( form, VS_K_jn_Process,
						i, 0, (unsigned char *) procList[i], flag);
			flag = FALSE ;
		}
	}
	info = jAttr->weldAttr.info ;

	if( info & VS_m_wldWeldAllAround ) {
		FIg_set_state_on( form, VS_K_jn_AllAround	) ;
	}

	/*
	if( info & VS_m_wldFieldWeld	) {
		FIg_set_state_on( form, VS_K_jn_FieldWeld	) ;
	}
	*/

	if( jAttr->addWldAttr.fieldweld  ) {
		FIg_set_state_on( form, VS_K_jn_FieldWeld       ) ;
	}

	if( info & VS_m_wldMeltThru	) {
		FIg_set_state_on( form, VS_K_jn_MeltThru	) ;
	}

	       if( info & VS_m_wldFlushContour	) {
		FIg_set_state_on( form, VS_K_jn_Flush	) ;
	} else if( info & VS_m_wldConvexContour	) {
		FIg_set_state_on( form, VS_K_jn_Convex	) ;
	} else if( info & VS_m_wldConcaveContour) {
		FIg_set_state_on( form, VS_K_jn_Concave	) ;
	}

	switch( jAttr->weldAttr.side ) {
		default			: 
		case VS_K_wldLeftSide	:
			g = VS_K_jn_LeftSide ;
			s = VS_K_jn_ArrowSideSym ; break ;
		case VS_K_wldRightSide	:
			g = VS_K_jn_RightSide ;
			s = VS_K_jn_OtherSideSym ; break ;
		case VS_K_wldBothSides	:
			g = VS_K_jn_BothSides ;
			s = VS_K_jn_BothSidesSym ; break ;
	}
	FIg_set_state_on( form, g ) ;
	FIg_display( form, s ) ;

	switch( jAttr->addWldAttr.position ) {
		default			: 
		case VS_K_wldFloorPos :
			g = VS_K_jn_FloorPos ;
			break ;
		case VS_K_wdlHorzPos :
			g =  VS_K_jn_HorzPos;
			break ;
		case VS_K_wldCeilPos :
			g = VS_K_jn_CeilPos ;
			break ;
		case VS_K_wldVertPos :
			g = VS_K_jn_VertPos ;
			break ;
	}
	FIg_set_state_on( form, g ) ;

	/*
	 * Set the weld shrinkage ratio
	 */
	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_Shrinkage,
				value	= jAttr->shrinkage ) ;

//	FIfld_set_text( form, VS_K_jn_UsrSymbol, 0, 0, jAttr->usrSymbol, FALSE ) ;

	wrapup :
		VSfreeList( cnt1, codeList);
		VSfreeList( cnt2, procList);
		return sts ;

} /* VSfillNewJointForm */
/*----------------------------------------------------------------------------*/

end implementation VSplnjntCmd ;

