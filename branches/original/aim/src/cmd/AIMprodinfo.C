/* $Id: AIMprodinfo.C,v 1.1.1.1 2001/06/01 20:06:28 tlstalli Exp $  */

/* --------------------------------------------------------------------
 * I/AIMSIR
 *
 * File:	src/cmd/AIMSIRprodinfo.C
 *
 * Description:
 *		This file consists of function to get product info 
 *              for example checks if product is active   
 *		If the product is active, is optinally retruns
 *		config path of the product.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: AIMprodinfo.C,v $
 *	Revision 1.1.1.1  2001/06/01 20:06:28  tlstalli
 *	Creating aim module
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 */

/*============================================================================*/
/*                             IMPLEMENTATION FUNCTIONS                       */
/*============================================================================*/

#include <sys/types.h>
#include <dirent.h>
#include "DIdef.h"
#include "EXproduct.h" 
#include "exproto.h" 
#include "exmacros.h"
#include "OMerrordef.h"
#include "AIMincludes.h"

#include "vadbgmacros.h"

#define AIM_DLOAD_DIR                   "config/dload/corrections"

extern struct EX_prod_def  *EX_product_list;
extern char	           EX_runname[];

/*----------------------------------------------------------------------------*/
int 	AIM_getProdInfo(	IGRchar     *run_name,
				IGRchar     *logo,
				IGRchar     *conf_path ){

	struct EX_prod_def	*prodDef;
	IGRchar			config_path[512];
	IGRint			name_found = FALSE;
	IGRint			prod_found = FALSE;
	IGRint			i;
	IGRlong			sts = OM_S_SUCCESS ;
	IGRchar			name[512];

	SetProc( AIM_getProdInfo ); Begin

	if( ( run_name == NULL ) && ( logo == NULL ) ){
		__DBGpr_com(" Invalid Arguments" );
		return OM_E_INVARG ;
	}

	if( conf_path != NULL ){ *conf_path = '\0';  }
 
	prodDef    =  EX_product_list;

	if( run_name )	__DBGpr_str(" Run_Name ", run_name );
	if( logo     )	__DBGpr_str(" LOGO     ", logo );

	while( prodDef ){

	  __DBGpr_str("   RUN_NAME ",  prodDef->run_name);
	  __DBGpr_str("   LOGO_PTR ",  prodDef->logo);

	  if(( run_name && (!strcmp(prodDef->run_name, run_name))) || 
             ( logo     && (!strcmp(prodDef->logo, logo)))){

	    name_found = TRUE;

#ifdef exrDEBUG
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

	if ( !name_found ) return OM_E_NOTIMPL ;

	__DBGpr_str( "Checking path", config_path );

	i = 0;
	sts = OM_S_SUCCESS;
	while ( sts ){

	  sts = ex$get_path( index = i , path = name, len = sizeof(name) );

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
	if( prod_found ){
	  if ( conf_path != NULL ){
		strcpy ( conf_path, config_path );
		__DBGpr_str(" CONFIG ", conf_path );
	  }
	  End ;
	  return OM_S_SUCCESS ;
	}
	else{
	  End ;
	  return OM_E_NOTIMPL ;
	}
}

/*----------------------------------------------------------------------------*/
long	AIM_prdLoadCorrections( run_name )

IGRchar		*run_name;
{
	IGRint			sts = OM_S_SUCCESS ;
	IGRchar			loadDir[DI_PATH_MAX],
				stsMess[256],
				loadFl[256];
	IGRint			len;
	DIR			*dirp;
	struct dirent		*dp;
	int			nbytes;


	SetProc( AIM_prdLoadCorrections ); Begin

	sts =
	AIM_getProdInfo( run_name, NULL, loadDir );
	if( !sts )	return OM_S_SUCCESS ;

	strcat( loadDir, AIM_DLOAD_DIR );

	if( dirp = opendir (loadDir)){

	  strcpy(loadFl, loadDir);
	  strcat(loadFl, "/");
	  nbytes = strlen(loadFl);

	  while (dp = readdir(dirp)){

	    len = strlen (dp->d_name);
#if defined(CLIX) || defined(IRIX4)
	    if (len >= 2 && 'o' == *(dp->d_name + len-1) && '.' ==
	      *(dp->d_name + len-2))
#elif defined(SUNOS) || defined (IRIX5)
	    if (len >= 3 && 'o' == *(dp->d_name + len-1) && 's' ==
	      *(dp->d_name + len-2) && '.' == *(dp->d_name + len-3))
#endif
	    {
		strcpy(&loadFl[nbytes], dp->d_name);
		sprintf( stsMess, "Loading: %s ", loadFl );
		UI_status( stsMess );
		ems_dload ( loadFl );
	    }
	  }
	  closedir(dirp);
	}

	End ;
	return OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

