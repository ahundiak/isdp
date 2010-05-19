/* $Id: VDgrset.S,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/imp / VDgrset.S
 *
 * Description: 
 *	This class defines sets used in I/VDS for set and 
 *	group operations.  The basic function is to deliver
 *	messages to all members of the set.  Sets can be 
 *	composed of other sets associated by channel connection.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgrset.S,v $
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
 *
 * History:
 *      06/10/94        Chaya V. Rao
 *
 * --------------------------------------------------------------------------*/

/*============================================================================*/

class specification VDgrset (1:0) of GRgrgrp;

#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"

instance VDgrset
{
	variable char		name[1];	/* name of set		*/
	variable char		comments[1];	/* comment of set	*/
	IGRint			flag;			
};


override GRget_locate_properties; /* the set should be non-locatable */
override GRdifference;
override GRintersection;
override GRunion;

/*
 *  Send this message when you create a set to give it a name.  Or, when
 * a group operation is converted into a permanent set.
 */
message	VDSet_name(
	long		*msg;           /* o - Return status            */
	char		*name;		/* i - name for set (NULL term) */
	);


/*
 *  Send this message when you create a set to give it commenr.  Or, when
 * a group operation is converted into a permanent set.
 */
message	VDSet_comment(
	long		*msg;           /* o - Return status            */
	char		*comment;	/* i - comment for set 		*/
	);


/*
 *  Send this message when you create a set to give it flag value. 
 */
message	VDSet_flag(
	long		*msg;           /* o - Return status            */
	int		flag;	        /* i - flag 0=public or 1=private*/
	);

/*
 * This message returns the set's name in a supplied character array
 */
message VDGet_name(
	long            *msg;           /* o - Return status            */
	int		maxlen;		/* i - maximum allowable length */
	char		*name;		/* o - Put name here		*/
	);


/*
 * This message returns the set's comment in a supplied character array
 */
message VDGet_comment(
	long            *msg;           /* o - Return status            */
	int		maxlen;		/* i - maximum allowable length */
	char		*comment;	/* o - Put comment here		*/
	);

/*
 *   message VDGet_flag -This message is used to get the flag
 */
message VDGet_flag(
        long            *msg;           /* o - Return status            */
        int             *flag;           /* o - Put flag here            */
        );

/* 
 * This message is generally sent by the SetManager when locating a set
 */
message VDName_to_id(
	long            *msg;           /* o - Return status            */
	char		*name;		/* i - name to match (NULL term)*/
      	struct GRid     *set_id;	/* o - Object id of set if matched*/
	);


/* This message is used to collect a list of set grids. 
 */
message VDget_grid_list(
	long		*msg;		/* o - return status	*/
	long		*index;		/* i/o - index of set	*/
	struct GRid	grids[];	/* i/o - array of grids	*/
	);

	
/* This message is generally sent by the SetManager when collecting names
 * of all sets
 */
message VDget_name_list(
	long		*msg;		/* o - return status		*/
	long		*index;		/* i/o - index of set		*/
	char		name[][32];	/* i/o - array of names		*/
	);



message VDdelete_if_empty(
      long              *msg;        /* i/o - return code            */
      struct GRmd_env	*md_env;     /* i   - module Info	     */
    );

end specification VDgrset;
