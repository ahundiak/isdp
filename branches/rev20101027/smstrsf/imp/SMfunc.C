/* $Id: SMfunc.C,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        smstrsf/SMfunct.C
 *
 * Description:
 *
 *      This file implements Functions used for the SMCmdStrSf command.
 *
 *
 * Revision History:
 *	$Log: SMfunc.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
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
 *
 *      02/19/93        P. Lacroix	Creation date.
 *
 * -------------------------------------------------------------------------
 */
 
 
#include <stdio.h>
#include "string.h"

#include  "OMerrordef.h"
#include  "OMprimitives.h"

#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "AS_status.h"
#include "SMStructSf.h"

 
 
#define   AS_DEBUG 	1
 

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMGetRgSf

  Abstract
        This function Get the info in the ACrg_coll and fills 
 	the attributes.

  Returns

	return 1 if ok 
 	else 0.	
	
 -------------------------------------------------------------------------
*/
  
 int	SMGetRgSf(ACrg, nb_att, SurfType, Description, Density, Tightness, 
			sfname, floor_area, weight, props, consume)

struct ACrg_coll 	*ACrg;	        /* (I) where the info are taken */
IGRint			nb_att;	      	/* (I) nb attributes in ACrg */
IGRchar			*SurfType;  	/* (O) attr SurfType */
IGRchar			*Description;	/* (O) attr description */
IGRdouble 		*Density; 	/* (O) attr density */
IGRchar 		*Tightness; 	/* (O) attr Tightness */
IGRchar 		*sfname; 	/* (O) attr name of the surface */
IGRdouble		*floor_area;	/* (O) attr floor_area */
IGRdouble		*weight;	/* (O) attr weight */
IGRshort		*props;		/* (O) attr props */
IGRshort		*consume;	/* (O) attr consume */
/*
-fi*/
{
long			status;
char			name[ATTR_TXT], text[ATTR_NAME];
IGRdouble		value;
 
/* Get the SurfType */

if(SurfType){
 	strcpy(name,"surftype");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute SurfType\n");
 		return(0);
 	}
 	strcpy(SurfType, text);
}

/* Get the Description */

if(Description){
 	strcpy(name,"description");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute Description\n");
 		return(0);
 	}
 	strcpy(Description, text);
}

/* Get the Density */

if(Density){
 	strcpy(name,"density");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, &value, NULL, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute Density\n");
 		return(0);
 	}
 	*Density = value;
}


/* Get the Tightness */

if(Tightness){
 	strcpy(name,"tightness");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute Tightness\n");
 		return(0);
 	}
 	strcpy(Tightness, text);
}

/* Get the surface name */

if(sfname){
 	strcpy(name,"name");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute sfname\n");
 		return(0);
 	}
 	strcpy(sfname, text);
}

/* Get the  floor_area */

if(floor_area){
 	strcpy(name,"area");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, &value, NULL, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute Floor_area\n");
 		return(0);
 	}
 	*floor_area = value;
}

/* Get the weight */

if(weight){
 	strcpy(name,"weight");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, &value, NULL, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute weight\n");
 		return(0);
 	}
 	*weight = value;
}

/* Get the props */

if(props){
 	strcpy(name,"props");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, &value, NULL, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute props\n");
 		return(0);
 	}
 	*props = (IGRshort)value;
}
if(consume){
 	strcpy(name,"consume");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, &value, NULL, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute consume\n");
 		return(0);
 	}
 	*consume = (IGRshort)value;
}

return(1);
}

