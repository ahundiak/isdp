/* $Id: SMmacros.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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


#ifndef SMmacros_include
#define SMmacros_include

/*
 * 	This file depends on the following files :
 *	
 *		gr.h
 *		ACrg_collect.h
 *		SMdef.h
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

extern int SMCritSel __((	IGRlong *msg,
				IGRshort options,
				IGRshort state,
				IGRshort type,
				IGRshort sub_type,
				IGRint nb_crit,
				struct ACrg_coll *crit,
				struct SMObjList *list,
				IGRboolean tag));

extern int SMSeasafe __((	IGRlong *msg,
				IGRchar *filename,
				IGRshort state,
				IGRshort options,
				IGRshort type,
				IGRshort sub_type,
				IGRboolean tag,
				IGRshort out_units,
				struct GRmdenv_info *trans_env,
				IGRint rel_number));


extern int SMReport __((	IGRlong *msg,
				IGRchar *filename,
				IGRshort state,
				IGRshort options,
				IGRshort type,
				IGRshort sub_type,
				IGRboolean tag,
				IGRshort out_units,
				struct GRmdenv_info *trans_env,
				IGRchar *DescFileName,
				IGRint RelNumber));

#if defined(__cplusplus)
}
#endif


/*---------------------------------------------------------------------------
  
  MACRO
	SM$CritSel(
	   options	= SM_ASCII_FILE,
	   state	= SM_NEW | SM_UPD | SM_MOD,
	   type 	= 0,
	   sub_type 	= 0xFFFF,
	   nb_crit 	= 0,
	   crit		= NULL,
	   list		= NULL ^  tag = FALSE)

  ABSTRACT
	Given a type, a sub_type and a criteria, its returns the list of found
	objects. Return OM_S_SUCCESS if succesful.

  ARGUMENTS

	data type	argument	I/O	description

	IGRlong		*msg		O :	Completion code

	IGRshort        options         I :	options (SMdef.h)

        IGRshort        state           I :	Simple filter
 					         (SM_NEW, SM_MOD, SM_UPD)

        IGRshort	type		I :	Type of the object ( SMdef.h).

        IGRshort	sub_type	I :	Sub-type of object (SMdef.h).

        IGRshort	units		I :	Output units.

	GRmdenv_info	*transl         I :	Transformation matrix (& type).

        IGRint		nb_crit		I :	Number of criteria.	

        struct ACrg_coll *crit		I :	Criteria list

        struct SMObjList *list		O :	Found object list.

        IGRboolean	tag		I :	If the found object are tagged.


  REMARKS
	The criteria are using an ACrg_coll structure. It allows to define the 
	attribute name, the attribute type (double, string) and the possible 
	value. Even if the attribute type is a double, its possible value will 
	be stored as a string. This allows using compressed forms for multiple 
	choices.

  EXAMPLE
	The criteria is two diameters with multiple values:

    	att[0].name =>       		"diam1"
	att[0].type =>  		AC_ATTRIB_DOUBLE
	att[0].desc.value.att_txt =>	"[5-7]" (from 5 to 7) 
	att[1].name =>       		"diam2"
	att[1].type =>  		AC_ATTRIB_DOUBLE
	att[1].desc.value.att_txt =>	"2,4,5" 

	This returns either a list of selected objects or it tags them. Some
	messages can be executed only by tagged objects.

  ------------------------------------------------------------------------*/

#omdef SM$CritSel(msg,
	   options	= SM_ASCII_FILE,
	   state	= SM_NEW | SM_UPD | SM_MOD,
	   type 	= 0,
	   sub_type 	= 0xFFFF,
	   nb_crit 	= 0,
	   crit		= NULL,
	   list		= NULL ^  tag = FALSE)

	SMCritSel((msg), (options), (state), (type), (sub_type),
			(nb_crit), (crit), (list), (tag));
#endomdef

/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------

  MACRO
	SM$Seasafe(
	   msg,
           filename  = "Seasafe_file",
	   state     = SM_NEW | SM_MOD, 
	   options   = SM_ASCII_FILE | SM_REG_RPT, 
           type      = 0xFFFF, 
	   sub_type  = 0xFFFF,
	   tag	     = FALSE,
	   out_units = SM_UNIT_INT,
	   trans_mat = NULL,
	   rel_numb  = 0)

  ABSTRACT
	Given the filename, state, type, sub_type and options generates the
	Seasafe output file.

  ARGUMENTS
	data type	argument	I/O	description

	IGRlong         *msg            O :	Completion code

	IGRchar         filename        I :	Output file name.

	IGRshort        state           I :	Simple filter
						(SM_NEW, SM_MOD, SM_UPD)

	IGRshort        options         I :	Possible options.
	
	IGRshort	type		I :	Type of objects (SMdef.h).

	IGRshort	sub_type	I :	Sub-type of objects (SMdef.h).
	
	IGRboolean 	tag		I :	TRUE => Use the tag method

	IGRshort	out_units	I :	Output units.

	struct GRmdenv_info *trans_mat	I :	Transf. matrix (NULL if unused).

  REMARKS
	Use type = "FFFF" and sub_type = "FFFF" to get all the components.


  ---------------------------------------------------------------------------*/

#omdef SM$Seasafe(
	   msg,
           filename  = "Seasafe_file",
	   state     = SM_NEW | SM_MOD, 
	   options   = SM_ASCII_FILE | SM_REG_RPT, 
           type      = 0xFFFF, 
	   sub_type  = 0xFFFF,
	   tag	     = FALSE,
	   out_units = SM_UNIT_INT,
	   trans_mat = NULL,
	   rel_numb  = 0)

	SMSeasafe((msg), (filename), (state), (options), (type),
		  (sub_type), (tag), (out_units), (trans_mat), (rel_numb));
#endomdef

/*---------------------------------------------------------------------------

  MACRO
	SM$Reports:

  ABSTRACT
	Generate the output ascii file for on line reports.

  ARGUMENTS
	data type	argument	I/O	description

	IGRlong         *msg            O :	Completion code

	IGRchar         filename        I :	Output file name.

	IGRshort        state           I :	Simple filter
						 (SM_NEW, SM_MOD, SM_UPD)
	IGRshort        options         I :	Report type (SMdef.h). 

	IGRshort	type		I :	Type of objects (SMdef.h). 

	IGRshort	sub_type	I :	Sub-type of objects (SMdef.h)

	IGRboolean 	tag		I :	TRUE => the tag method.

	IGRshort	out_units	I :	Output units.

	GRmdenv_info	*trans_mat      I :	Transformation matrix (& type).

	IGRchar         DescFilename    I :	If option == SM_USR_DEF_RPT
						(user defined) description
						filename.

  REMARKS
	Use type = "FFFF" and sub_type = "FFFF" to get all the components.


  ---------------------------------------------------------------------------*/

#omdef SM$Report(msg,
                filename     = "report_file",
	        state        = 0xFFFF, 
	        options      = SM_ASCII_FILE, 
                type         = 0xFFFF, 
	        sub_type     = 0xFFFF,
	        tag	     = FALSE,
	        out_units    = SM_UNIT_INT,
	        trans_mat    = NULL,
                DescFilename = NULL,
	        rel_numb     = 0)

	SMReport((msg), (filename), (state), (options), (type),
		(sub_type), (tag), (out_units), (trans_mat),
		(DescFilename), (rel_numb));
#endomdef

/* ---------------------------------------------------------------------------*/

#endif

