/* $Id: vdanmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        /include/vdanmacro.h
 *
 * Description: 
 *	This file defines macros to place annotation/item
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdanmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/09/18  03:13:12  pinnacle
 * Replaced: include/vdanmacros.h for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.6  1995/07/13  13:14:32  pinnacle
 * Replaced: include/vdanmacros.h for:  by jwfrosch for vds.240
 *
 *
 * History:
 *      08/07/94        Chaya V. Rao
 *	12/13/94	R. Manem	vd$getItemNoForObj macro
 *	06/15/95	tlb		Modify to use item number string
 *				 	   vd$place_item, vd$getItemNoForObj	
 *
 */

/*============================================================================*/
#ifndef vdanmacro_include
#define vdanmacro_include


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDannot_place __(( struct GRobj_env       *object,
                              IGRchar                *format,
                              IGRchar                *param,
                              IGRuchar               box,
                              struct VDan_ldrline    *leader_line,
			      IGRdouble	             position,
                              IGRpoint               offset, 
                              struct EX_button       *window,
			      struct GRid            *p_annot ));

extern int VDitem_place __((  struct GRobj_env    *object,
                              IGRint              *bln_type,
                              IGRint              *bln_sides,
                              IGRdouble           *bln_size,
                              IGRint              quantity,
                              struct VDan_ldrline *leader_line,
			      IGRdouble		  position,
                              IGRpoint            offset,
                              struct EX_button    *window,
                              struct GRid         *p_item,
                              IGRchar             *itemNo ));

extern IGRlong VDgetItemNoForObj __(( 	struct GRid	obj,
					IGRchar		*tblName,
					struct GRid	*itemId,
					IGRchar		**itemNo,
					IGRboolean	*found ));

#if defined(__cplusplus)
}
#endif

/*============================================================================*/
/* -----------------------------------------------------------------------------

  MACRO
	vd$place_annot (  );

  ABSTRACT

	Place "Formatted Text with Leader" objects without leader line. 

  ARGUMENTS
        
        data type         argument     I/O    description

        struct GRobj_env  *object      I      the object to be annotated
        IGRchar           *format      I      the annotation format
        IGRchar           *param       I      the object parameters
        IGRuchar          box          I      box option no/yes/oval
        struct VDan_ldrline*leader_lineI      leader line structure 
        IGRdouble         position     I      annotation placement position
        IGRpoint          offset       I      offset from placement point
        struct EX_button  *window      I      needed to get the window id
        struct GRid       *p_annot     O      create annotation object
        	

  EXAMPLE
        
	sts = vd$place_annot ( object     =  &object,
                               format     =  "%.2f",
                               param      =  "diam",
                               box        =  VD_box_DISPLAY,
                               leader_line=  &leader_line, 
                               position   =  position,
                               offset     =  offset, 
                               window     =  &window   
                             );
	
  REMARKS

        * window which is a EX_button stucture can be obtained from GRevent
        * position can be one of the placement positions- defined in vdann.h

  Return Status
        OM_S_SUCCESS     if success
        OM_E_NODYNMEM    no dynamic memory
        OM_W_ABORT       some other error
    


  ------------------------------------------------------------------------- */

#omdef	vd$place_annot (object,
                        format,
                        param    = NULL, 
                        box      = 1,
                        leader_line = NULL, 
                        position = VD_ANNOT_CENTER_CENTER,
                        offset, 
			window,
			p_annot  = NULL )
                             

	VDannot_place( (object), (format), (param), (box), (leader_line),
			(position), (offset), (window), (p_annot) )

#endomdef

/*============================================================================*/

/* -----------------------------------------------------------------------------

  MARCO
	vd$place_item (  );

  ABSTRACT

	Place "Item Number" objects without leader line. 

  ARGUMENTS

        data type         argument    I/O     description

        struct GRobj_env  *object      I      the object to be annotated
        IGRint            *bln_type    I      balloon type
        IGRint            *bln_side    I      balloon sides if sides > 4,
        IGRdouble         *bln_size    I      balloon size ratio
        IGRint            quantity     I      quantity
        structVDan_ldrline*leader_line I      leader_line structure
        IGRdouble         position     I      item placement position
        IGRpoint          offset       I      offset from placement point
        struct EX_button  *window      I      gives the window id to project
        struct GRid       *p_item      O      created balloon object
        IGRchar           *itemNo      I      the item number string

  EXAMPLE

	sts = vd$place_item ( object     =   &object,
                              bln_type   =   &bln_type,
                              bln_sides  =   &bln_sides,
                              bln_size   =   &bln_size,
                              quantity   =   1,
                              position   =   position,
                              leader_line=   &leader_line,
                              offset     =   offset, 
                              window     =   &window,
                              p_item     =   &p_item,
                              itemNo     =   "V-1");

  REMARKS

        * window which is a EX_button stucture can be obtained from GRevent
        * position can be one of the placement positions- defined in vdann.h
        * bln_type is defined in dimdef.h
        * bln_size should be greater than 1.5
        * bln_sides is defined if the bln_type is a polygon

  Return Status
        OM_S_SUCCESS     if success
        OM_E_NODYNMEM    no dynamic memory
        OM_W_ABORT       some other error

  ------------------------------------------------------------------------- */

#omdef	vd$place_item (object,
                       bln_type		= NULL,
                       bln_sides	= NULL,
                       bln_size		= NULL,
                       quantity         =   1,
                       leader_line      = NULL,
                       position         = VD_ANNOT_CENTER_CENTER,
                       offset,
                       window,
                       p_item		= NULL,
		       itemNo )
    
        VDitem_place ( (object), (bln_type), (bln_sides),
                     (bln_size), (quantity), (leader_line), (position),
                     (offset), (window), (p_item), (itemNo))

#endomdef

/*============================================================================*/

/* -----------------------------------------------------------------------------

  MACRO
        vd$getItemNoForObj

  ABSTRACT

        Gets the item number, prefix, prefix flag, and the item object for
        a given object and table name.

  ARGUMENTS

        struct GRid     obj          I      the GRid of the object
        IGRchar         *tblName     I      the name of the bom table
        struct GRid     *itemId      O      id of the item object if found
        IGRchar         **itemNo     O      item number for object
        IGRboolean      *found       O      whether item number is found or not

  REMARKS

        * memory will be allocated for itemPfx, and has to be freed by the
          caller
        * pfxFlag = 0 for prefix, = 1 for postfix
        * found = 1 if item number exists, = 0 otherwise

  Return Status
        OM_S_SUCCESS     if success
        OM_E_NODYNMEM    no dynamic memory

  ------------------------------------------------------------------------- */

#omdef  vd$getItemNoForObj(     obj,
                                tblName,
                                itemId          = NULL,
                                itemNo          = NULL,
                                found )

        VDgetItemNoForObj( obj, tblName, itemId, itemNo, found )
#endomdef


#endif
