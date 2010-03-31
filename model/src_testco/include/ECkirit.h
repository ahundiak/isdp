/****************************************************************
                        PROMPT STRINGS
****************************************************************/

# define ECsP_Identify_elt       "Identify element"
    /* Prompt user to identify an element */

#define ECsP_Identify_linear_elt  "Identify linear element"
  /* prompt user to identify linear element */

# define ECsP_Accept_reject_elt "Accept/reject"
    /* Prompt user to accept or reject an element with a point*/

# define ECsP_processing   "Processing"
    /* Tell user program is now processing his command */
 
# define ECsP_Accept_reject_cv2 \
         "Accept with boundary curve 2/reject"
/* Prompt user to accept second curve or reject  */

# define ECsP_Accept_reject_cv3 \
         "Accept with boundary curve 3/reject"
/* Prompt user to accept third curve or reject  */

# define ECsP_Accept_reject_cv4 \
         "Accept with boundary curve 4/reject"
/* Prompt user to accept forth curve or reject  */

#define ECsP_Identify_cv1 "Identify first boundary curve"
/* Prompt user to identify first boundary */

#define ECsP_Identify_cv2 "Identify second boundary curve"
/* Prompt user to identify first boundary */

#define ECsP_Identify_cv3 "Identify third boundary curve"
/* Prompt user to identify first boundary */

#define ECsP_Identify_cv4 "Identify fourth boundary curve"
/* Prompt user to identify first boundary */

# define ECsP_InputBsPt    "Input base point"
    /* Prompt user to input a base point for a cylinder */

# define ECsP_InputHtPt    "Input height point"
    /* Prompt user to input a height point for a cylinder */

# define ECsP_EnterRad     "Enter radius"
    /* Prompt user to keyin or input radius of cylinder */

#define ECsP_Input_bend_rad \
  "Input bend radius %d"
/* prompt for input bend radius */

# define ECsP_InputCentPt  "Input center point"

#define ECsP_reloc "Curve not found"

#define ECsP_Input_tube_rad "Enter tube radius"
 /* prompt user to input tube radius */

#define ECsP_linear_elenotfound \
  "Linear element not found"

/****************************************************************
                        STATUS STRINGS
****************************************************************/

# define ECsS_Internal_error_cont \
    "Internal error, continuing"
    /* Announce some kind of internal error, continuing
        command */

# define ECsS_Internal_error_term \
    "Internal error, terminating"
    /* Announce some kind of internal error, terminating
        command */

# define ECsS_Internal_error_retry \
    "Internal error, retry"
    /* Announce some kind of internal error, retry command */

# define ECsS_Invalid_input          "Invalid input"
    /* Announce data point was invalid */

# define ECsS_Invalid_class_of_elt   "Element not of a valid class"
    /* Announce element is not a member of a valid class for
        a given operation */

# define ECsS_ZeroAxis   "Zero length axis"
    /* Zero length axis for a cylinder */

# define ECsS_ZeroRad  "Zero radius"

# define ECsS_CouldNotMakeObj "Could not make object"

# define ECsS_DsplRef "Display request refused"


/****************************************************************
                        COMMAND STRINGS
****************************************************************/


/****************************************************************
                         ERROR STRINGS
****************************************************************/

# define ECsE_GRsvempty  "GRsv.GRsvempty error"

# define ECsE_lnproj_by_svpass  "GRlnproject by GRsvpass"

# define ECsE_GRsvpass  "GRsv.GRsvpass error"

# define ECsE_drawcross  "DPdrawcross error"

# define ECsE_display  "ECpydybf error"

# define ECsE_GRget_token  "GRget_token error"

# define ECsE_COsvlocate  "COsvlocate error"

# define ECsE_disp_by_svpass  "GRdisplay by GRsvpass"

# define ECsE_GRdisplay  "GRdisplay error"

# define ECsE_obj_not_on_sv  "object not on the saveset"

# define ECsE_geomprops_by_svpass  "GRgeomprops by GRsvpass"

# define ECsE_GRgeomprops  "GRgeomprops error"

# define ECsE_BSdistptli  "BSdistptli error"
 
# define ECsE_BSdistptpt  "BSdistptpt error"

# define ECsE_OMconvertNumToName \
    "OM_convert_OS_number_to_name error"

# define ECsE_OMconstructByName \
    "OM_construct_object_by_name error"

# define ECsE_ECsavedraw   "ECsavedraw.wakeup error"

# define ECsE_GRdelete  "GRdelete error"

# define ECsE_getattr_by_svpass  "GRgetattr by GRsvpass error"

# define ECsE_GRgetattr  "GRgetattr error"

# define ECsE_putattr_by_svpass  "GRputattr by GRsvpass error"

# define ECsE_GRputattr  "GRputattr error"

# define ECsE_EXputq_front "EXputq_front error"

# define ECsE_send_chan "OM_send_channel error"

# define ECsE_GRsvoadd "GRsvoadd error"

# define ECsE_GRsvputpath "GRsvputpath error"

# define ECsE_GRsvopass "GRsvopass error"

/****************************************************************
                           SUBSTRINGS
****************************************************************/


/****************************************************************
                           MESSAGE STRING
****************************************************************/

#define ECsM_suby3bound "Place surface by 3 boundaries"
  /* message for the user for start object command   */

#define ECsM_suby4bound "Place surface by 4 boundaries"
  /* message for the user for start object command   */

#define ECsM_planebyele \
  "Place plane encompassing planar element"
/* message to start command object */

#define ECsM_ECtubesur \
  "Place tube surface" /* message to start command object */


