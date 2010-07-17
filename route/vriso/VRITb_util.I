/* $Id: VRITb_util.I,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vriso / VRITb_util.I
 *
 * Description:
 *
 *              Service functions for store/retrieve
 *                of the "big" array.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRITb_util.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.1  1996/05/23  22:00:54  pinnacle
# Created: vriso/VRITb_util.I by hverstee for route240
#
 *
 * History:
 *
 *      04/05/96        hv      split off from fill_big.I
 *
 *************************************************************************/
 
/***************************************************************************
 *
 *  ISOGEN AND TRIFLEX INTERFACE
 *
 ***************************************************************************/

class implementation Root;

#include <stdio.h>

#include "OMerrordef.h" 
#include "OMminimum.h"
#include "OMmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "msdef.h"
#include "gomacros.h"
#include "exmacros.h"

#include "VDmem.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "VRmsg.h"
#include "ACrg_collect.h"

#include "big.h"
#include "dbs.h"

#include "AS_status.h"
#include "vriso_pto.h"

#define MAX_HANGERS     100

from     VRGeneric    import   VRGetHangers;
/* ------------------------------------------------------------------------- */


/***************************************************************/
/*
/*  ISshift:
/*         shift the given value of shift_nb and
/*         put in the value
/**************************************************************/

int
ISshift (int      value,
         int      shift_nb)
{
  return (value << shift_nb);
}

/*********************************************************************
 *
 *  get_big:  ajout le 8 NOVEMBRE 89
 *
 *  Given the address of an array (filled in a FORTRAN form), the maximun
 *  colonnes, the row and the line retrieve an array of short.
 *
 *  tab[i][j]: i->line, j->colonne
 *
 ********************************************************************/

int
get_big(short   *big,           /* addr of big  row, (I)                */
        int      row,           /* number of max colonne (C), (I)       */
        int      line,          /* line, and colonne to get (C), (I)    */
        int      col,           /* line, and colonne to get (C), (I)    */
        int      nb_word,       /* nb_word in attribute, (I)            */
        short   *attr_val)      /* attribute to get, (O)                */

{
  int i;

  for (i=0;i<nb_word;i++)
    attr_val[i] = big[line*row+col+i];

  return OM_S_SUCCESS;
}


/*********************************************************************
 *
 *  set_big:  ajout le 8 NOVEMBRE 89
 *
 *  Given the address of big row, the number of maximun
 *  colonnes, and the attribute to set ,fill the given row and line
 *  with the attribute.
 *
 *  tab[i][j]: i->line, j->colonne
 *
 ********************************************************************/

int
set_big(short   *big,           /* addr of big  row, (I)                */
        int      row,           /* number of max colonne (C), (I)       */
        int      line,          /* line, and colonne to set (C), (I)    */
        int      col,           /* line, and colonne to set (C), (I)    */
        int      nb_word,       /* nb_word in attribute, (I)            */
        short   *attr_val)      /* attribute to set, (I)                */

{
  int i;

  for (i=0;i<nb_word;i++)
    big[line*row+col+i] = attr_val[i];

  return OM_S_SUCCESS;
}


/*********************************************************************
 *
 *  set_big_mask:  ajout le 8 NOVEMBRE 89
 *
 *  Given the address of big row, the number of maximum
 *  colonnes, the attribute containing the bit to set, and its mask ,
 *  fill the given row and line  with the updated attribute.
 *
 ********************************************************************/

int
set_big_mask(short   *big,           /* addr of big  row, (I)                */
             int      row,           /* number of max colonne (C), (I)       */
             int      line,          /* line, and colonne to set (C), (I)    */
             int      col,           /* line, and colonne to set (C), (I)    */
             short   *attr_val,      /* attribute to set, (I)                */
             int      mask)          /* mask used to update the field        */

{
  big[line*row+col] = big[line*row+col] & (~mask);   /* reset of the bits */

  *attr_val = *attr_val & mask;

  big[line*row+col] = *attr_val |  big[line*row+col];

  return OM_S_SUCCESS;
}



/***********************************************************************
 *
 *    print_big: print the big array.
 *
 ***********************************************************************/

int
print_big (int      frm,            /* start index */
           int      to,             /* end   index */
           short   *big)            /* big array   */
{
  int   i;
  short node;
  short cp;

  struct GRid big_id;

  printf("index: objid : osnum :  cp  : node\n");

  for (i=frm;i<to;i++)
  {
    get_big (big,ROW,i,B_OBJID, 2, (short *)&big_id.objid);
    get_big (big,ROW,i,B_OSNUM, 1, (short *)&big_id.osnum);
    get_big (big,ROW,i,B_CP,    1, (short *)&cp);
    get_big (big,ROW,i,B_NODE,  1, (short *)&node);

    printf("%3d  : %4d  : %3d   : %3d  : %4d  :\n",
              i,big_id.objid,big_id.osnum,cp,node);
  }

  return OM_S_SUCCESS;
}

int
print_big1 (int      frm,            /* start index */
            int      to,             /* end   index */
            short   *big)            /* big array   */
{
  int      i,occ;
  short    node,orientation[3];
  short    cp,info22,info14,bseg;
  long     x, y, z;
  char     name[5];

  struct GRid big_id;

  printf(
"objid: occ   : name :  cp : node :info22 :info14 :    x   :    y   :  z  :\n");

  for (i=frm;i<to;i++)
  {
    get_big(big,ROW,i,B_NAME,2,(short *)name);
    name[4]='\0';

    get_big(big,ROW,i,B_OBJID,2,(short *)&big_id.objid);
    get_big(big,ROW,i,B_OCC,2,(IGRshort *)&occ);
    get_big(big,ROW,i,B_CP,1,(short *)&cp);
    get_big(big,ROW,i,B_NODE,1,(short *)&node);
    get_big(big,ROW,i,B_INFO22,1,(short *)&info22);
    get_big(big,ROW,i,B_INFO14,1,(short *)&info14);
    get_big(big,ROW,i,B_X,2,(short *)&x);
    get_big(big,ROW,i,B_Y,2,(short *)&y);
    get_big(big,ROW,i,B_Z,2,(short *)&z);

    printf("%5d :%6d :%5s : %3d : %4d : %4x  : %4x : %6ld : %6ld : %6ld\n",
             big_id.objid,occ,name,cp,node,info22,info14,x,y,z);
  }

  printf("index: occ   : B_18 :orient0: orient1: orient2\n");

  for (i=frm;i<to;i++)
  {
    get_big(big,ROW,i,B_18 ,1,(short *)&bseg);
    get_big(big,ROW,i,B_OCC,2,(short *)&occ);
    get_big(big,ROW,i,B_ORIENT,3,(short *)orientation);

    printf("%4d:%6d :%6d :%6d :%6d :%6d\n",
            i,occ,bseg,orientation[0],orientation[1],orientation[2]);
  }

  return OM_S_SUCCESS;
}




/***********************************************************************
 *
 *    print_big_file: print the big array in an ascii file
 *
 ***********************************************************************/

int
print_big_file (long    *msg,       /* complection code (O)                 */
                short  **big,       /* BIG array (I/O)                      */
                int     *nb_big,    /* number of elements of big (I/O)      */
                char    *file_name) /* output file name                     */

{
 FILE   *pf;
 int     i,j;
 int     iSing;
 short  *lbig;

 /*" Big file: %s\n",file_name */
 *msg = 0;
 lbig = *big;

 pf= (FILE *) fopen(file_name,"w");
 for (i=0;i<*nb_big;i++)
 {
   iSing =  i * ROW;

   for(j=0;j<ROW;j++)
     fprintf(pf," %6d ",lbig[iSing + j]);

   fprintf(pf,"\n");
   fflush(pf);
 }

 fclose(pf);
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}






/******************************************************/
/*  ISbig_alloc:                                      */
/*  big allocation or reallocation                    */
/******************************************************/

int
ISbig_alloc (long     *msg,      /* completion code (O)                     */
             int       nb_obj,   /* number of objects to add inside big (I) */
             int       nb_big,   /* number of objects of big (I)            */
             int      *size_big, /* size of big (I/O)                       */
             short   **big)      /* BIG array                               */

{
  int incr;

  *msg = MSSUCC;

  if( nb_obj > INCR ) incr = nb_obj;
  else                incr = INCR;

  if(nb_big + nb_obj >= *size_big)
  {
    if(*size_big == 0)
    {
      *big = _MALLOC (ROW * incr, short);
    }
    else
    {
      *big = _REALLOC (*big, (*size_big + incr) * ROW, short);
    }

    if(*big == NULL)
    {
      printf("No dynamic space avalaible for big\n");
      *msg = 10;
      return 0;
    }

    *size_big = *size_big + incr;
  }

  return OM_S_SUCCESS;
}


/**********************************************************************
 *
 *  big_dealloc:
 *
 *   free the structure big.
 *
 **********************************************************************/

int
big_dealloc (short   **big,
             int       nb_big)

{

 if ((*big != NULL) && (nb_big != 0))
    _FREE (*big);

 return OM_S_SUCCESS;
}



/*************************************************************************
 *
 *      ISget_cp_con:
 *
 *      Given an component and the corresponding neighbor, returns
 *      the corresponding cp number of the neighbor.
 *
 *      The cp number is now known (23 Apr 91), so ....
 *
 *************************************************************************/

int
ISget_cp_con (long  *msg,           /* complection code (O)                 */
       struct GRid   cmp,           /* identifier of the component (I)      */
              int   *cp_con_number, /* cp number of the neighbor (O)        */
              int    ncp_number)    /* Ce que l'on recherche    (I)         */

{
  long           status;
  int            nb_hangers;
  struct GRid    hangers[MAX_CP];

  *msg           =  0;
  *cp_con_number = -1;

  if(ncp_number != -1)
  {
    /*"connected cp: %d\n", ncp_number */
    *cp_con_number = ncp_number;
    *msg = 1;
    return 1;
  }

  /*|get_hangers\n*/
  status =
  om$send (msg = message VRGeneric.VRGetHangers
                           (msg,MAX_HANGERS, hangers, &nb_hangers, NULL, NULL),
      senderid = NULL_OBJID,
      targetid = cmp.objid,
      targetos = cmp.osnum);
  as$status(action = RET_STATUS);

  if(nb_hangers > 0)
  {
    /*|found, corresponding cp of the object with support\n*/
    *cp_con_number = 0;
    *msg = 1;
    return 1;
  }

  /*|ISget_cp_con, connected cp number not found\n*/
  return 1;
}

/*************************************************************************
 *
 *      ISget_cmp_cp_index:
 *
 *      Given an component and its cp number, returns the index in big.
 *      To be faster, a start index and an end index are given. The
 *      research will be done from the start index to the end index.
 *
 *
 *************************************************************************/

int
ISget_cmp_cp_index (long   *msg,       /* complection code (O)               */
             struct GRid    cmp,       /* identifier of the component (I)    */
                    int     cp_number, /* cp number of the component (I)     */
                    int     nb_big,    /* number of components of big (I)    */
                    short  *big,       /* big array (I)                      */
                    int     frm,       /* start index (I)                    */
                    int     to,        /* end index (I)                      */
                    int    *index)     /* cp number of the neighbor (O)      */

{
 struct GRid    big_id;
 short          cp;

 *msg = 0;

#ifdef MY_DEBUG
  printf("look for component: %d, %d, with cp number:%d, frm: %d, to: %d\n",
          cmp.objid, cmp.osnum, cp_number, frm, to);
#endif

  if(frm < 0 || frm > nb_big || frm > to || to > nb_big )
  {
    printf("et les arguments alors, ca va pas du tout (from & to index) !!!\n");
    return 0;
  }

  for(*index=frm;*index<to;*index=*index+1)
  {
     get_big(big,ROW,*index,B_OBJID,2,(short *)&big_id.objid);
     get_big(big,ROW,*index,B_OSNUM,1,(short *)&big_id.osnum);
     get_big(big,ROW,*index,B_CP,1,(short *)&cp);

     if (cp_number == -1) cp = cp_number;

     if(IF_EQ_OBJID(big_id.objid,cmp.objid) &&
        big_id.osnum == cmp.osnum &&
        cp == cp_number)
     {
        /*"found, index: %d\n", *index*/
         *msg = 1;
         return 1;
     }
  }

  *index=-1;
  return 1;
}

end implementation Root;

