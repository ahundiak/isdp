/* $Id: vdsfimacros.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / vdsfimacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdsfimacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


#ifndef vdsfimacros_include
#define vdsfimacros_include

/*
 * 	This file depends on the following files :
 *      godef.h
 *      gr.h
 *      igr.h
 *      igrdp.h
 *	go.h
 */

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDget_codelist_sname __((	IGRlong *msg,
				int  product,
				int  list_num,
				char ***sname_list,
				int  *nb_sname ));

extern int VDMngShortNameList   __((	IGRlong *msg,
				char  *FormPtr,
				int   Label,
				int   MsgLabel,
				int   Mode,
				int   Product,
				int   AttribType,
				char  *ShortName ));

#if defined(__cplusplus)
}
#endif

/*---------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------

  MACRO
	vd$get_codelist_sname (	msg,
			product = VDS,
			list_num = 125,
			name_list,
			list_size )

  ABSTRACT 
	This macro gets short name list for a given product, and
	given list number. It is used by the vd$mng_sname_list
	for getting short names for the given list number.
   
  ARGUMENTS

	data type	argument	I/O description

	IGRlong		*msg		O : Complection code 1 if ok.
	IGRint		product		I : product the equipment belongs to
	IGRint		list_num	I : list number in the table
	char		***name_list	O : list of the short text of the list_num
	IGRint		*list_size	O : size of the list

  STATUS RETURNS

	OM_S_SUCESS : Success
	OM_W_ABORT  : Failure

  ------------------------------------------------------------------------- */

#omdef  vd$get_codelist_sname (	msg,
			product = VDS,
			list_num = 125,
			name_list,
			list_size )

	VDget_codelist_sname ( (msg), (product), (list_num),
				(name_list), (list_size) )

#endomdef

/*---------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------

  MACRO
	vd$mng_sname_list (	msg,
			FormPtr,
			Label,
			MsgLabel = FI_MSG_FIELD,
			Mode,
			Product = VDS,
			AttribType = VD_SYS_NAME,
			ShortName )

  ABSTRACT 
	This macro manages form interface of short names for given product and
  attribute type.
   
  ARGUMENTS

	data type	argument	I/O description

	IGRlong		*msg		O : Complection code 1 if ok.
	IGRchar		*FormPtr	I : form pointer
	IGRint		Label		I : gadget label of the attribute
	IGRint		MsgLabel	I : gadget label of message strip
	IGRint		Product		I : product to which equipment belongs.
					    See VDmacdef.h
	IGRint		AttribType	I : type of the attribute
					    See 
	IGRchar		*ShortName      I/O : Old attribute which gets updated
						to new attribute.

  REMARKS :
        First time this macro is called with mode = VDShortNameLstInit which
  initializes the associated list of gadget label "Label" with the list of
  short names of AttribType.

        Subsequently, it is called with mode = VDShortNameVerif. This checks
  if the string keyed in by user exists in the list and acts appropriately.

  STATUS RETURNS

	OM_S_SUCESS : Success
	OM_W_ABORT  : Failure

  ------------------------------------------------------------------------- */

#omdef	vd$mng_sname_list (	msg,
			FormPtr,
			Label,
			MsgLabel = FI_MSG_FIELD,
			Mode,
			Product = VDS,
			AttribType = VD_SYS_NAME,
			ShortName )

	VDMngShortNameList ( (msg), (FormPtr), (Label), (MsgLabel), (Mode),
			     (Product), (AttribType), (ShortName) )

#endomdef

/*---------------------------------------------------------------------------*/

#endif
