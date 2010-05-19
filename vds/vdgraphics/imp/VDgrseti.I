/* $Id: VDgrseti.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/imp / VDgrseti.I
 *
 * Description:
 *   This file implements set messages used in I/VDS.
 *      its the implementation file for VDgrset.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgrseti.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:50  cvs
 *      Initial import to CVS
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
# Revision 1.5  1995/06/28  13:04:14  pinnacle
# Replaced: vdgraphics/imp/VDgrseti.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/06/19  13:27:16  pinnacle
# Replaced: vdgraphics/imp/VDgrseti.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/03/19  22:32:36  pinnacle
# Replaced: vdgraphics/imp/VDgrseti.I by azuurhou r#
#
# Revision 1.2  1994/11/30  21:19:30  pinnacle
# Replaced:  vdgraphics/imp r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/10/94        Chaya V. Rao
 *
 * --------------------------------------------------------------------------*/

/*===========================================================================*/

class implementation VDgrset;

#include 	<string.h>
#include 	<stdio.h>

#include 	"OMerrordef.h"
#include	"OMminimum.h"
#include	"OMmacros.h"
#include 	"msdef.h"
#include	"grownerdef.h"
#include	"v_miscmacros.h"
#include	"v_dbgmacros.h"
#include        "AS_status.h"


/*============================================================================*/
/*	method  VDSet_name -This message is used to set the name of VDgrset.  */
/*============================================================================*/

method	VDSet_name(
	long		*msg;           /* o - Return status            */
	char		*name;		/* i - name for set (NULL term) */
	) 
{
int			nam_len;

	SetProc( VDSet_name ); Begin 

	*msg = MSSUCC;

	nam_len = strlen(name);
	nam_len++ ;
	om$vla_set_dimension( varray = me->name, size = nam_len );
	strcpy( me->name, name );

	__DBGpr_str("Set_name ", me->name );

	End
	return( OM_S_SUCCESS );
}


/*============================================================================*/
/*	method  VDSet_comment -This message is used to set the comment        */
/*============================================================================*/

method	VDSet_comment(
	long		*msg;           /* o - Return status            */
	char		*comment;	/* i - comment for set 		*/
	) 
{
int			comment_len;

	SetProc( VDSet_comment ); Begin

	*msg = MSSUCC;

	comment_len = strlen(comment);
	comment_len++ ;
	om$vla_set_dimension( varray = me->comments, size = comment_len );
	strcpy( me->comments, comment );

	__DBGpr_str("Set_comment", me->comments );

	End 
	return( OM_S_SUCCESS );
}

/*============================================================================*/
/*	method  VDSet_flag -This message is used to set the flag              */
/*============================================================================*/

method VDSet_flag(
        long            *msg;           /* o - Return status            */
        int             flag;           /* i - flag 0=public or 1=private*/
        )

{
	SetProc( VDSet_flag ); Begin

	*msg = MSSUCC;
	me->flag = flag ;
	__DBGpr_int("VDSet_flag", me->flag );

	End
	return( OM_S_SUCCESS );
}

/*===========================================================================*/ 
/*   method VDGet_name -This message is used to get the name of VDgrset      */
/*===========================================================================*/ 

method VDGet_name(
	long            *msg;           /* o - Return status            */
	int		maxlen;		/* i - maximum allowable length */
	char		*name;		/* o - Put name here		*/
	)
{
IGRint	len = 0;

	SetProc( VDGet_name ); Begin

	*msg = MSSUCC;

	if( ! name ){
		*msg = MSFAIL;
		return( OM_S_SUCCESS );
	}

        len = om$dimension_of( varray = me->name );

	if( len < maxlen ){
		strcpy( name, me->name );
	}
	else{
		strncpy( name, me->name, maxlen-2 );
		name[maxlen-1] = '\0';
	}

	__DBGpr_str("VDGet_name ", name );

	End
	return( OM_S_SUCCESS );
}

/*===========================================================================*/
/*   method VDGet_comment -This message is used to get the comment 	     */
/*===========================================================================*/ 

method VDGet_comment(
	long            *msg;           /* o - Return status            */
	int		maxlen;		/* i - maximum allowable length */
	char		*comment;	/* o - Put comment here		*/
	)
{
IGRint	len = 0;

	SetProc( VDGet_comment ); Begin

	*msg = MSSUCC;

	if( ! comment ){
		*msg = MSFAIL;
		return( OM_S_SUCCESS );
	}

        len = om$dimension_of( varray = me->comments );

	if( len < maxlen ){
		strcpy( comment, me->comments );
	}
	else{
		strncpy( comment, me->comments, maxlen-2 );
		comment[maxlen-1] = '\0';
	}

	__DBGpr_str("VDGet_comment ", comment );

	End
	return( OM_S_SUCCESS );
}

/*===========================================================================*/
/*   method VDGet_flag -This message is used to get the flag         	     */
/*===========================================================================*/ 
method VDGet_flag(
	long            *msg;           /* o - Return status            */
	int		*flag;	        /* o - Put flag here		*/
	)
{
	SetProc( VDGet_flag ); Begin

	*msg = MSSUCC;

        *flag =  me->flag; 
	__DBGpr_int(" VDGet_flag ", *flag );

	End
	return( OM_S_SUCCESS );
}

/*============================================================================*/
/*   method VDName_to_id -matches set given name                              */
/*============================================================================*/

method VDName_to_id(
	long            *msg;           /* o - Return status            */
	char		*name;		/* i - name to match (NULL term)*/
      	struct GRid     *set_id;	/* i - Object id of set if matched*/
	)
{
	long		sts;

	SetProc( VDName_to_id ); Begin 

	*msg = MSSUCC ;	

	if ( !( sts = strcmp(name,me->name) ) )
	{
	   	(*set_id).objid = my_id;
	   	(*set_id).osnum = OM_Gw_current_OS;

	   	return( OM_I_STOP_SENDING );
	}

	End
	return( OM_S_SUCCESS );
}

/*============================================================================*//*   method VDget_grid_list -returns array of set grids                       *//*============================================================================*/                                                                    
method VDget_grid_list(
	long		*msg;		/* o - return status	*/
	long		*index;		/* i/o - index of set	*/
	struct GRid	grids[];	/* i/o - array of grids	*/
	)
{
	SetProc( VDget_grid_list ); Begin

	*msg = MSSUCC ;

	if( grids ){
	   grids[*index].objid = my_id;
           grids[*index].osnum = OM_Gw_current_OS;
        }

	*index = *index + 1;

	__DBGpr_int("Next Index", *index );

	End
	return( OM_S_SUCCESS );
}

/*============================================================================*//*    method VDget_name_list -returns array of set names                      *//*============================================================================*/  
method VDget_name_list(
	long		*msg;		/* o - return status		*/
	long		*index;		/* i/o - index of set		*/
	char		name[][32];	/* i/o - array of names		*/
	)
{
	SetProc( VDget_name_list ); Begin

	*msg = MSSUCC ;

	if (name)
	   sprintf( name[*index], "%s", me->name );

	*index = *index + 1;

	__DBGpr_int("Next Index", *index );

	End
	return( OM_S_SUCCESS );
}

/*============================================================================*//*     method VDdelete_if_empty -This message is to delete                    *//*============================================================================*/ 
method VDdelete_if_empty(
IGRlong			*msg;        /* i/o - return code            */
struct	GRmd_env	*md_env;     /* i   - module Info	     */
)
{
long		        status;
struct GRid	        my_grid;
OMuint	        	inq_count;
OM_S_CHANSELECT	        GRcmpowner_to_connector_CS;

	SetProc( VDdelete_if_empty ); Begin

	*msg = MSSUCC;

	my_grid.objid = my_id; 
	my_grid.osnum = OM_Gw_current_OS;

        status =
        om$make_chanselect( channame      = "GRcmpowner.to_components",
                            p_chanselect  = &GRcmpowner_to_connector_CS
                          );
        as$status();

	status =
	om$get_channel_count(	objid = my_id,
				p_chanselect = &GRcmpowner_to_connector_CS,
				count = &inq_count );
        as$status();

       __DBGpr_int(" count ", inq_count );

	if( ! inq_count )
	{
		status =
		_VD_SEND_OBJ(	my_grid,
				GRgraphics.GRdelete(msg, md_env ));
		as$status();

		/*
		 * if the flag is non-zero, the set is used for
		 * internal list management. 
		 */
	}
	
	End
	return( OM_S_SUCCESS );
}

/*============================================================================*//*   method GRget_locate_properties -This method returns properties           */
/*   which make the set non-locatable                                         */
/*============================================================================*/

method GRget_locate_properties(
	IGRlong *msg;
	IGRint *properties
	)
{
	SetProc( GRget_locate_properties ); Begin

	*msg = MSSUCC ;

	*properties =   GR_LC_CMP_READ | GR_LC_CMP_WRITE |
			GR_LC_CMP_PRM_READ | GR_LC_CMP_PRM_WRITE |
			GR_LC_FLEXIBLE;

	End
	return( OM_S_SUCCESS );
}

/*============================================================================*/

end implementation VDgrset;
