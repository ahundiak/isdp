/* $Id: vdprdmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* I/VDS
 *
 * File:        ~VDS/include/vdprdmacros.h
 *
 * Description: This file is the include file for macros that
 *              give product info 
 *
 * Revision History:
 *	$Log: vdprdmacros.h,v $
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
 * Revision 1.4  1995/08/21  16:27:56  pinnacle
 * Replaced: include/vdprdmacros.h for:  by azuurhou for vds.240
 *
 * Revision 1.3  1995/08/10  18:31:38  pinnacle
 * Replaced: include/vdprdmacros.h for:  by azuurhou for vds.240
 *
 * Revision 1.2  1994/12/21  22:30:22  pinnacle
 * Replaced: include/vdprdmacros.h by azuurhou r#
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *      10/10/94        Chaya V. Rao	first version.
 *	08/21/95	adz		add I/LOFT to package.
 *
 */

/*============================================================================*/

#ifndef vdprdmacros_include
#define vdprdmacros_include

# define    VD_PROD_NAME_VDS            "Vds"
# define    VD_PROD_NAME_STRUCT         "Struct"
# define    VD_PROD_NAME_ROUTE          "Route" 
# define    VD_PROD_NAME_LOFT           "Loft" 
# define    VD_PROD_LOGO_VDS            "I/VDS"
# define    VD_PROD_LOGO_STRUCT         "I/STRUCT"
# define    VD_PROD_LOGO_ROUTE          "I/ROUTE" 
# define    VD_PROD_LOGO_LOFT           "I/LOFT" 

/*
 * product sub-directory names:
 */
#define   VDS_DLOAD_DIR  "corrections"	/* used to load product .o files after
					   initialization.
					 */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern int VDprd_get_product_info __(( IGRchar     *run_name,
                                       IGRchar     *logo,
				       IGRchar	   *conf_path ));

extern int VDprd_dload_corrections __((IGRchar	   *run_name ));


#if defined(__cplusplus)
}
#endif

/*============================================================================*/

/*----------------------------------------------------------------------------

  MACRO

     vd$prd_get_product_info(  );
   
  ABSTRACT

     gets the product info. For example if product logo or product
     run_name is given, finds if product is active. Also returns
     config path ( eg. for Vds, /usr/ip32/vds ) optionally.
  
  ARGUMENTS
 
     data type         argument     I/O    description

     IGRchar           *run_name    I     run_name of product 
     IGRchar           *logo        I     logo of product
     IGRchar	       *conf_path   O     config path of the product
					  if the product is active.
					  = NULL, if not needed.


  EXAMPLE
    
     status = vd$prd_get_product_info( logo    = VD_PROD_LOGO_VDS );

  REMARKS
     
     logo and run_name can be one of the names defined above

  Return Status
     TRUE            if product found
     FALSE           if product not found
     OM_W_ABORT      other errors

----------------------------------------------------------------------------*/
/*===========================================================================*/

#omdef  vd$prd_get_product_info(
				run_name   =   (char *)NULL ^
				logo       =   (char *)NULL ,
				conf_path  =   NULL )

        VDprd_get_product_info( (run_name), (logo), (conf_path) )

#endomdef

/*============================================================================*/ 
/*----------------------------------------------------------------------------

  MACRO

     vd$prd_load_corrections(  );
   
  ABSTRACT

     Load possible correction file, written in the directory:

	./config/dload/corrections

     into the product. This avoid to load manual "z d l = filename",
     all the files after a strtup session.

     This allows also to load functions, written by user to load, which
     can be called by ppl commands.

  ARGUMENTS
 
     data type         argument     I/O    description

     IGRchar           *run_name    I     run_name of product 

  EXAMPLE
    
     status = vd$prd_load_corrections( run_name = VD_PROD_NAME_VDS );

  REMARKS
     
     logo and run_name can be one of the names defined above

  Return Status
     TRUE            if product found
     FALSE           if product not found
     OM_W_ABORT      other errors

----------------------------------------------------------------------------*/

/*===========================================================================*/

#omdef  vd$prd_load_corrections( run_name   =   (char *)NULL ) 

        VDprd_load_corrections( (run_name) )

#endomdef

/*============================================================================*/ 
#endif 
