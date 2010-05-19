/* $Id: VDprdMacFn.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDprdMacFn.I
 *
 * Description: This file consists of function to get product info 
 *              for example checks if product is active   
 *		If the product is active, is optinally retruns
 *		config path of the product.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDprdMacFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
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
# Revision 1.2  1995/08/21  16:28:26  pinnacle
# Replaced: vdutil/VDprdMacFn.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      29/09/94      Chaya V.Rao  	creation date
 *      10/16/94	Raju		Added conf_path argument.
 *	08/16/95	adz		Conifg_path initialization.
 *
 */

/*============================================================================*/
/*                             IMPLEMENTATION FUNCTIONS                       */
/*============================================================================*/

 /*+fe
  Function VDprd_get_product_info( )

  Macro Name
        vd$get_product_info(  );

  Abstract
        gets the product info. For example if product logo or product
        run_name is given, finds if product is active
  Arguments
        data type         argument     I/O    description

        IGRchar           *run_name    I     run_name of product
        IGRchar           *logo        I     logo of product
	IGRchar		  *conf_path   O     config path of the product
					     if the product is active.
					     NULL, if not interested

  Returns
     TRUE            if product found
     FALSE           if product not found/invalid arguments.

-fe*/

/*===========================================================================*/

class implementation Root;

#include <stdio.h>
#include <string.h>

#include "EXproduct.h" 
#include "exproto.h" 
#include "exmacros.h"
#include "v_dbgmacros.h"
#include "OMerrordef.h"

extern struct EX_prod_def  *EX_product_list;
extern char	           EX_runname[];

#include  "v_dbgmacros.h"

/*===========================================================================*/

int VDprd_get_product_info(	IGRchar     *run_name,
				IGRchar     *logo,
				IGRchar     *conf_path ){

   struct EX_prod_def   *prodDef;
   IGRchar      	config_path[512];
   IGRint       	name_found = FALSE;
   IGRint               prod_found = FALSE;
   IGRint               i;
   IGRlong              status;
   IGRchar		name[512];

   SetProc( VDprd_get_product_info ); Begin

   if( ( run_name == NULL ) && ( logo == NULL ) ){
	__DBGpr_com(" Invalid Arguments" );
	return FALSE ;
   }

   if( conf_path != NULL ){ *conf_path = '\0';  }
 
   prodDef    =  EX_product_list;

   if( run_name )	__DBGpr_str(" Run_Name ", run_name );
   if( logo	)	__DBGpr_str(" LOGO     ", logo );

   while (prodDef)
   {
      __DBGpr_str("   RUN_NAME ",  prodDef->run_name);
      __DBGpr_str("   LOGO_PTR ",  prodDef->logo);

      if (( run_name && (!strcmp(prodDef->run_name, run_name))) || 
          ( logo     && (!strcmp(prodDef->logo, logo))))
      {
	    name_found = TRUE;

#ifdef vdsDEBUG
            __DBGpr_str("===run_name     ",  prodDef->run_name);
            __DBGpr_str("===logo_ptr     ",  prodDef->logo);
            __DBGpr_str("===module_class ",  prodDef->module);
            __DBGpr_str("===search_path  ",  prodDef->srch_path);
            __DBGpr_str("===config_path  ",  prodDef->config_path);
            __DBGpr_str("===product_path ",  prodDef->product_path);
	    __DBGpr_int("===license      ",  prodDef->license );
	    __DBGpr_int("===status       ",  prodDef->status );
	    __DBGpr_int("===flags        ",  prodDef->flags );
	    __DBGpr_com(" \n\n");
#endif
	    strcpy( config_path , prodDef->config_path);
            break;

      }
      prodDef = prodDef->next;
   }

   if ( !name_found ) return FALSE;

   __DBGpr_str( "RUNNAME", EX_runname );

   i = 0;
   status = 1;
   while ( status )
   {
      status = 
      ex$get_path(	index	= i ,
			path	= name,
			len	= sizeof(name) );

      __DBGpr_int ( "Path no", i );
      __DBGpr_str ( "Config path", name );

      if( !strcmp( name, config_path )){

         __DBGpr_com("FOUND PRODUCT");
         prod_found = TRUE;
         break;

      }
      i++; 
   }

   /*
    * Give return value.
    */
   if( prod_found ) 
   {
	if ( conf_path != NULL ){
		strcpy ( conf_path, config_path );
		__DBGpr_str(" CONFIG ", conf_path );
	}
	End ;
	return TRUE ;
   }
   else return FALSE ;
}

/*===========================================================================*/
end implementation Root;
/*===========================================================================*/

