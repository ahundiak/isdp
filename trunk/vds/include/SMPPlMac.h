/* $Id: SMPPlMac.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMPPlMac.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMPPlMac.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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
 * Revision 1.2  1996/05/27  05:15:32  pinnacle
 * Replaced: include/SMPPlMac.h for:  by apazhani for vds.240
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

#ifndef SMPPlMac_include
#define SMPPlMac_include

/*                        SMPPlCompMac.h                                     */
/* This file is exclusively for use in a PPL for setting attributes          */
/* of a compartment                                                          */



#define SM_TEXT_ATTRIB    1         /* Type of attribute is text   */
#define SM_DOUBLE_ATTRIB  2         /* Type of attribute is double */


#define SM_AFT_FRAME      3
#define SM_FORE_FRAME     4

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int SMGetAttribute __((IGRlong     *msg, 
			      struct GRid *object,    
			      IGRchar     *name_att, 
			      IGRshort    *data_type, 
			      IGRchar     *text_value,
			      IGRdouble   *double_val
			      ));

extern int SMSetAttribute __((IGRlong     *msg, 
			      struct GRid *object,    
			      IGRchar     *name_att, 
			      IGRshort    data_type, 
			      IGRchar     *text_value,
			      IGRdouble   double_val
			      ));

extern int SMAftForeFrame __((IGRlong     *msg, 
			      struct GRid *vol_id,
			      struct GRmd_env *md_env,
			      IGRint          *low_fr_num, 
			      IGRchar        *low_fr_name, 
			      IGRdouble	     *low_fr_dist,
			      IGRint         *high_fr_num, 
			      IGRchar        *high_fr_name,
			      IGRdouble	     *high_fr_dist,
			      IGRshort       which_frame   
			      ));

extern int SMCompCmpSide  __((IGRlong          *msg,       
			      struct GRid      *vol_id,        
			      struct GRmd_env  *md_env,    
			      int	       *side       
			      ));

#if defined(__cplusplus)
}
#endif

/* Declaration of two variables for this PPL                                 */ 

struct GRid 	COMP_ID  ;
struct GRid     VOL_ID   ;
struct GRmd_env	COMP_ENV ;


/*---------------------------------------------------------------------------
  
  MACRO
 
  SM$GetAttribute( msg,             
  		   object = &COMP_ID,
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

IGRchar     *name_att     [I] Name of the attribut to retrieve 

IGRshort    *data_type    [O] Type of data return
                          (SM_TEXT_ATTRIB or SM_DOUBLE_ATTRIB)                                

IGRchar     *text_value    [O] Data return if AC_ATTRIB_TXT           

IGRdouble   *double_val    [O] Double value return  if AC_ATTRIB_DOUBLE  


 Notes
 ------
  if data_type of attributes is known , you can give only
  text_value or double_value else you can give both 
 
 ------------------------------------------------------------------------*/

#omdef 
    SM$GetAttribute( msg,             
		     object = &COMP_ID,
		     name_att,         
		     data_type = NULL,        
		     text_value = NULL,
		     double_value = NULL);
		   
    SMGetAttribute ((msg), (object), (name_att), (data_type), 
	            (text_value), (double_value)); 
	
#endomdef

/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
  
MACRO

SM$SetAttribute( msg,             
		 object = &COMP_ID,
		 name_att,         
                 data_type = SM_TEXT_ATTRIB,        
                 text_value = NULL ^
                 double_value = 0.0)

/* This macro set the value and type of attribute name_att for object 

ARGUMENT DESCRIPTION:

IGRlong     *msg            [O] Return code OM_S_SUCCESS or OM_E_ABORT 

struct GRid *object         [I] Object to look for attribut 

IGRchar    *name_att        [I] Name of the attribut to set 

IGRshort   data_type        [I] Type of data for this attribute  
                                SM_TEXT_ATTRIB or SM_DOUBLE_ATTRIB

IGRchar    *text_value      [I] Data to set if text              

IGRdouble  double_val       [I] Double value set              

 ------------------------------------------------------------------------*/

#omdef 
    SM$SetAttribute( msg,             
		     object = &COMP_ID,
		     name_att,         
		     data_type = SM_TEXT_ATTRIB,        
		     text_value = NULL ^
		     double_value = 0.0)

    SMSetAttribute ((msg), (object), (name_att), (data_type), 
	            (text_value), (double_value)); 
	
#endomdef

/* -------------------------------------------------------------------------- */

/*---------------------------------------------------------------------------
  
MACRO

SM$AftForeFrame( msg,
                 vol_id = &VOL_ID, 
                 md_env = &COMP_ENV,
                 *low_fr_num = NULL,
                 *low_fr_name = NULL,
		 *low_fr_dist = NULL,
		 *high_fr_num = NULL , 
                 *high_fr_name = NULL,
		 *high_fr_dist = NULL,
                 which_frame   = SM_FORE_FRAME
)

This macro compute  the fore or aft frame of a volume .
It can give the frame number or frame name.
If the volume is exactly on a frame it give low_frame and high_frame are equal.
If not:
-low_frame is : inside the volume for SM_FORE_FRAME
                outside for SM_AFT_FRAME 
-high_frame is : outside the volume for SM_FORE_FRAME
                 inside for SM_AFT_FRAME

ARGUMENT DESCRIPTION:

IGRlong          *msg,        [I] Completion code                      

struct GRid      *vol_id,     [I] Volume to look for aft and fore frame

struct GRmd_env  *md_env,     [I] Module env of the volume             

IGRint          *low_fr_num,  [O] Lowest frame number                      

IGRchar        *low_fr_name,  [O] Lowest frame name                       

IGRdouble      *low_fr_dist,  [O] Lowest frame distance (in design file unit) 

IGRint         *high_fr_num,  [O] Highest Frame number                     

IGRchar        *high_fr_name, [O] Highest frame name  

IGRdouble      *high_fr_dist, [O] Highest frame distance (in design file unit)

IGRshort       which_frame    [I] SM_AFT_FRAME or SM_FORE_FRAME         

 ------------------------------------------------------------------------*/

#omdef 

SM$AftForeFrame( msg = msg,
                 vol_id = &VOL_ID, 
                 md_env = &COMP_ENV,
                 low_fr_num   = NULL,
                 low_fr_name  = NULL,
		 low_fr_dist  = NULL,
		 high_fr_num  = NULL , 
                 high_fr_name = NULL,
		 high_fr_dist = NULL,
                 which_frame  = SM_FORE_FRAME)

SMAftForeFrame((msg), (vol_id), (md_env),
	       (low_fr_num),(low_fr_name),(low_fr_dist),
	       (high_fr_num), (high_fr_name),(high_fr_dist),(which_frame));
	
#endomdef

/* -------------------------------------------------------------------------- */

/*---------------------------------------------------------------------------
  
MACRO

SM$CompCmpSide(msg,      
               vol_id  = &VOL_ID,     
	       md_env = &COMP_ENV, 
	       side      
)

This macro compute the compartment side
( 1 = starboard , 2 = portside , 0 = centerline)

ARGUMENT DESCRIPTION:

IGRlong          *msg,        [I] Completion code                      

struct GRid      *vol_id,     [I] Volume to look for compartment side

struct GRmd_env  *md_env,     [I] Module env of the volume             

IGRint           *side        [O] side of compartment

 ------------------------------------------------------------------------*/

#omdef

SM$CompCmpSide(msg,      
               vol_id  = &VOL_ID,     
	       md_env = &COMP_ENV, 
	       side)

SMCompCmpSide((msg),(vol_id), (md_env),(side))

#endomdef

/* -------------------------------------------------------------------------- */

#endif









