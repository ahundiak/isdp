/* $Id: VDPplMac.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDPplMac.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDPplMac.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
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
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef VDPplMac_include
#define VDPplMac_include

/*                        VDPplMac.h                                     */
/* This file is exclusively for use in a PPL for setting attributes      */
/* of an equipment                                                       */


#define VD_TEXT_ATTRIB          1
#define VD_DOUBLE_ATTRIB        2

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDGetAttribute __((IGRlong         *msg, 
			      struct GRid     *object,    
			      struct GRmd_env *md_env,    
			      IGRchar         *name_att, 
			      IGRshort        *data_type, 
			      IGRchar         *text_value,
			      IGRdouble       *double_val
			      ));

extern int VDSetAttribute __((IGRlong     *msg, 
			      struct GRid *object,    
			      IGRchar     *name_att, 
			      IGRshort    data_type, 
			      IGRchar     *text_value,
			      IGRdouble   double_val
			      ));

extern int VDEquipName __((IGRlong     *msg, 
			      struct GRid *object,    
			      struct GRmd_env *md_env,    
			      IGRchar     *family_name
			      ));

#if defined(__cplusplus)
}
#endif


/* Declaration of two variables for this PPL                                 */ 

struct GRid 	EQUIP_ID  ;
struct GRmd_env	EQUIP_ENV ;


/*---------------------------------------------------------------------------
  
  MACRO
 
  VD$GetAttribute( msg,             
  		   object = &EQUIP_ID,
                   md_env = &EQUIP_ENV,
    		   name_att,         
                   data_type = NULL,        
                   text_value = NULL,
                   double_value = NULL);

 ABSTRACT
   Given an object and a name of an attribute, this macro gets
   the value and type of attribute for this object

ARGUMENTS :

IGRlong     *msg          [O] Return code OM_S_SUCCESS or OM_E_ABORT 

struct GRid *object       [I] Object to look for attribut    

struct GRmd_env *md_env   [I] env of the object

IGRchar     *name_att     [I] Name of the attribut to retrieve 

IGRshort    *data_type    [O] Type of data return
                          (VD_TEXT_ATTRIB or VD_DOUBLE_ATTRIB)              

IGRchar     *text_value    [O] Data return if AC_ATTRIB_TXT           

IGRdouble   *double_val    [O] Double value return  if AC_ATTRIB_DOUBLE  


 Notes
 ------
  if data_type of attributes is known , you can give only
  text_value or double_value else you can give both 
 
 ------------------------------------------------------------------------*/

#omdef 
    VD$GetAttribute( msg,             
		     object = &EQUIP_ID,
                     md_env = &EQUIP_ENV,
		     name_att,         
		     data_type = NULL,        
		     text_value = NULL,
		     double_value = NULL);
		   
    VDGetAttribute ((msg), (object), (md_env), (name_att), (data_type), 
	            (text_value), (double_value)); 
	
#endomdef

/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
  
MACRO

VD$SetAttribute( msg,             
		 object = &EQUIP_ID,
		 name_att,         
                 data_type = VD_TEXT_ATTRIB,        
                 text_value = NULL ^
                 double_value = 0.0)

/* This macro set the value and type of attribute name_att for object 

ARGUMENT DESCRIPTION:

IGRlong     *msg            [O] Return code OM_S_SUCCESS or OM_E_ABORT 

struct GRid *object         [I] Object to look for attribut 

IGRchar    *name_att        [I] Name of the attribut to set 

IGRshort   data_type        [I] Type of data for this attribute  
                                VD_TEXT_ATTRIB or VD_DOUBLE_ATTRIB

IGRchar    *text_value      [I] Data to set if text              

IGRdouble  double_val       [I] Double value set              

 ------------------------------------------------------------------------*/

#omdef 
    VD$SetAttribute( msg,             
		     object = &EQUIP_ID,
		     name_att,         
		     data_type = VD_TEXT_ATTRIB,        
		     text_value = NULL ^
		     double_value = 0.0)

    VDSetAttribute ((msg), (object), (name_att), (data_type), 
	            (text_value), (double_value)); 
	
#endomdef





/*---------------------------------------------------------------------------
  
  MACRO
 
  VD$EquipName   ( msg,             
  		   object = &EQUIP_ID,
                   md_env = &EQUIP_ENV,
    		   family_name = NULL);


 ABSTRACT
   Given an equipment this macro will return his family_name.


ARGUMENTS :

IGRlong     *msg          [O] Return code OM_S_SUCCESS or OM_E_ABORT 

struct GRid *object       [I] Object to look for attribut    

struct GRmd_env *md_env   [I] env of the object

IGRchar     *family_name   [I] Family Name of the equipment
 
 ------------------------------------------------------------------------*/

#omdef 
    VD$EquipName    ( msg,             
		     object = &EQUIP_ID,
                     md_env = &EQUIP_ENV,
		     family_name = NULL);
		   
    VDEquipName ((msg), (object), (md_env), (family_name)); 
	
#endomdef

#endif
