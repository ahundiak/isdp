/* $Id: VDdrw_sort.I,v 1.7 2002/03/31 18:21:00 ylong Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:        vdtbl/func/VDdrw_sort.I
 *
 * Description:
 *   VDdrw_sort.I includes the functions used for sorting table 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrw_sort.I,v $
 *      Revision 1.7  2002/03/31 18:21:00  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/11/28 21:47:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/07/06 21:01:47  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/07/03 20:11:50  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/03/08 21:56:18  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/19 12:19:19  paul_noel
 *      *** empty log message ***
 *
# Revision 1.3  2000/10/10  21:53:56  pinnacle
# (No comment)
#
# Revision 1.2  2000/06/29  21:11:26  pinnacle
# Replaced: vds/vdtbl/func/VDdrw_sort.I for:  by mdong for Service Pack
#
# Revision 1.1  2000/06/29  14:26:04  pinnacle
# Created: vds/vdtbl/func/VDdrw_sort.I by mdong for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1996/05/31  22:43:26  pinnacle
# Replaced: vdtbl/func/VDdrw_sort.I for:  by tlbriggs for vds.240
#
# Revision 1.8  1995/09/22  14:50:26  pinnacle
# Replaced: vdtbl/func/VDdrw_sort.I for:  by rmanem for vds.240
#
# Revision 1.7  1995/09/19  22:12:46  pinnacle
# Replaced: vdtbl/func/VDdrw_sort.I for:  by yzhu for vds.240
#
# Revision 1.5  1995/09/07  14:34:02  pinnacle
# Replaced: vdtbl/func/VDdrw_sort.I for:  by yzhu for vds.240
#
# Revision 1.4  1995/07/24  15:36:08  pinnacle
# Replaced: vdtbl/func/VDdrw_sort.I for:  by yzhu for vds.240
#
# Revision 1.3  1995/07/24  15:31:58  pinnacle
# Replaced: vdtbl/func/VDdrw_sort.I for:  by yzhu for vds.240
#
# Revision 1.2  1995/07/12  14:21:06  pinnacle
# Replaced: vdtbl/func/VDdrw_sort.I for:  by yzhu for vds.240
#
# Revision 1.1  1995/06/07  20:16:52  pinnacle
# Created: vdtbl/func/* by tdumbach for vds.240
#
# Revision 1.1  1995/05/31  19:32:42  pinnacle
# Created: vdtbl/func/VDdrw_sort.I by yzhu r#
# rno
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/23/95        yzhu            creation date
 *      09/22/95        rmn             Added qty field to VDrowinfo and
 *					VDsortElementM structures
 *	05/31/96	tlb		Added flag to VD_Return_Attr
 *	06/28/00	Ming		TR179901736
 ************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"

#include "OMprimitives.h"
#include "OMmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vdparmacros.h"
#include "DIdef.h"
#include "DImacros.h"
#include "AS_status.h"
#include "VDbom.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"
#include "VDdrwlo_pr.h"
#include "v_dbgmacros.h"
#include "v_miscmacros.h"


extern struct VDsortElementM;

/* #define vdsDEBUG    */
#define ASCENDING1      0
#define DESCENDING1    1 

from GRvg               import  GRgetname;
from GRgraphics         import  GRgetobjinfo;

/* ---------------------------------------------------------------------------
  Functions: strcmpa,  strcmpd, valcmpa, valcmpd

  Abstract
     those functions are used to sort table according attributes.

     strcmpa : string comparison on ascending
     strcmpd : string comparison on descending
     valcmpa : value comparison on ascending
     valcmpd : value comparison on descending


  Arguments
     struct VDsortElementM       *elm1          I/O     element list 
     struct VDsortElementM       *elm2          I/O     element list 


  Example:

  Status/Return Code
     status == -1 , reference strings unequal
                    or second string is NULL_VAL_STR
     status == 1  , first string is NULL_VAL_STR
     status == else , return normal
----------------------------------------------------------------------------*/
int strcmpa( struct VDsortElementM *elm1,
             struct VDsortElementM *elm2 )
{

     if( strcmp( elm1->refStr, elm2->refStr ))  
     {
#ifdef DEBUG
          printf("\nstrcmp_asc ::::  reference strings unequal\n" );
#endif
          return(-1);
     }
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) && 
          strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
#ifdef DEBUG
          printf("\nstrcmpa ::::  first string is NULL_VAL_STR\n" );
#endif
          return(1);
     }
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) &&
         !strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
#ifdef DEBUG
          printf("\nstrcmpa ::::  first  and second string is NULL_VAL_STR\n" );
#endif
          return(-1);
     }

     if( !strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
#ifdef DEBUG
          printf("\nstrcmpa ::::  second string is NULL_VAL_STR\n" );
#endif
          return(-1);
     }
     else
     {
#ifdef DEBUG
          printf("\nstrcmpa ::::  normal strcmp\n");
#endif

#ifdef YYY
          i = len1 = strlen( elm1->compStr );
          j = len2 = strlen( elm2->compStr );

          /*
           * i and j point to last integers in the strings
           * eg. in stiff10, i will point to 10
           */

          while( isdigit( elm1->compStr[i-1] ) )
              i--;

          while( isdigit( elm2->compStr[j-1] ) )
              j--;

          /*
           * if both strings end in some integer, and
           * the two strings differ only in the ending integer value
           * then compare the integers and accordingly sort them
           */

          if( i != len1 && j != len2 && i == j &&
                        !strncmp( elm1->compStr, elm2->compStr, i ) )
          {
              if( atoi( &elm1->compStr[i] ) < atoi( &elm2->compStr[i] ) )
                  return( -1 );
              else
                  return( 1 );
          }
#endif
          if (!strcmp( elm1->compStr, elm2->compStr) )
                  return( -1 );
          else
              return( strcmp( elm1->compStr, elm2->compStr ) );
     }
}


int strcmpd( struct VDsortElementM *elm1,
             struct VDsortElementM *elm2 )
{

     if( strcmp( elm1->refStr, elm2->refStr )) 
          return(-1);

     if( !strcmp( elm1->compStr, NULL_VAL_STR ) &&
          strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
          return(1);
     }
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) &&
         !strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
          return(-1);
     }

     if( !strcmp( elm2->compStr, NULL_VAL_STR ) )
          return(-1);
     else
     {
/*
          i = len1 = strlen( elm1->compStr );
          j = len2 = strlen( elm2->compStr );

          while( isdigit( elm1->compStr[i-1] ) )
              i--;

          while( isdigit( elm2->compStr[j-1] ) )
              j--;

          if( i != len1 && j != len2 && i == j &&
                        !strncmp( elm1->compStr, elm2->compStr, i ) )
          {
              if( atoi( &elm1->compStr[i] ) > atoi( &elm2->compStr[i] ) )
                  return( -1 );
              else
                  return( 1 );
          }
*/
          if (!strcmp( elm1->compStr, elm2->compStr) )
                  return( -1 );
          else
              return( strcmp( elm2->compStr, elm1->compStr ) );
     }
}


int valcmpa( struct VDsortElementM *elm1,
             struct VDsortElementM *elm2 )
{
     char *ptr = NULL;

     if( strcmp( elm1->refStr, elm2->refStr ) )
          return(-1);
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) &&
          strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
          return(1);
     }
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) &&
         !strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
          return(-1);
     }

     if( !strcmp( elm2->compStr, NULL_VAL_STR ) )
          return(-1);
     else
          return( (int) (strtod(elm1->compStr, &ptr) -
                         strtod(elm2->compStr, &ptr)) );
}


int valcmpd( struct VDsortElementM *elm1,
             struct VDsortElementM *elm2 )
{
     char *ptr = NULL;

     if( strcmp( elm1->refStr, elm2->refStr ) )
          return(-1);
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) &&
          strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
          return(1);
     }
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) &&
         !strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
          return(-1);
     }

     if( !strcmp( elm2->compStr, NULL_VAL_STR ) )
          return(-1);
     else
          return( (int) (strtod(elm2->compStr, &ptr) -
                         strtod(elm1->compStr, &ptr)) );
}

/* ----------------------------------------------------------------------------
  Function: VDsort_tbl
 
  Abstract
     This function is used to sort table
 
  Arguments
     IGRlong            *msg,                 O return code.
     IGRchar            *Tabnam               I table name
     struct GRobj_env   *objs               I/O the list of object
     struct VDrowinfo   *Rowinfo            I/O the list of row
                                                info and summarization info.
     IGRint             nbObjects             I nunber of objects
     IGRint             nbRows                I nunber of row

  Note:
           *----------------------------------------------------*
           * About  type match proble: for each object, the attr*
           * type is double/text. we have following rules when  *
           * input type mismatch with  attr type                *
           *----------------------------------------------------*
           * attr type  | input type | assign type | screen     *
           * double     | string     | doublec     | value      *
           * string     | double     | NULL_VAL_STR| NULL       *
           *            |            | + error mess|            *
           * no exist   | string     | null        | NULL       *
           * no exist   | double     | NULL_VAL_STR| NULL       *
           *----------------------------------------------------*

           here  NULL_VAL_STR = '!@!'
 
  Example:
        IGRlong            msg;
        IGRlong            status;
        IGRint             i;
        IGRchar            Tabnam[80];
        struct GRobj_env   *objs;
        struct VDrowinfo   Rowinfo[10];
        IGRint             nbObjects;
        IGRint             nbRows;

        strcpy(Tabnam, "sortkey");

        * get objs, nbObjects, Rowinfo, nbRows  using other method *

        status =
        VDsort_tbl(&msg, Tabnam, objs, Rowinfo, nbObjects, nbRows);
 
  Status/Return Cod
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/
IGRlong VDsort_tbl(
     IGRlong            *msg, 
     IGRchar            *Tabnam, 
     struct GRobj_env   *objs,   
     struct VDrowinfo   *Rowinfo, 
     IGRint             nbObjects, 
     IGRint             nbRows )
{
     IGRint                i, j, k,
                           len;
     IGRlong               status = OM_S_SUCCESS;
     struct ACrg_coll      *attLst = NULL;
     struct VDsortElementM *sortElmLst = NULL;
     struct VDsortElementM *sortElmLst1 = NULL;
     IGRshort              nCount;
     struct VDdrwlo_sort   *Srtrec = NULL;
     IGRint                vflag, ii;
     IGRint                status1,len1;
     IGRint                *lenarr = NULL;
     IGRchar               szmsg[200];

     
     SetProc( VDsort_tbl function ); Begin

     UI_status( "Starting of Sorting ..." );

     __DBGpr_str(" Tabnam ", Tabnam );
     __DBGpr_int(" nbObjects ", nbObjects );
     __DBGpr_int(" nbRows ", nbRows );
       
     /* to get sort criteria */
     *msg = MSSUCC;

     nCount = 0;

     status1 =
     VD_crsrt_gsort (msg,
                     Tabnam,
                     VD_DRWLO_EN_ALL,  
                     &nCount,
                     NULL); 
    
     if(!(status1&(*msg)&1)) {
          status = OM_E_ABORT ;
          goto wrapup;
     }
     /* allocate space for Srtrec */
     if(nCount) {
        Srtrec = _MALLOC(nCount, struct VDdrwlo_sort);
     }
     if( Srtrec == NULL )
     {
          printf("\nERROR : Dynamic memory allocation\n");
          status = OM_E_ABORT;
          goto wrapup;
     } 

     /* get Srtrec */
     status1 =
     VD_crsrt_gsort (msg,
                     Tabnam,
                     VD_DRWLO_EN_ALL,   
                     &nCount,
                     Srtrec);

     if(!(status1&(*msg)&1) || Srtrec == NULL) {
          printf ("\nERROR : VD_crsrt_gsort function \n"); 
          status = OM_E_ABORT;
          goto wrapup;
     }

     __DBGpr_int("Number of Srtrec", nCount);

     /* allocate space for sort element list */
     sortElmLst = _MALLOC(nbObjects, struct VDsortElementM);
     if( sortElmLst == NULL )
     {
          printf("\nERROR : Dynamic memory allocation\n");
          status = OM_E_ABORT;
          goto wrapup;
     }


     /* initialize the sort element list for qsort */
     len = 100;

     for( i = 0 ; i < nbObjects ; i++ ) {
          sortElmLst[i].obj = objs[i];

          sortElmLst[i].refStr = NULL;
          sortElmLst[i].refStr = _MALLOC(len+1, char );
          if( sortElmLst[i].refStr == NULL )
          {
               printf("\nERROR : Dynamic memory allocation\n");
               status = OM_E_ABORT;
               goto wrapup;
          }
          strcpy( sortElmLst[i].refStr, "" );

	  /* Modified by Ming for TR179901736 */
          sortElmLst[i].attrVal = (IGRchar (*)[MAX_BUF_CHARS1]) malloc(
                            sizeof( IGRchar ) * MAX_BUF_CHARS1 * nCount);

          if( sortElmLst[i].attrVal == NULL )
          {
               printf("\nERROR : Dynamic memory allocation\n");
               status = OM_E_ABORT;
               goto wrapup;
          }

          sortElmLst[i].sum = -1;
          strcpy( sortElmLst[i].compStr, "" );
          
     } /* for i */

     /* set up  sortElmLst[i].sum */
     for( i = 0 ; i < nbRows ; i++ ) { 
          for( k = Rowinfo[i].start_rindex; 
               k < (Rowinfo[i].start_rindex + Rowinfo[i].nbsumobjs); k++) {
          
             if( k == Rowinfo[i].start_rindex)          
	     {
                sortElmLst[k].sum = Rowinfo[i].nbsumobjs;
		sortElmLst[k].qty = Rowinfo[i].qty;
	     }
             else
                sortElmLst[k].sum = 0;

             sortElmLst[k].rowNb = i;
          }
     }

        
     /*
      * get the attribute values from each object and fill up the lists
      * for each object, we only consider attributes defined in the 
      * sort keys. we can use vd$review_params or vd$get_params. if using
      * vd$review_params, we need to give para name, 
      */
     
     /* allocate memory for attLst: here only one element to be used */
     attLst = _MALLOC(1, struct ACrg_coll);
     if( !attLst ) {
                   printf("\nVDsortObjects : ERROR in Dynamic Allocation\n");
                   status = OM_E_ABORT ;
                   goto wrapup;
     }


     for( i = 0 ; i < nbObjects ; i++ )
     {
	   if( !((100*i/nbObjects)%10) )
	   {
	     sprintf( szmsg, "Sorting objects: %d%s", (100*i/nbObjects),"%" );
             UI_status( szmsg );
	   }

          /*----------------------------------------------------*
           * About type match problem: for each object, the attr*
           * type is double/text. we have following rules when  *
           * input type mismatch with  attr typefo		*
           *----------------------------------------------------*     
           * attr type  | input type | assign type | screen     *   
           * double     | string     | double      | value      *
           * string     | double     | NULL_DBL +  | NULL       *
           *            |            | error mess  |            *
           * no exist   | string     | null        | NULL       *
           * no exist   | double     | NULL_DBL    | NULL       *
           *----------------------------------------------------*/ 
           /* may using NULL_VAL_STR = "!@!" as NULL_DBL        */ 
 
          for( j = 0 ; j < nCount; j++ ) {
            strcpy( sortElmLst[i].attrVal[j], NULL_VAL_STR );

            strcpy( attLst[0].name, Srtrec[j].szAtt );
            if(Srtrec[j].nsTyp == VD_DRWLO_EN_NUMERIC) {
                attLst[0].desc.type = AC_ATTRIB_DOUBLE;
            }
            else {
                attLst[0].desc.type = AC_ATTRIB_TEXT;
            }


            /* get red out front space */           
            while(attLst[0].name[0] == ' '&& (&attLst[0].name[1] != NULL)){
                   strcpy(attLst[0].name, &attLst[0].name[1]);
            } 

            if(attLst[0].name[0] =='\0') {
                printf(" [%d]key attribute name is empty\n", j+1);
                status = OM_E_ABORT;
                goto wrapup;
            } 

            /* get red out back space */           
            len1 = strlen(attLst[0].name);
            while(attLst[0].name[len1-1] == ' '){
                   attLst[0].name[len1-1] = '\0';
                   len1 = len1 - 1;
            }

            /* using vd$review_params or VD_Return_Attr*/

            if(attLst[0].name[0] !='#') {

	       __DBGpr_obj("Get att from vd$review_params for", objs[i].obj_id);
               status = vd$review_params(  
                                        pMsg       = msg,
                                        pComponent = &objs[i].obj_id,
                                        pMdEnv     = &objs[i].mod_env,
                                        pList      = attLst,
                                        NbParams   = 1);
               as$status();
            }
            else {
                while(attLst[0].name[0] == '#'&& (&attLst[0].name[1] != NULL)){
                   strcpy(attLst[0].name, &attLst[0].name[1]);
                }
	       __DBGpr_obj("Get att from VD_Return_Attr for", objs[i].obj_id);
                status = VD_Return_Attr (msg,
                                         1,
                                         &objs[i].obj_id,
                                         attLst,
                                         &objs[i].mod_env,
					 TRUE);
               as$status();
            } 

            if( (status&(*msg)&1) ) {
                   /* 
                    * need to check object type with input type here ???
                   */
                  switch( attLst[0].desc.type ) {
                     case AC_ATTRIB_TEXT :
                     	sprintf( sortElmLst[i].attrVal[j],
                                 "%s", attLst[0].desc.value.att_txt );
                     	break;

                     case AC_ATTRIB_DOUBLE :
                     	sprintf( sortElmLst[i].attrVal[j],
                              "%.2f", attLst[0].desc.value.att_exp );
                     	break;

                     default :
                     	strcpy( sortElmLst[i].attrVal[j], NULL_VAL_STR );
                        break;
                  } /* switch */
               } /* if */
               else {
                       /* 
                        * if no key attr for object, 
                        * set the attr = NULL_VAL_STR
                        */

                       strcpy( sortElmLst[i].attrVal[j],
                                           NULL_VAL_STR );
                       /* also need return  success */
                       status = OM_S_SUCCESS;
                       *msg = MSSUCC;
               } 
               /* truncate attribute val to column width no of characters ?? */
           } /* for j */
     } /* for i */

     UI_status( "End of Retrieving Attributes for Sorting..." );

     __DBGpr_int("nCount", nCount);
 

     /* 
      * deal with summarization rows: if at key attr column, attr values 
      * of objects in summarization rows are no equal, set them = 
      * NULL_AL_STR, otherwise they have same values and set it as row valus
     */
     for( j = 0 ; j < nCount; j++ ){
        for( i = 0 ; i < nbRows; i++ ) {
          vflag = TRUE;

          for( k = Rowinfo[i].start_rindex;
               k < (Rowinfo[i].start_rindex + Rowinfo[i].nbsumobjs); k++) {
                              
               if( strcmp(sortElmLst[k].attrVal[j],
                          sortElmLst[Rowinfo[i].start_rindex].attrVal[j])!= 0 ){
                 vflag = FALSE;
                 break;
               } 
          } 
          if(!vflag) {
           __DBGpr_int( " attrVal are not same at row ", i);

           for( k = Rowinfo[i].start_rindex;
                k < (Rowinfo[i].start_rindex + Rowinfo[i].nbsumobjs); k++) 
               sprintf( sortElmLst[k].attrVal[j], "%s", NULL_VAL_STR);
          }
       }
     }
       

     /* set up the sortElmLst1 which is used for keep 
      * first object in each sumrizatio row
      */

     sortElmLst1 = _MALLOC(nbRows, struct VDsortElementM);

     if( sortElmLst1 == NULL )
     {
          printf("\nERROR : Dynamic memory allocation\n");
          status = OM_E_ABORT;
          goto wrapup;
     }

     for( i = 0 ; i < nbRows ; i++ ) {

          sortElmLst1[i].refStr = NULL;
          sortElmLst1[i].refStr = _MALLOC( len+1, char );
          if( sortElmLst1[i].refStr == NULL )
          {
               printf("\nERROR : Dynamic memory allocation\n");
               status = OM_E_ABORT;
               goto wrapup;
          }
          strcpy( sortElmLst1[i].refStr, "" );

	  /* Modified by Ming for TR179901736 */
          sortElmLst1[i].attrVal = (IGRchar (*)[MAX_BUF_CHARS1]) malloc(
                            sizeof( IGRchar ) * MAX_BUF_CHARS1 * nCount);

          if( sortElmLst1[i].attrVal == NULL )
          {
               printf("\nERROR : Dynamic memory allocation\n");
               status = OM_E_ABORT;
               goto wrapup;
          }

          strcpy( sortElmLst1[i].compStr, "" );

     } /* for i */

     /* set up  sortElmLst1[i].sum */
     for( i = 0 ; i < nbRows ; i++ ) {

                k = Rowinfo[i].start_rindex;
          
                sortElmLst1[i].obj = sortElmLst[k].obj;

                sortElmLst1[i].sum =  sortElmLst[k].sum;

                sortElmLst1[i].qty =  sortElmLst[k].qty;

                sortElmLst1[i].rowNb = sortElmLst[k].rowNb;
               
     		for( j = 0 ; j < nCount ; j++ ) {
                 sortElmLst1[i].attrVal[j][0] = '\0';
                 strcpy(sortElmLst1[i].attrVal[j], sortElmLst[k].attrVal[j]);
                } 
     }


     /* set up the compStr for the 1st level of qsort */
     for( i = 0 ; i < nbRows ; i++ )
       strcpy( sortElmLst1[i].compStr, sortElmLst1[i].attrVal[0] );


     /* set up the element list for the next level of sorting */
     lenarr = NULL;
     lenarr = _MALLOC( nbRows, int );

     for( j = 0 ; j < nbRows ; j++ ) lenarr[j] = len;

     /* do a nested sort 
      *  note type definition: 
      *  nsTyp = VD_DRWLO_EN_ASCII,   attribute.desc.type = AC_ATTRIB_TEXT   
      *  nsTyp = VD_DRWLO_EN_NUMERIC, attribute.desc.type = AC_ATTRIB_DOUBLE
      */

     for( i = 0 ; i < nCount ; i++ )
     {
          /* sort with the proper criteria */

          if( Srtrec[i].nsTyp == VD_DRWLO_EN_ASCII &&
              Srtrec[i].nsSeq ==  ASCENDING1)
          {
               qsort( sortElmLst1, nbRows, sizeof(struct VDsortElementM),
                      (int (*)())strcmpa );
          }
          else if(  Srtrec[i].nsTyp == VD_DRWLO_EN_ASCII &&
                    Srtrec[i].nsSeq == DESCENDING1 )
          {
               qsort( sortElmLst1, nbRows, sizeof(struct VDsortElementM),
                      (int (*)())strcmpd );
          }
          else if(  Srtrec[i].nsTyp == VD_DRWLO_EN_NUMERIC &&
                    Srtrec[i].nsSeq == ASCENDING1 )
          {
               qsort( sortElmLst1, nbRows, sizeof(struct VDsortElementM),
                      (int (*)())valcmpa );
          }
          else if(  Srtrec[i].nsTyp == VD_DRWLO_EN_NUMERIC &&
                    Srtrec[i].nsSeq == DESCENDING1 )
          {
               qsort( sortElmLst1, nbRows, sizeof(struct VDsortElementM),
                      (int (*)())valcmpd );
          }


          for( j = 0 ; i < nCount-1 && j < nbRows ; j++ )
          {    
               lenarr[j] = lenarr[j] + strlen(sortElmLst1[j].attrVal[i+1]);   

               strcat( sortElmLst1[j].refStr, sortElmLst1[j].attrVal[i] );
               strcpy( sortElmLst1[j].compStr, sortElmLst1[j].attrVal[i+1] );
               if( sortElmLst1[j].refStr ) {
                  sortElmLst1[j].refStr = 
                  _REALLOC( sortElmLst1[j].refStr, lenarr[j]+1, IGRchar );
               }
          }

     } /* for i */


     /* copy sorted list of objects back to the output array */

     ii = 0;
     for( i = 0 ; i < nbRows ; i++ ) {
        for( j = 0 ; j < nbObjects; j++ ) {
          if( sortElmLst1[i].rowNb == sortElmLst[j].rowNb) { 
             objs[ii] = sortElmLst[j].obj;
             ii++ ;   
          }
        }
     } 

     __DBGpr_int( " output num of objs ", ii);

     /* get row info after sorting */
     Rowinfo[0].start_rindex = 0; 
     Rowinfo[0].nbsumobjs = sortElmLst1[0].sum; 
     Rowinfo[0].qty = sortElmLst1[0].qty; 
     __DBGpr_com("Sorted row info:");
     for( i = 1 ; i < nbRows ; i++ ){
            Rowinfo[i].start_rindex = Rowinfo[i-1].start_rindex
                                      + sortElmLst1[i-1].sum; 
            Rowinfo[i].nbsumobjs = sortElmLst1[i].sum; 
            Rowinfo[i].qty = sortElmLst1[i].qty; 
	    __DBGpr_int("\tstart_rindex", Rowinfo[i].start_rindex);
	    __DBGpr_int("\tnbsumobjs", Rowinfo[i].nbsumobjs);
	    __DBGpr_int("\tqty_nSflag", Rowinfo[i].qty.nSflag);
	    __DBGpr_str("\tqty_szExp", Rowinfo[i].qty.szExp);
     }

     UI_status( "End of Sorting ..." );

wrapup :

     /* free all allocated space */

          _FREE( lenarr);

          _FREE( Srtrec );

          _FREE( attLst );

     if( sortElmLst )
     {
          for( i = 0 ; i < nbObjects ; i++ ) {
               if( sortElmLst[i].attrVal )
                    free( sortElmLst[i].attrVal );
               _FREE( sortElmLst[i].refStr ); 
          } 
          _FREE( sortElmLst );
     }

     if( sortElmLst1 )
     {
          for( i = 0 ; i < nbRows ; i++ ) {
               if( sortElmLst1[i].attrVal )
                    free( sortElmLst1[i].attrVal );
               _FREE( sortElmLst1[i].refStr );
          }
          _FREE( sortElmLst1 );
     }
 
     End
     return status;
}/*VDsort_tbl*/

end implementation Root;
