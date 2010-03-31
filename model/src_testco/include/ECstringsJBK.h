# ifndef ECstringsJBK_include
# define ECstringsJBK_include

/****************************************************************
                        PROMPT STRINGS
****************************************************************/

# define ECsP_ShouldNotSee       "Should not see this prompt"

# define ECsP_Identify_elt       "Identify element"
    /* Prompt user to identify an element */

# define ECsP_Identify_cv        "Identify curve"
# define ECsP_Identify_cvMO      "Identify curve/move on"
# define ECsP_Identify1cv        "Identify the first curve"
# define ECsP_Identify2cv        "Identify the second curve"
    /* Prompt user to identify a curve */

# define ECsP_Identify_sf        "Identify surface"
# define ECsP_Identify1sf        "Identify the first surface"
# define ECsP_Identify2sf        "Identify the second surface"
    /* Prompt user to identify a surface */

# define ECsP_Approve_reject "Accept/reject"
# define ECsP_Approve_reject_elt "Accept/reject element"
# define ECsP_Approve_reject_cv "Accept/reject curve"
# define ECsP_Approve_reject_cvMO "Accept/reject curve/move on"
# define ECsP_Approve_reject_sf "Accept/reject surface"
    /* Prompt user to approve or reject an element */

# define ECsP_Approve_reject_ptSet "Accept/reject set of points"
    /* Prompt user to approve or reject a set of points */

# define ECsP_ApproveWithPointParameter "Accept with point or parameter value"

# define ECsP_ApproveWithBeginPointParameter "Accept with begin point or parameter value"

# define ECsP_ApproveWithNextElement "Accept with next element"

# define ECsP_ApproveWithNextElementOrMoveOn \
                        "Accept with next element or move on"

# define ECsP_ApproveWithVecPoint "Accept with point for vector/reject"
# define ECsP_ApproveWithAnotherCurve "Accept with next curve/move on/reject"

# define ECsP_ApproveWithAppxTangencyPoint \
                            "Accept with tangency point/reject"

# define ECsP_ApproveWithBlendBoundary \
                        "Accept with point on boundary/reject"
# define ECsP_IBlendBoundary "Input point on boundary"
# define ECsP_IBlendDirectionPoint "Input blend direction point"

# define ECsP_I1AppxTangencyPoint \
                            "Input first approximate tangency point"
# define ECsP_I2AppxTangencyPoint \
                            "Input second approximate tangency point"
# define ECsP_I1AppxTangencyPointMO \
                            "Input first tangency point/move on"
# define ECsP_I2AppxTangencyPointMO \
                            "Input second tangency point/move on"

# define ECsP_IpointMoveOn "Input point/move on"

# define ECsP_Input1VecPoint "Input first point for vector"

# define ECsP_Input2VecPoint "Input second point for vector"

# define ECsP_IPointToProjectMO "Input point to project"

# define ECsP_IBeginPointKParameter \
                                   "Input begin point or key in parameter"

# define ECsP_IEndPointKParameter "Input end point or key in parameter"

# define ECsP_IPointKParameter  "Input a point or key in parameter"
# define ECsP_IPointKParameters "Input a point or key in parameters"
# define ECsP_IPointKuParameter "Input a point or key in u-parameter"

# define ECsP_KParameterValue  "Key in parameter value"
    /* Prompt user to give parameter value for element */

# define ECsP_KuParameter      "Key in u-parameter"
    /* Prompt user to give u-parameter value for element */

# define ECsP_KvParameter      "Key in v-parameter"
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

# define ECsP_RestartingCommand "Restarting command"

# define ECsP_IDataPointToDebug "Input data point to debug"

/****************************************************************
                        STATUS STRINGS
****************************************************************/

# define ECsS_EltNotFound "Element not found"
# define ECsS_CvNotFound "Curve not found"
# define ECsS_SfNotFound "Surface not found"

# define ECsS_RhoOutOfBounds "Rho value must lie between 0 and 1"

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

# define ECsS_InternalErrorNoStackMemory "No stack memory available"

# define ECsS_Invalid_input          "Invalid input"
    /* Announce data point was invalid */

# define ECsS_InvalidTypeOfCommand "Invalid me->mytype"

# define ECsS_Invalid_class_of_elt   "Element not of a valid class"
    /* Announce element is not a member of a valid class for
        a given operation */

# define ECsS_Point_not_unique_in_set "Point not unique in set"

# define ECsS_VectorNoMag "Vector has zero magnitude"

# define ECsS_Processing "Processing"

# define ECsS_CurveNotProj "Curve not projected"
# define ECsS_PointNotProj "Point not projected"

# define ECsS_CurveNotMade "Curve not constructed"
# define ECsS_BlendNotMade "Blend not constructed"
# define ECsS_ParabNotMade "Parabola not constructed"
# define ECsS_ConicNotMade "Conic not constructed"
# define ECsS_NoSolution "No solution"

/****************************************************************
                        COMMAND STRINGS
****************************************************************/

# define ECsM_DebugO "Debug out EMS"
# define ECsM_DebugI "Debug in EMS"

# define ECsM_Conic32  "Conic by 3 points and 2 tangents"
# define ECsM_Conic41  "Conic by 4 points and 1 tangent"
# define ECsM_Conic50  "Conic by 5 points"
# define ECsM_RhoConic  "Rho conic"

# define ECsM_CvPointParameter \
             "Display curve parameter/point"
# define ECsM_SfPointParameters \
            "Display surface parameters/point"

# define ECsM_ParameterAtPoint "Display parameterization of a point"
# define ECsM_PointAtParameter "Display point for parameter value(s)"
# define ECsM_ImposeCurveBoundary "Impose curve boundary"
# define ECsM_CurveSelfIntersection "Curve self intersection"
# define ECsM_ProjectPointAlongVectorOntoSf \
                "Project point along vector onto surface"
# define ECsM_ProjectCurveAlongVectorOntoSf \
                "Project curve along vector onto surface"
# define ECsM_ParabolaTangent2cvsApproxPoints \
                "Parabola tangent to 2 curves"
# define ECsM_Blend2surfacesNaturalBoundaries \
                "Blend 2 surfaces at natural boundaries"

/****************************************************************
                         ERROR STRINGS
****************************************************************/


# define ECsE_VectorNoMag ECsS_VectorNoMag

# define ECsE_ResultTruncated "Result truncated"

# define ECsE_OnlyLocateOne "Only locate one"

# define ECsE_ImpossibleAction "Internal error, bad action"
# define ECsE_ImpossibleTransition "Internal error, bad transition"
# define ECsE_ImpossibleSwitch \
    "Internal error, bad switch condition"

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
# define ECss_InputTolOrApprove \
    "Key in tolerance [%lg]"
# define ECss_Approve_reject_cvTolMO \
    "Accept by point, tol[%lg], move on"

# endif /* ECstringsJBK_include */
