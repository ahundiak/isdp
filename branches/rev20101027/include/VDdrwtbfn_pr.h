/* $Id: VDdrwtbfn_pr.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDdrwtblfn_pr.h
 *
 * Description:
 *      This code includes prototype functions which are used for sort table
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwtbfn_pr.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
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
 * Revision 1.1  1995/06/07  21:41:54  pinnacle
 * Created: include/VDdrw*.h by tdumbach for vds.240
 *
 * Revision 1.1  1995/05/31  19:36:44  pinnacle
 * Created: include/VDdrwtbfn_pr.h by yzhu r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/26/95          YZ            include file to define sort table
 *                                      table function  prototype
 *************************************************************************/

#ifndef  VDdrwtblfn_pr_h

#define  VDdrwtblfn_pr_h

/* ------------------------------------------------------------------------ */
extern IGRlong VDsort_tbl(
        IGRlong            *msg,
        IGRchar            *Tabnam,
        struct GRobj_env   *objs,
        struct VDrowinfo   *Rowinfo,
        IGRint             nbObjects,
        IGRint             nbRows );
/* ---------------------------------------------------------------------
  Abstract
     This function is used to sort table

  Arguments
     IGRlong            *msg,                 O return code.
     IGRchar            *Tabnam,              I sort criteria table name
     struct GRobj_env   *objs               I/O the list of object
     struct VDrowinfo   *Rowinfo            I/O the list of row
                                                info and summarization info.
     IGRint             nbObjects             I nunber of objects
     IGRint             nbRows                I nunber of objects

  Note: 
           *----------------------------------------------------*
           * About  type match proble: for each object, the attr*
           * type is double/text. we have following rules when  *
           * input type mismatch with  attr type                *
           *----------------------------------------------------*
           * attr type  | input type | assign type | screen     *
           * double     | string     | double      | value      *
           * string     | double     | NULL_VAL_STR| NULL       *
           *            |            | + error mess|            *
           * no exist   | string     | null        | NULL       *
           * no exist   | double     | NULL_VAL_STR| NULL       *
           *----------------------------------------------------*

           Here:  NULL_VAL_STR = '!@!'  
                  The rows with NULL_VAL_STR are put bottom of the column.

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

  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error

------------------------------------------------------------------------ */

#endif
