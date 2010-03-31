/****************************************************************
                        PROMPT STRINGS
****************************************************************/

# define ECsP_Identify_elt   "Identify element"

# define ECsP_Identify_crv   "Identify curve"

# define ECsP_Identify_surf  "Identify surface"

# define ECsP_Identify_srf1  "Identify surface 1"

# define ECsP_Identify_srf2  "Identify surface 2"

# define ECsP_Identify_crv1  "Identify curve 1"

# define ECsP_Identify_crv2  "Identify curve 2"

# define ECsP_SurfNotFound  "Surface not found"

# define ECsP_CrvNotFound  "Curve not found"

# define ECsP_Accept_reject_elt "Accept/reject"

# define ECsP_Accept_reject_stpt "Accept with a start pt/reject"
    /* Prompt user to accept or reject an element with a start pt */

# define ECsP_Accept_reject_crv2 "Accept with curve 2/reject"

# define ECsP_Accept_reject_srf2 "Accept with surface 2/reject"

# define ECsP_Accept_reject_capt1 \
     "Accept with align pt on crv 1/reject"

# define ECsP_Accept_reject_sapt1 \
     "Accept with align pt on surf 1/reject"

# define ECsP_Accept_reject_pt1 \
    "Accept with pt1 of prj vector/reject"
    /* Prompt user to accept/reject with first point of prj vector */

# define ECsP_Keyin_max_length  "Key in maximum length of lines"
    /* Prompt user to give max length for radius of curvature */

# define ECsP_Keyin_num_lines \
   "Key in number of places of curvature desired"
    /* Prompt user to give number of lines from center to element */

# define ECsP_Keyin_UVB_dir \
   "Key in 'u', 'v', or 'b'(both) direction for alter"

#define ECsP_Keyin_rad_ulines \
   "Key in the number of node points in u"

#define ECsP_Keyin_rad_vlines \
   "Key in the number of node points in v"

# define ECsP_Keyin_u_lines \
    "Key in number of rules between natural rules in U"

# define ECsP_Keyin_v_lines \
    "Key in number of rules between natural rules in V"

# define ECsP_Keyin_ulines  "Key in number of u rule lines to display"

# define ECsP_Keyin_order  "Key in new order: %d-%d"

# define ECsP_Keyin_vlines  "Key in number of v rule lines to display"

# define ECsP_Keyin_mult  "Key in multiplicity: 1-%d [1]"

# define ECsP_Keyin_mode  "Key in mode: 0-3"

# define ECsP_many_or_single_elt \
   "Output a graph(g), many(m), or single(s) element?"

# define ECsP_Input_cpt1  "Input alignment pt on crv 1"

# define ECsP_Input_cpt2  "Input alignment pt on crv 2"

# define ECsP_Input_spt1   "Input alignment pt on srf 1"

# define ECsP_Input_spt2  "Input alignment pt on srf 2"

# define ECsP_Input_knot  "Input knot on element"

# define ECsP_Input_str_pt  "Input start point"

# define ECsP_Input_end_pt  "Input end point / move on"

# define ECsP_Input_legend_pnt \
    "Input upper left-hand corner point of legend"

# define ECsP_Color_display \
    "Do you want to output color display graph?(y/n) [y]"

# define ECsP_WishToSvOutput "Do you wish to save the output?(y/n) [y]"

# define ECsP_processing   "Processing"
    /* Tell user program is now processing his command */
 
# define ECsP_Input_pt_on_elt        "Input point on element"
    /* Prompt user to input a point on an element */

# define ECsP_InputBsPt    "Input base point"
    /* Prompt user to input a base point for a cylinder */

# define ECsP_InputHtPt    "Input height point"
    /* Prompt user to input a height point for a cylinder */

# define ECsP_EnterRad     "Enter radius"
    /* Prompt user to keyin or input radius of cylinder */

# define ECsP_InputPt1   "Input point 1 of axis"
# define ECsP_InputVertex "Input vertex point"
# define ECsP_InputAxisPt "Input point defining axis"
# define ECsP_InputPt2   "Input point 2 of axis"

# define ECsP_InputCentPt  "Input center point"

# define ECsP_InputPrjpt1  "Input point 1 of prj vector"

# define ECsP_InputPrjpt2  "Input point 2 of prj vector"

/****************************************************************
                        STATUS STRINGS
****************************************************************/

/**added by DLB 12/2/86**/
# define ECsS_SolidCylNotConstr "Solid cylinder not constructed"
# define ECsS_SolidTorusNotConstr "Solid torus not constructed"
/***********************/


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

# define ECsS_Max_rad_error  "Maximum radius must be greater than 0"
    /* Announce max radius is invalid */

# define ECsS_MaxOrd  "New order cannot be greater than 12"

# define ECsS_MinOrd  "New order must be greater than 2"

# define ECsS_Point_not_unique "Point not unique from previous one"

# define ECsS_ZeroAxis   "Zero length axis"
    /* Zero length axis for a cylinder */

# define ECsS_NoDefaultRad   "No default radius is supplied"

# define ECsS_NoDefaultDir  "No default direction is supplied"

# define ECsS_NoDefaultVal  "No default value is supplied"

# define ECsS_RadTooSmall  "Cylinder radius is too small"

# define ECsS_CentOnAxis  "Center was on axis"

# define ECsS_InvalidRad  "Invalid radius"

# define ECsS_TorusSecCrossAxis  "Torus section crosses axis"

# define ECsS_ZeroPrjVec  "Zero length projection vector"

# define ECsS_SurfNotConstr "Surface not constructed"

# define ECsS_CylNotConstr  "Cylinder not constructed"

# define ECsS_TorusNotConstr  "Torus not constructed"

# define ECsS_Min2lines  "Mininum of 2 lines"

# define ECsS_Min0lines  "Mininum of 0 lines"

# define ECsS_Max256lines  "Maximum of 256 lines"

# define ECsS_OnlyFreeForm "Only free form elements are allowed"

# define ECsS_DsplRef "Display request refused"

# define ECsS_OnlySurf "Only surfaces are allowed"

# define ECsS_EleUnaltered  "Failure: Element unaltered"

# define ECsS_OrdInc  "Order increased"

# define ECsS_OrdChg  "Order changed"
 
# define ECsS_KnotIns  "Knot inserted"

# define ECsS_IncorMode "Incorrect mode"

# define ECsS_MinMult  "Minimum multiplicity of 1"

# define ECsS_LnEleNotSup  "Linear element not supported"

# define ECsS_LnrEleEx  "Linear element exists"

# define ECsS_MinLines  "Minimum of 1 line"

/****************************************************************
                        COMMAND STRINGS
****************************************************************/


/*added by DLB 12/2/86*/
# define ECsM_Place_solid_cylinder "Place solid right circ. cylinder"
# define ECsM_Place_solid_torus    "Place solid torus"
/**********************/



# define ECsM_MeasureRadCrvtrCrv  "Measure radius of curvature of curve"
# define ECsM_MeasureRadCrvtrSrf "Measure radius of curvature of surface"
# define ECsM_PlaceCylinder  "Place cylinder by axis and radius"
# define ECsM_PlaceTorus  "Place torus"
# define ECsM_PlacePrjSurf  "Place surface of projection"
# define ECsM_ChgRlLnDpl  "Change rule line display"
# define ECsM_InsertKnot  "Insert knot"
# define ECsM_InsertKnotln "Insert knotline"
# define ECsM_ChgOrdCrv  "Change order of a curve"
# define ECsM_ChgOrdSrf  "Change order of a surface"
# define ECsM_IncOrdCrv  "Increase order of a curve"
# define ECsM_IncOrdSrf  "Increase order of a surface"
# define ECsM_Align2Crv  "Align 2 curves"
# define ECsM_Align2Srf  "Align 2 surfaces"
# define ECsM_TogglePoly "Toggle polygon on/off"
# define ECsM_TogglePat  "Toggle pattern on/off"
# define ECsM_ToggleSpd  "Toggle display speed"

/****************************************************************
                         ERROR STRINGS
****************************************************************/

# define ECsE_GRsvempty  "GRsv.GRsvempty error"

# define ECsE_bsextractpar  "BSEXTRACTPAR error"

# define ECsE_CObrln  "CObrln error"

# define ECsE_lnproj_by_svpass  "GRlnproject by GRsvpass"

# define ECsE_GRsvpass  "GRsv.GRsvpass error"

# define ECsE_GRlnproject  "GRlnproject error"

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

# define ECsE_convert_name_to_number \
    "OM_convert_channame_to_number error"

# define ECsE_OMconstructByName \
    "OM_construct_object_by_name error"

# define ECsE_ECsavedraw   "ECsavedraw.wakeup error"

# define ECsE_delete  "Root.delete error"

# define ECsE_getattr_by_svpass  "GRgetattr by GRsvpass error"

# define ECsE_GRgetattr  "GRgetattr error"

# define ECsE_putattr_by_svpass  "GRputattr by GRsvpass error"

# define ECsE_GRputattr  "GRputattr error"

# define ECsE_EXputq_front "EXputq_front error"

# define ECsE_send_chan "OM_send_channel error"

# define ECsE_GRsvopass "GRsvopass error"

# define ECsE_GRsvoinqnum  "GRsvoinqnum error"

# define ECsE_GRcpxdisconn "GRcpxdisconn error"

/****************************************************************
                           SUBSTRINGS
****************************************************************/

# define ECss_max_rad_ln "max rad length = "
    /* Used to construct a status message telling the 
       maximum radius length */

# define ECss_max_order  "Maximum allowable:  %d"
    /* Used to tell user the maximum order allowed */

# define ECss_mult_exc_lim "Multiplicity exceeds limit:  %d"

# define ECss_ord_exc_poles "New order exceeds number of poles: %d"

# define ECss_must_exc_oldord "Must exceed old order: %d"
