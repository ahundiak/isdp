/* $Id: SMColl_util.C,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMColl_util.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMColl_util.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/07/14  19:34:00  pinnacle
 * Replaced smutil/func/SMColl_util.C for: TR 179600523 by A.Gupta for VDS
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

/*
 	
      PL       FEV 1993  : Design date
 
 ABSTRACT : 
 
 	Implements Functions used for the ACrg_coll management

	1. SMIsACrgEqual
	2. SMGetAttr
	3. SMSetAttr
 */
 
 
#include <stdio.h>
#include <math.h>
#include "string.h"
#include  "OMerrordef.h"
#include  "OMprimitives.h"

#include "igrtypedef.h"
 
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "AS_status.h"

 
 

/*1 ====================== SMIsACrgEqual =====================
/*
/* 	This fonction compare two ACrg and return 1 if they have  
/* 	the same attributes                                       
/*
/* */

int SMIsACrgEqual(ACrg1,nb_attr1,ACrg2,nb_attr2)
struct ACrg_coll ACrg1[],ACrg2[];  /* [I] ACrg to compare */
int nb_attr1,nb_attr2;             /* [I] Nb of attribut in each ACrg */
{
  int       i,type;
  IGRdouble val_db;
  char      str[ATTR_TXT];
  #define EPSILON 0.000000001

  if(nb_attr1 != nb_attr2) return 0;

  for(i = 0; i < nb_attr1; i++)
   {
     if(!SMGetAttr(ACrg1[i].name,ACrg2,(IGRshort *)NULL,nb_attr2,
		  &type,&val_db,str,(IGRshort *)NULL))
       return 0;

     if(type != ACrg1[i].desc.type) return 0;
     
     switch(type)
      {
      case AC_ATTRIB_TEXT:
	if(strcmp(ACrg1[i].desc.value.att_txt,str)) return 0;
	break;
      case  AC_ATTRIB_DOUBLE:
	if(fabs(ACrg1[i].desc.value.att_exp - val_db) > EPSILON) return 0;
	break;
      default:
	return 0;
      }
   }
  return 1; /* All test of equalities pass ! */
}




/*2 ====================== SMGetAttr =====================
/*
/* 	This fonction    Retrieve the value of an attribute in the
/*	 array of ACrg_coll 
/*                                  
/*	Return 1 if found and 0 if not found  
/* */

int SMGetAttr(name,ACrg,SMattr,nb_attr,type,f,str,sm_type)
char name[];             /* [I] Name of the attribute              */
struct ACrg_coll ACrg[]; /* [I] Array of ACrg_col where to search  */
IGRshort SMattr[];       /* [I] Array of sman type of attributes    */
int nb_attr;             /* [I] Number of element in the ACrg      */   
int *type;               /* [O] type of return value  (or NULL)    */
double  *f;              /* [O] double return if AC_ATTRIB_DOUBLE (or NULL) */
char str[];              /* [O] string return if AC_ATTRIB_TEXT (or NULL) */
IGRshort *sm_type;      /* [O] SMAN TYPE Of the Attribute  (or NULL) */
{
  int i;
  
  for(i = 0; i < nb_attr; i++)
   {
     if(ACrg[i].name == NULL) continue;
     if(strcmp(name,ACrg[i].name) == 0)
      {
	if(type) *type = ACrg[i].desc.type;
	switch(ACrg[i].desc.type)
	 {
	 case AC_ATTRIB_TEXT :
	   if(str) strcpy(str,ACrg[i].desc.value.att_txt);
	   break;
	 case AC_ATTRIB_DOUBLE :
	   if(f) *f= ACrg[i].desc.value.att_exp; 
	   break;
	 }
	if(sm_type && SMattr) *sm_type = SMattr[i];
	return 1;
      }
   }
  return 0;
}
/* ---------------  int SMSetAttr ---------------------- */
/* Set the value of an attribute in the array of ACrg_coll   */
/* If attributes not already exists, create it               */ 
/* Return 1 if found or create. Return 0 if cannot create    */

int SMSetAttr(name,ACrg,SMattr,nb_attr,type,f,str,sm_type,max_attr)
char name[];              /* [I] Name of the attribute               */
struct ACrg_coll ACrg[]; /* [O] Array of ACrg_col where to modify   */
IGRshort SMattr[];       /* [O] Array of sman type of attributes    */
int *nb_attr;            /* [I/O] Number of element in the ACrg     */   
int type;                /* [I] ACrg_type type of attribut          */
double  f;               /* [I] value of attribut (if double)       */
char str[];              /* [I] value of attribut (if text)         */
IGRshort sm_type;        /* [I] SMAN TYPE Of the Attribute          */
int max_attr;            /* [I] max nb_attr possible in ACrg        */ 
{
  int i;
  
  for(i = 0; i < *nb_attr; i++)
   {
     if(ACrg[i].name == NULL) continue;
     if(strcmp(name,ACrg[i].name) == 0)
      {
	switch(ACrg[i].desc.type)
	 {
	 case AC_ATTRIB_TEXT :
	   strcpy(ACrg[i].desc.value.att_txt,str);
	   break;
	 case AC_ATTRIB_DOUBLE :
	   ACrg[i].desc.value.att_exp = f; 
	   break;
	 }
	if(SMattr) SMattr[i] = sm_type;
	return 1;
      }
   }

  /* Attribut not found : create it */
  if(max_attr > *nb_attr)
   {
     strcpy(ACrg[*nb_attr].name,name);
     ACrg[*nb_attr].desc.type = type;
     switch(type)
      {
      case AC_ATTRIB_TEXT :
	strcpy(ACrg[*nb_attr].desc.value.att_txt,str);
	break;
      case AC_ATTRIB_DOUBLE :
	ACrg[*nb_attr].desc.value.att_exp = f; 
	break;
      }
     if(SMattr) SMattr[*nb_attr] = sm_type;
     (*nb_attr)++;
     return 1;
   }

  return 0;
}



