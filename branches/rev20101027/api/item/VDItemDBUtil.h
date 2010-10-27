/* $Id: VDItemDBUtil.h,v 1.3 2001/01/14 16:39:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDItemDBUtil.h
 *
 * Description: Routines for getting additional attributes from database tables
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDItemDBUtil.h,v $
 *      Revision 1.3  2001/01/14 16:39:21  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/09 21:35:20  art
 *      ah
 *
 * Revision 1.1  2000/12/06  20:38:28  pinnacle
 * Created: vds/api/item/VDItemDBUtil.h by jdsauby for Service Pack
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/08/00  js      Creation
 *
 ***************************************************************************/

#ifndef VDItemDBUtil_include
#define VDItemDBUtil_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -------------------------------------------------------------------
 * Need a method to pass an array of collectors from a PPL.  This struct
 * should do the trick.
 * *****/
typedef struct {
    IGRint		cnt;         /* The number of attributes in collector           */
    IGRint		max;         /* Used to determine when more mem needs allocated */
    IGRint		inc;         /* mem allocation increments                       */
    struct ACrg_coll    *attrs;      /* ACrg_collect                                    */
} TVDitemdbCollAttrs;


/* --------------------------------------------------------------------
 * Shared functions for the TVDitemdbCollAttrs structure
 * ***/

/* ----------------------------------------------------------
 * Add an attribute to the TVDitemdbCollAttrs structure
 * ***/
extern IGRstat VDitemdbAddCollAttr __((	TVDitemdbCollAttrs 	*list,
				 	struct ACrg_coll 	*attr  ));

/* -----------------------------------------------
 * Frees a TVDitemdbCollAttrs structure
 */
extern IGRstat VDitemdbFreeCollAttrs __(( TVDitemdbCollAttrs *list ));

/* -----------------------------------------------------------
 * Init TVDitemdbCollAttrs structure 
 * ***/
extern IGRstat VDitemdbInitCollAttrs __(( TVDitemdbCollAttrs *list ));


/*+Me
  External Macro vd$item_add

  Abstract
      This function is used to add an attribute (struct ACrg_coll) to
      a list of attributes (TVDitemdbCollAttrs).  It keeps track of the
      number of attributes, and will allocate memory as required.

  Arguments
      TVDitemdbCollAttrs *list            (I/O)  pointer to list of attributes
      struct ACrg_coll   *attr            (I)    pointer to attribute

  Status/Return Code
      1    : if success
      0    : some error

  Remarks
      Memory for the output of parameters will be allocated by the macro
      and has to be initialized and freed by the caller.

-Me*/

#omdef vd$item_add(   list, attr )
     VDitemdbAddCollAttr( (list), (attr) );
#endomdef

/*+Me
  External Macro vd$item_init

  Abstract
      This function is used to initialize TVDitemdbCollAttrs

  Arguments
      TVDitemdbCollAttrs *list            (I/O)  pointer to list of attributes

  Status/Return Code
      1    : if success
      0    : some error

  Remarks
      Memory for a list of 100 attributes will be initialy allocated.  The macro
      vd$item_add will allocate more memory as required.  Memory is incremented
      by slots of 100.

-Me*/

#omdef vd$item_init( list )
     VDitemdbInitCollAttrs ( (list) );
#endomdef

/*+Me
  External Macro vd$item_free

  Abstract
      This function is used to free up memory allocated for TVDitemdbCollAttrs

  Arguments
      TVDitemdbCollAttrs *list            (I/O)  pointer to list of attributes

  Status/Return Code
      1    : if success
      0    : some error

  Remarks
      Memory for the list will be freed. 

-Me*/

#omdef vd$item_free( list )
     VDitemdbFreeCollAttrs ( (list) );
#endomdef

//Cleanup
#if defined(__cplusplus)
#endif

#endif
