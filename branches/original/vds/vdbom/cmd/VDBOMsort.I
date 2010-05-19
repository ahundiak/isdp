/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdbom/cmd / VDBOMsort.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      12/07/94        R. Manem        Creation for OPE enhancements
 *                                      - sorting of objects in BOM table
 *	12/12/94	R. Manem	- global attributes sorting 
 *	01/09/95	R. Manem	Included printfs within DEBUG
 * 	12/01/95	R. Manem	Handling of special strings like
 *					"stiff10" and stiff8"
 *					Avoid sorting for non-assoc BOM
 *	01/23/95	R. Manem	Handle multiple types for attributes
 *					Removed small bugs in status checks.
 *					Reintroduced sorting for non-assoc BOM
 *					also
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdBOM;

#include "OMprimitives.h"
#include "OMmacros.h"
#include "string.h"
#include <stdlib.h>
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vdparmacros.h"
#include "DIdef.h"
#include "DImacros.h"
#include "AS_status.h"
#include "VDbom.h"

extern struct VDsortElement;

/*
#define DEBUG
*/

from GRvg 		import	GRgetname;
from GRgraphics 	import	GRgetobjinfo;

int strcmp_asc( struct VDsortElement *elm1, 
                struct VDsortElement *elm2 )
{
     int i, j, len1, len2;

     if( strcmp( elm1->refStr, elm2->refStr ) )
     {
#ifdef DEBUG
          printf("\nstrcmp_asc ::::  reference strings unequal\n" );
#endif
          return(-1);
     }
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) )
     {
#ifdef DEBUG
          printf("\nstrcmp_asc ::::  first string is NULL_VAL_STR\n" );
#endif
          return(1);
     }
     else if( !strcmp( elm2->compStr, NULL_VAL_STR ) )
     {
#ifdef DEBUG
          printf("\nstrcmp_asc ::::  second string is NULL_VAL_STR\n" );
#endif
          return(-1);
     }
     else
     {
#ifdef DEBUG
          printf("\nstrcmp_asc ::::  normal strcmp\n");
#endif

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
           *     the two strings differ only in the ending integer value
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
          else
              return( strcmp( elm1->compStr, elm2->compStr ) );
     }
}


int strcmp_des( struct VDsortElement *elm1, 
                struct VDsortElement *elm2 )
{
     int i, j, len1, len2;

     if( strcmp( elm1->refStr, elm2->refStr ) )
          return(-1);
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) )
          return(1);
     else if( !strcmp( elm2->compStr, NULL_VAL_STR ) )
          return(-1);
     else
     {
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
          else
              return( strcmp( elm2->compStr, elm1->compStr ) );
     }
}


int dblcmp_asc( struct VDsortElement *elm1, 
                struct VDsortElement *elm2 )
{
     char *ptr = NULL;

     if( strcmp( elm1->refStr, elm2->refStr ) )
          return(-1);
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) )
          return(1);
     else if( !strcmp( elm2->compStr, NULL_VAL_STR ) )
          return(-1);
     else
          return( (int) (strtod(elm1->compStr, &ptr) - 
                         strtod(elm2->compStr, &ptr)) );
}


int dblcmp_des( struct VDsortElement *elm1, 
                struct VDsortElement *elm2 )
{
     char *ptr = NULL;

     if( strcmp( elm1->refStr, elm2->refStr ) )
          return(-1);
     if( !strcmp( elm1->compStr, NULL_VAL_STR ) )
          return(1);
     else if( !strcmp( elm2->compStr, NULL_VAL_STR ) )
          return(-1);
     else
          return( (int) (strtod(elm2->compStr, &ptr) - 
                         strtod(elm1->compStr, &ptr)) );
}

IGRlong VDsortObjs(    struct GRobj_env        *objLst,
                       IGRint                  nbObjects,
                       IGRint                  sortNestLevel,
                       IGRchar                 *sortOrderLst,
                       IGRchar                 (*sortAttrLst)[MAX_BUF_CHARS],
                       IGRint                  *colSizeLst,
                       IGRchar                 (*formatLst)[MAX_BUF_CHARS] )
{
     IGRint                i, j, k,
                           nbParams,
                           len,
                           *attrTypeLst = NULL;
     IGRlong               msg,
                           status = OM_S_SUCCESS;
     IGRchar               tempName[MAX_BUF_CHARS],
                           buffer[MAX_BUF_CHARS],
                           elmName[DI_PATH_MAX];
     struct GRobj_info     info;
     struct ACrg_coll      *attLst = NULL;
     struct VDsortElement  *sortElmLst = NULL;

#ifdef DEBUG
     printf("\nVDsortObjs function :\n");
     printf("nbObjects = %d, sortNestLevel = %d\n", nbObjects, sortNestLevel );
     for( i = 0 ; i < sortNestLevel ; i++ )
     {
          printf("\ncolSizeLst[%d] = %d, sortOrderLst[%d] = %c", 
					i, colSizeLst[i], i, sortOrderLst[i] );
          printf("\nsortAttrLst[%d] = %s, formatLst[%d] = %s", 
					i, sortAttrLst[i], i, formatLst[i] );
     }
#endif


     /* allocate space for sort element list */

     sortElmLst = (struct VDsortElement *)malloc( sizeof(struct VDsortElement)
                                                   * nbObjects );
     if( sortElmLst == NULL )
     {
          printf("\nERROR : Dynamic memory allocation\n");
          status = OM_E_NODYNMEM;
          goto wrapup;
     }

     /* calculate maximum length of reference string */

     for( i = 0, len = 0 ; i < sortNestLevel ; i++ )
          len += colSizeLst[i];

     /* initialize the sort element list for qsort */

     for( i = 0 ; i < nbObjects ; i++ )
     {
          sortElmLst[i].obj = objLst[i];

          sortElmLst[i].refStr = NULL;
          sortElmLst[i].refStr = (IGRchar *)malloc( sizeof(char) * len );
          if( sortElmLst[i].refStr == NULL )
          {
               printf("\nERROR : Dynamic memory allocation\n");
               status = OM_E_NODYNMEM;
               goto wrapup;
          }
          strcpy( sortElmLst[i].refStr, "" );

          sortElmLst[i].attrVal = (IGRchar (*)[MAX_BUF_CHARS]) malloc(
                            sizeof( IGRchar ) * MAX_BUF_CHARS * sortNestLevel );

          if( sortElmLst[i].attrVal == NULL )
          {
               printf("\nERROR : Dynamic memory allocation\n");
               status = OM_E_NODYNMEM;
               goto wrapup;
          }
     }


     /* 
      * allocate space for attribute type list and initialize type
      */

     attrTypeLst = (IGRint *)malloc( sizeof(IGRint) * sortNestLevel );
     
     if( attrTypeLst == NULL )
     {
          printf("\nERROR : Dynamic memory allocation\n");
          status = OM_E_NODYNMEM;
          goto wrapup;
     }

     for( i = 0 ; i < sortNestLevel ; i++ )
          attrTypeLst[i] = AC_ATTRIB_TYPE_NOT_DEF ;

     /* 
      * get the attribute values from each object and fill up the lists
      * for each object
      */

     for( i = 0 ; i < nbObjects ; i++ )
     {
          nbParams = 0;

          /* get the count of parameters for the object */
 
          status = vd$get_parameters( sts       = &msg,
                                      object    = &objLst[i].obj_id,
                                      md_env    = &objLst[i].mod_env,
                                      count     = &nbParams );
          as$status();

#ifdef DEBUG
     printf("\nNumber of parameters for <%d,%d> = %d", objLst[i].obj_id.objid,
                                                       objLst[i].obj_id.osnum,
                                                       nbParams );
#endif

          if( nbParams )
          {
              /* allocate space for the parameter list */

              attLst = (struct ACrg_coll *)malloc( sizeof(struct ACrg_coll) *
                                               nbParams );
              if( !attLst )
              {
                   printf("\nVDsortObjects : ERROR in Dynamic Allocation\n");
                   goto wrapup;
              }

              /* get the object parameters */

              status = vd$get_parameters( sts       = &msg,
                                          object    = &objLst[i].obj_id,
                                          md_env    = &objLst[i].mod_env,
                                          plist     = attLst,
                                          size      = nbParams,
                                          count     = &nbParams );
              as$status();
          }

          /* convert the detailed names to short names (remove all prefixes) */

          for( j = 0 ; j < nbParams ; j++)
          {
               for( k = strlen( attLst[j].name ) - 1 ; k >= 0 ; k-- )
               if( attLst[j].name[k] == ':' )
                    break;

               k++;
               strcpy( tempName, &attLst[j].name[k] );
               strcpy( attLst[j].name, tempName );
          }

          for( j = 0 ; j < sortNestLevel ; j++ )
          {
               strcpy( sortElmLst[i].attrVal[j], NULL_VAL_STR );

               /* take care of global attributes */

               if( !strcmp( sortAttrLst[j], "%OBJ_NAME" ) )
               {
               
                    /* get the object name */

                    elmName[0] = '\0';

                    status =  om$send( msg = message  GRvg.GRgetname( &msg,
                                                                    elmName ),
                                       senderid = NULL_OBJID,
                                       targetid = objLst[i].obj_id.objid,
                                       targetos = objLst[i].obj_id.osnum );
                    as$status( );
                    if( !(status & msg & 1) )
                         continue;

                    di$cvt_name_for_output( s_path = elmName,
                                            u_path = elmName );
      
                    if( elmName[0] == ':' )
                         strncpy( buffer, &elmName[1], MAX_BUF_CHARS - 1 );
                    else
                         strncpy( buffer, elmName, MAX_BUF_CHARS - 1 );
                    sprintf( sortElmLst[i].attrVal[j], formatLst[j], buffer );

                    sortElmLst[i].attrVal[j][ colSizeLst[j] ] = '\0';
                    attrTypeLst[j] = AC_ATTRIB_TEXT;
                    continue;
               }
               else if( !strcmp( sortAttrLst[j], "%OBJ_TYPE" ) )
               {
                    /* get the object type */

                    info.type[0] = '\0';

                    status =  om$send( msg = message  GRgraphics.GRgetobjinfo( 
									&msg,
                                                                    	&info ),
                                       senderid = NULL_OBJID,
                                       targetid = objLst[i].obj_id.objid,
                                       targetos = objLst[i].obj_id.osnum );
                    as$status();
                    if( !(status & msg & 1) )
                         continue;
        
                    strncpy( buffer, info.type, MAX_BUF_CHARS - 1 );
                    sprintf( sortElmLst[i].attrVal[j], formatLst[j], buffer );

                    sortElmLst[i].attrVal[j][ colSizeLst[j] ] = '\0';
                    attrTypeLst[j] = AC_ATTRIB_TEXT;
                    continue;
               }

               /* must validate the format and the type of the attribute */

               len = strlen( formatLst[j] );

               for( k = 0 ; k < nbParams ; k++ )
               {
                    if( !strcmp( sortAttrLst[j], attLst[k].name ) )
                    {
 
                         switch( attLst[k].desc.type )
                         {

                         /* ------- to check for overflow of string?? --------*/

                              
                              case AC_ATTRIB_TEXT :
				   if( formatLst[j][len-1] != 's' )
                                       sprintf( sortElmLst[i].attrVal[j], 
                                                "%s", 
                                                attLst[k].desc.value.att_txt );
				   else
                                       sprintf( sortElmLst[i].attrVal[j], 
                                                formatLst[j], 
                                                attLst[k].desc.value.att_txt );
                                   attrTypeLst[j] = AC_ATTRIB_TEXT;
                                   break;

                              case AC_ATTRIB_DOUBLE :
				   if( formatLst[j][len-1] == 's' )
				   {
                                       sprintf( sortElmLst[i].attrVal[j],
                                                "%.2f", 
                                                attLst[k].desc.value.att_exp );
				       attrTypeLst[j] = AC_ATTRIB_TEXT;
				   }
				   else
                                       sprintf( sortElmLst[i].attrVal[j],
                                                formatLst[j], 
                                                attLst[k].desc.value.att_exp );
				   if( attrTypeLst[j] == AC_ATTRIB_TYPE_NOT_DEF)
                                       attrTypeLst[j] = AC_ATTRIB_DOUBLE;
                                   break;

                              default :
                                   strcpy( sortElmLst[i].attrVal[j], 
                                           NULL_VAL_STR );
                                   attrTypeLst[j] = AC_ATTRIB_DOUBLE;
                                   break;
                         }
                         break;
                    }
               }

               /* truncate attribute val to column width no of characters */

               sortElmLst[i].attrVal[j][ colSizeLst[j] ] = '\0';
           }
           if( attLst )
               free( attLst );
           attLst = NULL;
     }

     /* set up the compStr for the 1st level of qsort */

     for( i = 0 ; i < nbObjects ; i++ )
          strcpy( sortElmLst[i].compStr, sortElmLst[i].attrVal[0] );

#ifdef DEBUG
     printf("\n\nAttribute lists :");
     for( i = 0 ; i < nbObjects ; i++ )
     {
          printf("\n\tobject %d : ", i+1 );
          for( j = 0 ; j < sortNestLevel ; j++ )
               printf("%s ", sortElmLst[i].attrVal[j] );
     }
#endif


     /* do a nested sort */

     for( i = 0 ; i < sortNestLevel ; i++ )
     {
          /* sort with the proper criteria */

          if( attrTypeLst[i] == AC_ATTRIB_TEXT &&
                                 sortOrderLst[i] == ASCENDING )
          {
#ifdef DEBUG
     printf("\nqsort with strcmp_asc function\n");
#endif
               qsort( sortElmLst, nbObjects, sizeof(struct VDsortElement),
                      (int (*)())strcmp_asc );
          }
          else if(  attrTypeLst[i] == AC_ATTRIB_TEXT &&
                                 sortOrderLst[i] == DESCENDING )
          {
#ifdef DEBUG
     printf("\nqsort with strcmp_des function\n");
#endif
               qsort( sortElmLst, nbObjects, sizeof(struct VDsortElement),
                      (int (*)())strcmp_des );
          }
          else if(  attrTypeLst[i] == AC_ATTRIB_DOUBLE &&
                                 sortOrderLst[i] == ASCENDING )
          {
#ifdef DEBUG
     printf("\nqsort with dblcmp_asc function\n");
#endif
               qsort( sortElmLst, nbObjects, sizeof(struct VDsortElement),
                      (int (*)())dblcmp_asc );
          }
          else if(  attrTypeLst[i] == AC_ATTRIB_DOUBLE &&
                                 sortOrderLst[i] == DESCENDING )
          {
#ifdef DEBUG
     printf("\nqsort with dblcmp_des function\n");
#endif
               qsort( sortElmLst, nbObjects, sizeof(struct VDsortElement),
                      (int (*)())dblcmp_des );
          }

          /* set up the element list for the next level of sorting */

          for( j = 0 ; i < sortNestLevel-1 && j < nbObjects ; j++ )
          {
               strcat( sortElmLst[j].refStr, sortElmLst[j].attrVal[i] );
               strcpy( sortElmLst[j].compStr, sortElmLst[j].attrVal[i+1] );
          }

#ifdef DEBUG
     printf("\nList after %d level of sorting :\n", i+1 );
     for( j = 0 ; j < nbObjects ; j++ )
          printf("%s\t\t%s\n", sortElmLst[j].refStr, sortElmLst[j].compStr );
#endif

     }

     /* copy sorted list of objects back to the output array */

     for( i = 0 ; i < nbObjects ; i++ )
          objLst[i] = sortElmLst[i].obj;

wrapup :

     /* free all allocated space */
     
     if( attrTypeLst )
          free( attrTypeLst );
     if( sortElmLst )
     {
          for( i = 0 ; i < nbObjects ; i++ )
               if( sortElmLst[i].attrVal )
                    free( sortElmLst[i].attrVal );
          free( sortElmLst );
     }
     return status;
}

method sort_objs( long *sts )
{
     long status    = OM_S_SUCCESS;

     IGRint           i, j,
                      sortLevel = 0;

     /* compute actual sort level ; some entries may be null */

     for( i = 0 ; i < SORT_LEVEL-sortLevel ; i++ )
     {

#ifdef DEBUG
     printf("\nsort_objects method : sortAttrLst[%d] = %s\n", i,
				me->sortAttrLst[i] );
#endif
			
          if( !strlen( me->sortAttrLst[i] ) )
          {
               for( j = i ; j < (SORT_LEVEL-sortLevel)-1 ; j++ )
               {
                    me->sortOrderLst[j] = me->sortOrderLst[j+1];
                    strcpy( me->sortAttrLst[j], me->sortAttrLst[j+1] );
                    me->colSizeLst[j] = me->colSizeLst[j+1];
                    strcpy( me->formatLst[j], me->formatLst[j+1] );
               }
          }
          else
               sortLevel++;
     }

#ifdef DEBUG
     printf("\nSORT INFO :\n");
     for( i = 0 ; i < sortLevel ; i++ )
          printf("%c %s %d %s\n", me->sortOrderLst[i],
                                  me->sortAttrLst[i],
                                  me->colSizeLst[i],
                                  me->formatLst[i] );
#endif

     if( !sortLevel )
          goto quit;

     status = VDsortObjs( me->locObjs,
                          me->nbLocObjs,
                          sortLevel,
                          me->sortOrderLst,
                          me->sortAttrLst,
                          me->colSizeLst,
                          me->formatLst );

quit :
     return OM_S_SUCCESS;
}
end implementation VDCmdBOM;

