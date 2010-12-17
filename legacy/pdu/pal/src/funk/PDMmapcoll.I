/***********************************************************************************/
/*   This file contains routines for getting the mapping of a given attribute to a */
/*   collection in the list of collections and other collection related functions  */
/*                                                                                 */
/*     File Creation date 05/12/92            DKK (IGI)                            */
/***********************************************************************************/

class implementation ACdyn_col ;

#include "AS_status.h"
#include "exmacros.h"
#include "expmacros.h"
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <sys/types.h>
#include <sys/dirent.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMmacros.h"
#include "madef.h"
#include "msdef.h"
#include "MOmacros.h"

#include "parametric.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "expmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "macro.h"
#include "PDUstr.h"
#include "PALglbs.h"
#include "ACattrib.h"
#include "ACdyn_col.h"

/* mold include files */
#include "msdef.h"
#include "msmacros.h"
#include "PALmsg.h"
#include "FI.h"
#include "CIforms.h"
#include "expression.h"
#include "PDUfile_def.h"
#include "MEMerrordef.h"


#include "MEMstruct.h"

/*#include "PDUproto.h"*/
#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"


#define	EXP_DOUBLE	0
#define EXP_TEXT	4

#define	TAB_MAX_VALUES	20

from ACcpx import ACfind_temp_obj;
from  ACcpx_defn   import ACgive_temp_desc ;


CreateCollections ( env, list_coll, num_coll ) 
struct GRmd_env *env;         /* I */
int    num_coll;      	      /* I */
struct GRid **list_coll;      /* O */
{
	int i;

	*list_coll = (struct GRid *)malloc( sizeof(struct GRid) * num_coll);
	MemCheck( *list_coll );

	/* Now create num_coll dyncols */
	for( i = 0; i < num_coll; i++ )
	{
		(*list_coll)[i].objid = NULL_OBJID ;

		if( ! PDUcreat_rgbox("", env, &(*list_coll)[i] ) ) 
		{
			_pdm_debug("PDUcreat_rgbox failed",0);
			MyFree( *list_coll );
			return(0);
		}
	}

	return(1);
} 

/* This function is meant to get the ACdyncols' number to which a template
   is mapped to (double and text type only).

   What about the catalog attributes and the dynamic attributes that are not
   templates of the macro??

   All the catalog attributes that are not templates to the macro are 
   mapped on to the FIRST collection
	and
   All the dynamic atttributes that are not templates to the macro are
   mapped on to the LAST collection.
*/ 

GetDyncolIndx( temp_desc, attr, num_org_temp, num_loc_temp,  dyn_num ) 
char *attr;
int *dyn_num;
struct stemp *temp_desc;
int num_org_temp, num_loc_temp;
{
int i;
/* TR # 13941 8495.	*/
char	temp_name[32], attr_name[32];
char	*to_lower();

	_pdm_debug("Get mapping of attribute %s", attr );
	for( i = 0 ; i < num_org_temp ; i++ )
	{
		if( !(temp_desc[i].type & parameter_generic ) )
			continue;
/* TR# 	13941 8495. Attribute name could have been to lower case.
Conver to lower case before comparison. */
/*		if( !strcmp( temp_desc[i].name, attr ) )*//* Found match */
		strcpy(temp_name, temp_desc[i].name);
		strcpy(attr_name, attr);
		to_lower(temp_name);
		to_lower(attr_name);
		if( !strcmp(temp_name, attr_name ) )	/* Found match */
		{
			_pdm_debug("Found matching template %s", temp_desc[i].name);
			*dyn_num = temp_desc[i].back - num_loc_temp;	
/* TR# 	13941 8495. Attribute name could have been to lower case,
replace with actual template name from macro definition, since
this is how it is to be posted in the ACdyn_col and looked for by
the macro during its compute. */
			strcpy(attr, temp_desc[i].name);
			break;
		}
	}
	if( i == num_org_temp ) /* No match, Not a template to macro */
	{
		_pdm_debug("Attribute %s not mapped to any Collection",attr);
		return( -1 );
	}
	_pdm_debug("Attribute %s mapped to ...",attr);
	_pdm_debug("...Collection %d",*dyn_num );

	return( 1 );
}

/* Given attribute name, gets the value and type of attribute */
GetNamedAttribValue(BOX,att_name,att_value,attr_type)
char          *att_name , *att_value ;
struct GRid   *BOX ;
int           *attr_type ;
{
struct	ACrg_coll	attrib;
int           sts ;
IGRlong	      msg ;

	strcpy(attrib.name,att_name);

	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
						( &msg, &attrib ),
				senderid = BOX -> objid,
				targetid = BOX -> objid,
				targetos = BOX -> osnum );

	_MO_omerr_chk("ACrg_collect.ACget_named_attribute:", sts, wrapup);

	if( attrib.desc.type & AC_ATTRIB_MASK_TYPE 
						& AC_ATTRIB_DOUBLE )
	
		sprintf(att_value,"%lf",attrib.desc.value.att_exp );
	else
		strcpy(att_value,attrib.desc.value.att_txt );

	*attr_type = attrib.desc.type;
	
	return(1);
wrapup:
	return(0);
}

get_temp_index(temp_desc, temp_name, num_org_temp )
char 	temp_name[] ;
struct  stemp *temp_desc;
int	num_org_temp;
{
    int i ;

#ifdef DEBUG
    printf("  temp_name:%s\n ",  temp_name);
#endif

    for ( i = 0 ; i < num_org_temp ; i = i + 1 ) 
	if( ! strcmp(temp_name, temp_desc[i].name) )
              return(i);
    return(-1);

}

GetMacroTempDesc(hdr, temp_desc, numtemp)
int *numtemp;
struct GRid *hdr ;
struct stemp **temp_desc;
{
	int sts ;
	struct stemp *tdesc;

	sts = om$send( msg = message ACcpx_defn.ACgive_temp_desc(numtemp,
								&tdesc),
                      senderid = hdr -> objid,
                      targetid = hdr -> objid,
                      targetos = hdr -> osnum );

	_MO_omerr_chk("ACgive_temp_desc : getmacrotempdesc", sts, wrapup);

	*temp_desc = tdesc;

#ifdef DEBUG
	for(sts=0;sts<*numtemp;sts++)
		printf("templ[%d]=%s\n",sts,(*temp_desc)[sts].name);
#endif

	return(1);
wrapup:

	return(0);
}

GetNumLocatable( temp_desc, num_org_temp, numloc )
struct stemp *temp_desc;
int num_org_temp;
int *numloc;
{
int i;

/* Here it is assumed that all macro_generic type templates are not locatable */

	*numloc = 0;
	for( i = 0 ; i < num_org_temp ; i++ )
		if( ( temp_desc[i].type & parameter_generic ) ||
			( temp_desc[i].type & macro_generic) ) 
			continue;
		else
			(*numloc)++;

	_pdm_debug("No. of locatable templates = %d\n", *numloc );

	return (1);
}			

GetOriginalMacroInfo ( hdr, temp_desc, num_org, num_loc, num_coll)
struct GRid *hdr;
struct stemp **temp_desc;
int *num_org, *num_loc, *num_coll;
{
int tmp, i;

	/* Get original template description as exists at creation time */
	if (!GetMacroTempDesc( hdr, temp_desc, num_org ))
		return (0); 

	/* Now get the number of locatable type templates */
	if (!GetNumLocatable( *temp_desc, *num_org, num_loc))
		return (0);

	/* 23/Dec/93 - raj. This no longer works. COMMENTED THE FOLLOWING SECTION. */
	/* Now get the number of collections 	
*	tmp = (*temp_desc)[0].back ;
*	for( i = 1; i < *num_org; i++ ) 
*		if( (*temp_desc)[i].back > tmp )
*			tmp = (*temp_desc)[i].back ;
* 
* 	*num_coll = tmp - *num_loc + 1;
*/

	/*
	 * 23/Dec/93 - raj. Now the (*temp_desc)[i].back has an index value for
	 * each of the templates whether they are collection or not. Since the
	 * locatables are decided by by the fact that they are not of type
	 * macro_generic, ( see function GetNumLocatable() ), let us consider
	 * ALL macro_generic templates to be collections.
	 */
	*num_coll = 0;
	for (i = 0; i < *num_org; i++ )
	{
          if ((*temp_desc)[i].type == macro_generic)
          {
            (*num_coll)++;
          }
        }

	_pdm_debug( "No. of collections = %d",*num_coll );

	return (1);
}



end implementation ACdyn_col;
