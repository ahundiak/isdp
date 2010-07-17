/*
	I/STRUCT
	2/21/96	Raju		Implementation of p_macro attribute
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "DIdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsRDBdef.h"
#include "vsRISmacros.h"
#include "vsRDBmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsRDBproto.h"
#include "vsstrngproto.h"

/*----------------------------------------------------------------------------*/
long VSgetPpartData( msg, errStr, family, material, part, file, size,
					p_count, pmNames, pmValues )

long	*msg ;
char	*errStr,
	*family,
	*material,
	*part,
	*file ;
int	size,
	*p_count ;
char	*pmNames[] ;
double	pmValues[] ; {

	long	sts ;
	char	
		where		[VS_K_MAX_CHARS],
		select		[VS_K_MAX_CHARS],
		macropartno	[VS_K_MAX_CHARS],
		macrorev	[VS_K_MAX_CHARS],
		macrocat	[VS_K_MAX_CHARS],
		f_macrocat	[VS_K_MAX_CHARS],
		macro_name	[VS_K_MAX_CHARS],  /* added 12/21/1995 */
		**list		= NULL,
		*templates	[1+VS_K_MAX_PARMS],
		**parms,
		macLibName	[1+DI_PATH_MAX] ;
	int	nbParms,
		i,
		count	= 0 ;

	if( errStr ) *errStr = '\0' ;

	/*
	 * get macro name ( specified by p_macro attribute ) for the
	 * part.
	 */
	sts = VSgetMacroNameFromPmacro( family, material, part, macro_name );
	if ( !(sts&1) )
	{
	   printf("%s[%d] : Error getting macro_name for the part\n",
		  __FILE__, __LINE__ );
	   *msg = MSFAIL;
	   goto wrapup;
	}

	/*
	 * Retrieve the name of the macro library from the f_<family> table.
	 */

	/*
	 * SELECT	p_macrocat,p_macropartno,p_macrorev
	 * FROM		pdmparamloc
	 * WHERE	n_catalogname='<family>'
	 */

	sprintf( where, "%s='%s'", PDU_NFM_CATALOG_NAME, family ) ;

	sprintf( select,"%s,%s,%s", VS_K_PDM_macroCat, VS_K_PDM_macroPartno,
		 VS_K_PDM_macroRev ) ;

	sts = vs$RISquery(	table	= VS_K_PDM_pdmparamloc,
				select	= select,
				where	= where,
				nbAttrs	= 3,
				p_count	= &count,
				p_list	= &list ) ;
	if( !sts ) goto SQLERR ;

	vs$RISextractVal(	count		= count,
				list		= list,
				nbAttrs		= 3,
				whichAttr	= 0,
				whichVal	= 0,
				value		= macrocat ) ;

	vs$RISextractVal(	count		= count,
				list		= list,
				nbAttrs		= 3,
				whichAttr	= 1,
				whichVal	= 0,
				value		= macropartno ) ;

	vs$RISextractVal(	count		= count,
				list		= list,
				nbAttrs		= 3,
				whichAttr	= 2,
				whichVal	= 0,
				value		= macrorev ) ;

	VSfreeList( count, list ) ; count = 0 ; list = NULL ;

	/*
	 * SELECT	n_itemno
	 * FROM		<macrocat>
	 * WHERE		n_itemname='<macropartno>'
	 *		AND	n_itemrev='<macrorev>'
	 */
	sprintf( where, "%s='%s' AND %s='%s'",
			 PDU_PARTID_ATTR	, macropartno,
			 PDU_REVISION_ATTR	, macrorev ) ;

	sts = vs$RISquery(	table	= macrocat,
				select	= PDU_NFM_ITEM_NO,
				where	= where,
				p_count	= &count,
				p_list	= &list ) ;
	if( !sts ) goto SQLERR ;

	sprintf( f_macrocat, "f_%s", macrocat ) ;

	sprintf( where, "%s=%s", PDU_NFM_ITEMNUM, list[0] ) ;

	VSfreeList( count, list ) ; count = 0 ; list = NULL ;

	/*
	 * SELECT	n_cofilename
	 * FROM		f_<macrocat>
	 * WHERE	n_itemnum=<item number>
	 */
	sts = vs$RISquery(	table	= f_macrocat,
				select	=  PDU_FILENAME_ATTR,
				where	= where,
				p_count	= &count,
				p_list	= &list ) ;

	if( !sts ) {
		SQLERR :
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_QyLibFailed,
					type	= "%s",
					var	= `macro_name`,
								/* `family`, */
					buff	= errStr ) ;
		}
		goto wrapup ;
	} else if( !count ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_NoMacLib,
					type	= "%s",
					var	= `macro_name`,
								/* `family`, */
					buff	= errStr ) ;
		}
		goto wrapup ;
	}

	strcpy( macLibName, list[0] ) ;
	VSfreeList( count, list ) ; count = 0 ; list = NULL ;

	if( file ) strcpy( file, macLibName ) ;

	vs$getTemplateNames(	msg		= msg,
				macLib		= macLibName,
				macDefName	= macro_name,   /* family, */
				size		= size,
				p_count		= &nbParms,
				templates	= templates ) ;
	if( !( *msg & 1 ) ) {
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_NoDataFrMac,
					type	= "%s%s",
					var	= `macro_name,macLibName`, 
							/*`family,*/
					buff	= errStr ) ;
		}
		goto wrapup ;
	}

	/*
	 * Get value for each template but the 1st one : the 1st one is a
	 * coordinate system, the other ones are parameters.
	 */
	nbParms-- ;
	if( nbParms > size ) nbParms = size + 1 ;

	parms = templates + 1 ;

	for( i = 0 ; i < nbParms ; i++ ) {

		/*
		 * Get value of parameter from the data base :
		 * SELECT	<param>
		 * FROM		<family>
		 * WHERE		n_itemname= '<part>'
		 *		AND	n_itemrev = '<material>'
		 */
		sprintf( where, "%s='%s' AND %s='%s'",
				PDU_PARTID_ATTR, part,
				PDU_REVISION_ATTR, material ) ;

		sts = vs$RISquery(	table	= family,
					select	= parms[i],
					where	= where,
					p_count	= &count,
					p_list	= &list ) ;
		
		if( !sts ) {
			*msg = MSFAIL ;
			if( errStr ) {
				ex$message(	msgnumb	= VS_gW_QyMacPmFailed,
						type	= "%s%s",
						var	= `parms[i],family`,
						buff	= errStr ) ;
			}
			goto wrapup ;
		} else if( !count ) {
			*msg = MSFAIL ;
			if( errStr ) {
				ex$message(	msgnumb	= VS_gW_NoMacPmVal,
						type	= "%s%s",
						var	= `parms[i],family`,
						buff	= errStr ) ;
			}
			goto wrapup ;
		}
		if( pmNames ) {
			pmNames[i] = parms[i] ;
		}
		pmValues[i] = atof( list[0] ) ;
		VSfreeList( count, list ) ; count = 0 ; list = NULL ;
	}

	*p_count = nbParms ;
	*msg = MSSUCC ;

	wrapup :
		return *msg & 1 ;

} /* VSgetPpartData */
/*----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Desc : This function gets macro name ( specified by p_macro attribute )
       for the part.

Note : If p_macro attribute is not found, then family name is returned as 
       macro_name.

Return Status :  OM return status

History :	 2/21/96     Raju  Creation

------------------------------------------------------------------------------*/
long VSgetMacroNameFromPmacro(
  char	*family,	  /* I - family of the part		    */
  char	*material,	  /* I - material of the part ( part rev ) */
  char	*part,		  /* I - part Id			    */
  char	*macro_name	  /* O - name of macro(specified by p_macro attrib ) */
)
{
	long	sts ;
	char
		where		[VS_K_MAX_CHARS],
		select		[VS_K_MAX_CHARS],
		**list		= NULL;

	int	count	= 0 ;

  sts = OM_S_SUCCESS;

  strcpy( macro_name, family );

  /*
   * See if p_macro attribute has been deefined for the given part
   */
  sprintf ( where,
	    "nfmattributes.n_tableno = nfmtables.n_tableno and \
	    nfmtables.n_tablename = '%s' and n_name = 'p_macro'",
	    family );

  sts =
  vs$RISquery  (  select      =      "n_name,n_datatype",
		  table       =      "nfmattributes,nfmtables",
		  where       =      where,
		  nbAttrs     =      2,
		  p_count     =      &count,
		  p_list      =      &list );


  if ( sts != 1  || count == 0  )
  {
     sts = OM_S_SUCCESS;
     goto wrapup;
  }

  /* count != 0,  p_macro is defined for the part */
  /* count is not set to '0' here. It is set inside 'if ( count )' block */
  VSfreeList( count, list ) ;
  list = NULL ;

  if ( count )
  {
	/*
	 * get macro_name from p_macro attribute
	 * SELECT  p_macro  FROM  <family> WHERE 
	 * 				   n_itemname='<macropartno>'
	 *			  AND	   n_itemrev='<macrorev>'
	 */

	sprintf( where, "%s='%s' AND %s='%s'",
			PDU_PARTID_ATTR, part,
			PDU_REVISION_ATTR, material ) ;
	sprintf( select,"p_macro" );

	count = 0;
	sts = vs$RISquery(	table	= family,
				select	= select,
				where	= where,
				p_count	= &count,
				p_list	= &list ) ; 

	if ( sts ==  1 && count != 0 )
		strcpy( macro_name, list[0] );

	VSfreeList( count, list ) ; count = 0 ; list = NULL ;
  }

wrapup:
  return sts;

} /* VSgetMacroNameFromPmacro */
/*----------------------------------------------------------------------------*/
