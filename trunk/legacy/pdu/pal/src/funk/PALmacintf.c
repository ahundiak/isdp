/******************************************************************************

 This module contains routines for placing a part through a macro interface 

	Creation  -  dkk  - 10/15/92

******************************************************************************/

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <PDUstr.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"
#include "PALglbs.h"
#include "PDUerror.h" 
#include "PDUstr.h"
#include "MEMerrordef.h"
#include "PALmsg.h"
#include "ACattrib.h"
#include "PDUcommand.h"
#include "PDUfile_def.h"
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif

/*#include "PDUproto.h" */
#include "PALfunkpro.h"
#include "PALpdmrpro.h"

#define EXP_MAX_LEN 80

static char **dyn_attrs, **dyn_attr_types, **dyn_attr_values;
static int  num_dyn;
static struct GRid *grids;
static int  nogrids;
static struct GRmd_env *genv;


extern struct PDUrefresh *refresh;
extern int    PALMacintf;
extern int	PDU_command             ;

PlprtThruMacro( cat, id, rev, md_env, gridlst, no, attrs, types, vals, noattrs )
char *cat, *id, *rev;    	/* I */
struct GRmd_env *md_env;    	/* I */
struct GRid *gridlst;    	/* I (locatable dynamic templates list) */
char **attrs, **types, **vals;  /* I (other dynamic attributes) */
int no, noattrs;    		/* I */
{
	grids = gridlst;
	nogrids = no;

	dyn_attrs = attrs;
	dyn_attr_types = types;
	dyn_attr_values = vals;
	num_dyn = noattrs;

	genv = md_env;
/*
	if( !PALplace_part( cat, id, rev, md_env, NULL, 1 ) )
		return( 0 );
*/
	mystrcpy( &refresh->rev_partid, id );
	mystrcpy( &refresh->rev_catalog, cat );
	mystrcpy( &refresh->rev_revision, rev );

	{
		int             responses[1];
		char            *strings[1];		

			PALMacintf = 1;
			PDU_command = PDC_M_PLACE_PPART;
			responses[0] = EX_CMD_KEY;
			strings[0] = "PDPPPr";

		PDUprepare_queue(responses,strings,1);
		return(1);
	}
}

/*
   This routine adds the dynamic attributes + the description template(s) +
   the no. of such description template(s) to the ACdyncol, increments the
   number to templates to the macro by 1 (ACdyncol) and adds ACdyncol to 
   gridlist
*/

AddDynattrsToColl( temp_desc, dyncol, num_coll, num_org_temp, num_loc, gridlist, numtemp )
struct GRid *dyncol;       /* I */
int        num_coll;       /* I */
struct stemp *temp_desc;   /* I */
int num_org_temp, num_loc; /* I */
struct GRid **gridlist;    /* O */
int *numtemp; 		   /* O */
{
struct GRid **exp_list;
int    sts, i, exptype;
char   **attr_desc, tmp[10];
int    *lsize, colno;

	/* Now realloc to the global grids for including ACdyncol's grid */

	*gridlist = grids;

	*gridlist = (struct GRid *)realloc(*gridlist,
					( nogrids + num_coll) * sizeof( struct GRid ));
	MemCheck( *gridlist );

	for(i = 0; i < num_coll; i++)
		(*gridlist)[nogrids+i] = dyncol[i];
	*numtemp = nogrids + num_coll;

	/* Build the templates of the ACdyncol */
	exp_list = (struct GRid **)malloc( sizeof(struct GRid *) * num_coll ); 
	MemCheck( exp_list );
	attr_desc = (char **)malloc( sizeof(char *) * num_coll ); 
	MemCheck( attr_desc );
	lsize = (int *)malloc( num_coll * sizeof(int) );
	MemCheck( lsize );

	for( i = 0; i < num_coll; i++ )
	{
		exp_list[i] = (struct GRid *)malloc(sizeof(struct GRid)); 
		MemCheck( exp_list[i] );
		attr_desc[i] = (char *)malloc(sizeof(char)); 
		MemCheck( attr_desc[i] );
		lsize[i] = 0;
		attr_desc[i][0] = '\0';
	}

	/* For each dynamic atribute create a unnamed expression object
		and make the expression a template to corresponding ACdyn_col
                also add the attr to the attr_desc string of that ACdyn_col 
	*/

	for( i = 0 ; i < num_dyn; ++i ) 
	{ 
		_pdm_debug("exp type: %s",dyn_attr_types[i]);

		if( !strcmp(dyn_attr_types[i],"Expression text") ||
		    !strncmp(dyn_attr_types[i],"char",4) )
			exptype = 2;
		else 
			exptype = 1;

		if( exptype == 1 && strlen(dyn_attr_values[i]) < 1 )
		{
			_pdm_debug("No data value for this",0);
			continue;
		}

		if(GetDyncolIndx( temp_desc, dyn_attrs[i], num_org_temp, 
						num_loc, &colno ) == -1 )
			colno = num_coll - 1; /* put that in last collection */ 

		_pdm_debug("mapping to coll index %d", colno);

		lsize[colno] += 1;
		exp_list[colno] = (struct GRid *)realloc(exp_list[colno],
					sizeof(struct GRid) * lsize[colno] );
		MemCheck( exp_list[colno] );
 
		exp_list[colno][lsize[colno]-1].osnum = genv->md_id.osnum;

 		if( !create_expression("",dyn_attr_values[i],
				&exp_list[colno][lsize[colno]-1], exptype))
		{
			sts = 0;
			goto CleanUp;
		}

		/* Add the attr to the description template of this dyncol */
 
		attr_desc[colno] = (char *)realloc( attr_desc[colno],
				strlen(attr_desc[colno]) + strlen(dyn_attrs[i]) + 5 );
		MemCheck(attr_desc[colno]);

		strcat(attr_desc[colno],dyn_attrs[i]); 
		sprintf(tmp,",%d,", lsize[colno]-1 );
		strcat(attr_desc[colno], tmp);
	}

	/* Now, given the exp_list, attr_desc and the lsize arrays,
           for each collection break up attr_desc if it is longer
           than EXP_MAX_LEN, create so many text expr. objects and
           add them to the exp_list, incrementing the lsize for that
           collection 
	*/

	for( i = 0; i < num_coll; i++ )
	{
		if( !lsize[i] ) /* no templates mapped to this particular collection */
			continue;
		if( !BreakupAndAddToList( attr_desc[i], &exp_list[i], &lsize[i],
						 genv))
		{
			sts = 0;
			goto CleanUp; 
		}

		if( ! define_temp_to_ACdyncol( lsize[i], exp_list[i], 
						&dyncol[i], genv))
		{
			_pdm_debug("Define temp to ACdyncol failed",0);
			sts = 0;
			goto CleanUp;
		}
	}

	sts = 1;

CleanUp:		
/*	FreeArrayPtr( exp_list, num_coll );		*/
	FreeArrayPtr( attr_desc, num_coll );		
	MyFree(lsize);
	return(sts);
}

