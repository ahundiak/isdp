/* $Id: vdrptmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	$VDS/include/vdrptmacros.h
 *
 * Description:
 *		This file contains the macro used to generate an output
 *		report;
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdrptmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/11/04  17:44:10  pinnacle
 * Created: include/vdrptmacros.h by v250_int for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/28/97	adz		creation date
 ***************************************************************************/

#ifndef vdrptmacro_include
#define vdrptmacro_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VD_reportObjects __((
			    	FILE			*infile,
				FILE			*outfile,
				int			nbOjs,
				struct GRobj_env	*objList
				)) ;

extern int VD_reportHeader __((
				FILE			*rF,
				char			*title
				));

extern int VD_reportObjectsToASCII __((
				IGRlong			*msg,
				IGRchar			*fFpath,
				IGRchar			*fFname,
				IGRchar			*rFname,
				IGRchar			*title,
				IGRint			nbObjs,
				struct GRobj_env	*objList
				));

#if defined(__cplusplus)
}
#endif

/*============================================================================*/
/* ---------------------------------------------------------------------------

MARCO

    vd$create_report (  );

ABSTRACT
     
    This macro creates a ASCII report, based on an "report layout" file
	and a set objects.

ARGUMENTS

        DATA TYPE	ARGUMENT	I/O	DESCRIPTION
        long		*msg		O	return message. 
	IGRchar		*fFpath		I	Report Output Path; 
						NULL -> Active Directory.
	IGRchar		*fFname		I	Report Output Filename.
	IGRchar		*rFname		I	Report Layout Filename.
	IGRchar		*title		I	Title name on report.
	int		nbObjs		I	Number of Input objects.
	struct GRobj_env *objList	I	List of input objects.

EXAMPLE

        vd$create_report(	msg		= &msg,
				fFpath		= "/usr2/reports",
				fFname		= "equip.info",
				rFname		= "report.eq",
				title		= "Equipment Report",
				nbObjs		= count,
				objList		= list );

REMARKS

	'*fFpath' will be optiona; When NULL, '*rFname' will be placed in
	current working directory.
	'*title' will be optional; When NULL, no title block section
	will be generated;
	'rFname' will be checked in the active file and in the product
	sub-directory "./config/reports" of available products.

Return Status

        OM_S_SUCCESS	if report is created
	OM_E_ABORT	if failure during process.

---------------------------------------------------------------------------- */

#omdef vd$create_report(	msg,
				fFpath	= NULL,
				fFname,
				rFname,
				title	= NULL,
				nbObjs,
				objList )

       VD_reportObjectsToASCII( (msg), (fFpath), (fFname), (rFname),
				(title), (nbObjs), (objList) )
#endomdef

/*============================================================================*/

#endif
 
