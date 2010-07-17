/*********************************************************************

Author    :    Jaimin Mehta (Huntsville)

Creation:    September 9, 1993


        This file contains the definition of connector command
    
Change History :


          date    |  name     |  modification's description
        --------+--------+-----------------------------------
        10/3/93 l Jaimin l Added constants for extended forms
 
*********************************************************************/

#ifndef    vr_VRconnectordef_include

#define    vr_VRconnectordef_include


/*C    variable needed to allocate values and names attributes buffers */
#define VR_MAX_CHAR                80

/*C    state table */
#define VR_CONN_DYN               501 
#define VR_CONN_PLACED            536 
#define VR_LG_NO_FREE_CONN        621
#define VR_LG_FORM_FINISHED       622


/*C    forms     */
#define VR_CONNECTOR_FORM           0
#define USR_PARAM_FORM              1

/*C    fields     */

#define    CN_FI_HEADER            11
#define    CN_EL_HEADER            30
#define    CN_PI_HEADER            31
#define    CN_HV_HEADER            32
#define    CN_GN_HEADER            33
#define    CN_FI_EQ_HDR            36

#define    LBL_CONNECTOR_TAG       12
#define    CN_CONNECTOR_TAG        14

#define    LBL_COMP_CODE           16
#define    CN_COMP_CODE            17

#define    LBL_MACRO_NAME          35
#define    CN_MACRO_NAME           17   /*   Re-use field, just change text */

#define    LBL_CONST_STATUS        20
#define    CN_CONST_STATUS         21

#define    LBL_APPROV_STATUS       22
#define    CN_APPROV_STATUS        23

#define    LBL_NO_MTO              25
#define    CN_NO_MTO               24

#define    LBL_UNIT                29
#define    CN_UNIT                 15

#define    LBL_SYSNAM              28
#define    CN_SYSNAM               26

#define    LBL_ZONE                27
#define    CN_ZONE                 13

#define USR_ATTR_BUTTON            34

#define    LBL_NOTES               18
#define    CN_NOTES                19

#define    MSG_1                 9
#define    MSG_2                10
#define    MSG                  10

#define    ELEC_TERM            900
#define    FOPTIC_TERM          901
#define    PIPE_NOZZLE          902
#define    HVAC_NOZZLE          903

#define    ELEC_PIN             904
#define    FOPTIC_PIN           905

#define    ELEC_CABLE           906
#define    FOPTIC_CABLE         907 /* not in Nabil's memo */


#endif

