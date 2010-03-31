/****************************************************************
                        PROMPT STRINGS
****************************************************************/
# define ECsP_Identify_surface "Identify surface"
# define ECsP_Input_extract_pt  "Input extract point"
    /* prompts user to input extract point for ext. para curves */
# define ECsP_Input_dir_pt  "Input direction point"
    /* prompts for direction point*/
# define ECsP_Enter_number_to_ext "Enter number to extract"
    /* prompts for number of curves to extract from sf.*/
# define ECsP_Input_range  "Input range point"
    /* prompts for range point to extract from*/

# define ECsP_NULL ""
    /* defines a nul string */
# define ECsP_Element_not_found "Element not found"
    /* Notes that locate was not succesful */

# define ECsP_Identify_curve0 "Identify the first curve"
    /* Prompts the user to  ident the first curve*/

# define ECsP_Identify_curve1 "Identify the second curve"
   /* Prompt the user to ident the second curve */

# define ECsP_Enter_top_radius   "Enter top radius"
    /* Prompt user to key in or give data pt. for radius */

# define ECsP_Enter_bottom_radius "Enter bottom radius"
    /* Prompts user to key in or give data pt. for radius */

# define ECsP_Input_base_point  "Input base point"
    /* Prompts user to input data pt. at base */

# define ECsP_Input_height_point "Input height point"
    /* Prompts user to input data pt. at height*/

# define ECsP_Identify_elt       "Identify element"
    /* Prompt user to identify an element */

# define ECsP_Input_point_1_of_base "Input point 1 of base"
    /* Prompt user to enter 1st point of plane*/

# define ECsP_Input_point_2_of_base "Input point 2 of base"
    /* Prompt user to enter 2nd point of plane*/

# define ECsP_Approve_reject_elt "Approve/reject element"
    /* Prompt user to approve or reject an element */

# define ECsP_Approve_loc_next_reject_elt \
       "Approve (Locate next element) / reject"
    /* Prompt to Acc with next locate or reject */

# define ECsP_Approve_loc_next_move_on_reject \
     "Approve(Locate next)(Move on)/reject"
  /* Prompt to accept with next locate or with move on or reject */

# define ECsP_Approve_reject_ptSet "Approve/reject set of points"
    /* Prompt user to approve or reject a set of points */

# define ECsP_Enter_parameter_value  "Enter parameter value"
    /* Prompt user to give parameter value for element */

# define ECsP_Enter_u_parameter      "Enter u parameter"
    /* Prompt user to give u-parameter value for element */

# define ECsP_Enter_v_parameter      "Enter v parameter"
    /* Prompt user to give v-parameter value for element */

# define ECsP_Input_pt_on_elt        "Input point on element"
    /* Prompt user to input a point on an element */

# define ECsP_Input_pt               "Input point"
    /* Prompt user to input a point */

# define ECsP_Delete_parent "Delete parent curves? y/n [n]"
    /* Prompts to delete parent curves. Default is no.*/

/****************************************************************
                        STATUS STRINGS
****************************************************************/

# define ECsS_Internal_error_but_continuing \
    "Internal error, continuing"
    /* Announce some kind of internal error, continuing
        command */

# define ECsS_Internal_error_and_terminating \
    "Internal error, terminating"
    /* Announce some kind of internal error, terminating
        command */

# define ECsS_Invalid_input          "Invalid input"
    /* Announce data point was invalid */

# define ECsS_Must_be_unique_points  "Must be unique points"
    /* Announce that entered points are the same*/

# define ECsS_Points_are_collinear   "Points are collinear"
    /* Announce that the inputted points are collinear*/

# define ECsS_Invalid_class_of_elt   "Element not of a valid class"
    /* Announce element is not a member of a valid class for
        a given operation */

# define ECsS_Point_not_unique_in_set "Point not unique in set"
    /* Announce that point is not unique in set */

# define ECsS_Zero_length_axis   "Zero length axis"
    /* Announce that the input points that make up an axis
       are not far enough apart */

# define ECsS_No_default_supplied "No default is supplied"
    /* Announce that user asked for the default param. when none
        existed   */

# define ECsS_Cone_radius_too_small "Cone radius is too small"
    /* Announce that the entered cone radius is too small */

# define ECsS_Could_not_make_object "Couldn't make object due to errors"
    /* Announce that the object to be place could not be construct due
       to internal or user input errors   */

/****************************************************************
                        COMMAND STRINGS
****************************************************************/

# define ECsM_Ptdist          "Distance from point to element"
# define ECsM_DistanceEqualLF "Distance = %lf"
# define ECsM_Place_rectangular_plane "Place rectangular plane"
# define ECsM_Place_parallelogram_plane "Place parallelogram plane"
# define ECsM_Place_cone  "Place right truncated cone by axis and radii"
# define ECsM_Place_ruled_surface "Place ruled surface"
# define ECsM_Merge_curves  "Merge curves"
# define ECsM_Make_merged_cv "Make merged curve"
# define ECsM_Merge_surfaces "Merge surfaces"
# define ECsM_Make_merged_sf "Make merged surface"
# define ECsM_Extract_cv     "Ext. isoparametric curve(s) of surface"

/****************************************************************
                         ERROR STRINGS
****************************************************************/

/****************************************************************
                           SUBSTRINGS
****************************************************************/

/****************************************************************
                        PROMPT STRINGS
****************************************************************/

# define ECsP_Identify_elt       "Identify element"
    /* Prompt user to identify an element */

# define ECsP_Identify_cv        "Identify curve"
    /* Prompt user to identify a curve */

# define ECsP_Identify_sf        "Identify surface"
    /* Prompt user to identify a surface */

# define ECsP_Approve_reject_elt "Approve/reject element"
    /* Prompt user to approve or reject an element */

# define ECsP_Approve_reject_ptSet "Approve/reject set of points"
    /* Prompt user to approve or reject a set of points */

# define ECsP_ApproveWithPointParameter "Approve with point or parameter value"

# define ECsP_ApproveWithBeginPointParameter "Approve with begin point or parameter value"

# define ECsP_ApproveWithNextElement "Approve with next element"

# define ECsP_ApproveWithNextElementOrMoveOn \
                        "Approve with next element or move on"

# define ECsP_ApproveWithVecPoint "Approve with point for vector"
# define ECsP_InputVecPoint "Input point for vector"

# define ECsP_IPointToProject "Input point to project"

# define ECsP_IPointKParameter "Input point or key in parameter"
# define ECsP_EnterPointParameter ECsP_IPointKParameter

# define ECsP_IBeginPointKParameter \
                                   "Input begin point or key in parameter"
# define ECsP_EnterBeginPointParameter ECsP_IBeginPointKParameter

# define ECsP_IEndPointKParameter "Input end point or key in parameter"
# define ECsP_EnterEndPointParameter ECsP_IEndPointKParameter

# define ECsP_KParameterValue  "Key in parameter value"
# define ECsP_Enter_parameter_value ECsP_KParameterValue
    /* Prompt user to give parameter value for element */

# define ECsP_KuParameter      "Key in u parameter"
# define ECsP_Enter_u_parameter      ECsP_KuParameter
    /* Prompt user to give u-parameter value for element */

# define ECsP_KvParameter      "Key in v parameter"
# define ECsP_Enter_v_parameter      ECsP_KvParameter
    /* Prompt user to give v-parameter value for element */

# define ECsP_Input_pt_on_elt        "Input point on element"
    /* Prompt user to input a point on an element */

# define ECsP_Input_1_pt_on_cnc    "Input first point on conic"
# define ECsP_Input_2_pt_on_cnc    "Input second point on conic"
# define ECsP_Input_3_pt_on_cnc    "Input third point on conic"
# define ECsP_Input_4_pt_on_cnc    "Input fourth point on conic"
# define ECsP_Input_L_pt_on_cnc    "Input last point on conic"

# define ECsP_Input_1_tn_to_cnc \
    "Input tangent to first point on conic"
# define ECsP_Input_L_tn_to_cnc \
    "Input tangent to last point on conic"

# define ECsP_Key_in_rho_or_MOVE_ON "Move on/key in rho value"

/****************************************************************
                        STATUS STRINGS
****************************************************************/

# define ECsS_RhoOutOfBounds "Rho value must be 'twixt 0 and 1"

# define ECsS_Internal_error \
    "Internal error"
    /* Announce some kind of internal error */

# define ECsS_Internal_error_but_continuing \
    "Internal error, continuing"
    /* Announce some kind of internal error, continuing
        command */

# define ECsS_Internal_error_and_terminating \
    "Internal error, terminating"
    /* Announce some kind of internal error, terminating
        command */

# define ECsS_Invalid_input          "Invalid input"
    /* Announce data point was invalid */

# define ECsS_Invalid_class_of_elt   "Element not of a valid class"
    /* Announce element is not a member of a valid class for
        a given operation */

# define ECsS_Point_not_unique_in_set "Point not unique in set"

# define ECsS_Processing "Processing"

/****************************************************************
                        COMMAND STRINGS
****************************************************************/

# define ECsM_Conic32  "Conic by 3 points and 2 tangents"
# define ECsM_Conic41  "Conic by 4 points and 1 tangent"
# define ECsM_Conic50  "Conic by 5 points"
# define ECsM_RhoConic  "Rho conic"
# define ECsM_ParameterAtPoint "Parameter(s) at point"
# define ECsM_PointAtParameter "Point at parameter(s)"
# define ECsM_ImposeCurveBoundary "Impose curve boundary"
# define ECsM_CurveSelfIntersection "Curve self intersection"
# define ECsM_ProjectPointAlongVectorOntoSf \
                "Project point along vector onto surface"

/****************************************************************
                         ERROR STRINGS
****************************************************************/


# define ECsE_ECconic32_impossible_action \
    "ECconic32 internal bad action -- abort"
# define ECsE_ECconic41_impossible_action \
    "ECconic41 internal bad action -- abort"
# define ECsE_ECconic50_impossible_action \
    "ECconic50 internal bad action -- abort"

/****************************************************************
                           SUBSTRINGS
****************************************************************/

# define ECss_parameters_found "%d parameters found"
    /* Used to construct a message indicating how many
        parameters were found */
