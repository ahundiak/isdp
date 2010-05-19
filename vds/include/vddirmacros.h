/* $Id: vddirmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / vddirmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddirmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
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

#ifndef vddirmacro_include
#define vddirmacro_include

/* I/VDS
 *
 * File:        ~VDS/include/vddirmacro.h
 *
 * History:
 *      08/07/94        Ad Zuurhout
 *
 */

/*============================================================================*/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

int	VDdir_update_form __((void));

#if defined(__cplusplus)
}
#endif

/*============================================================================*/
/* -----------------------------------------------------------------------------

  MARCO
	vd$dir_update_form (  );

  ABSTRACT

	Update the I/EMS and I/VDS display directory command form.

  ARGUMENTS
        
        data type         argument     I/O    description

	none.

  EXAMPLE
        
	sts = vd$dir_update_form ();
	
  REMARKS

  Return Status
        OM_S_SUCCESS    	Allways.
    

  ------------------------------------------------------------------------- */

#omdef	vd$dir_update_form ( )
                             
	VDdir_update_form( )

#endomdef

/*============================================================================*/

#endif
