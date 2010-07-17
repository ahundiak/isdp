/* define needed for the PID */

#ifndef vr_piddef_include
#define vr_piddef_include


/* Add a new representation to the VDS representation */
#define VR_N_PID_REP	"Pid"	/* name to be printed in the
				   vds rep form */
#define VR_V_PID_REP	0x6	/* internal value */


/* Macros to test whether we are in Pid mode */
#define bVR_IS_PID_ACTIVE	bVRTestPidAct()

#define bVR_IS_PID(rep)	( ((rep)&AC_VDS_REP) == VR_V_PID_REP )

/* Macro libraries names */
#define VRPID_N_METRIC_LIB	"PidMetLib"
#define VRPID_N_IMPERIAL_LIB	"PidImpLib"

/* default components' macro names */
#define VRPID_N_BRIDGE_MACRO	"_brdg"	/* Half circle cross */
#define VRPID_N_SPACE_MACRO	"_spc"	/* Partial delete cross */

#define VRPID_N_NOZZ_MACRO	"pidnozz"

#define VRPID_N_DANG_MACRO	"piddang"
#define VRPID_N_PIPE_MACRO	"pidpip"
#define VRPID_N_DUCT_MACRO	"pidduct"
#define VRPID_N_REDUCER_MACRO	"pidred"
#define VRPID_N_ELBOW_MACRO	"pidcod"
#define VRPID_N_BRANCH_MACRO	"pidbrn"
#define VRPID_N_CROSS_MACRO	"pidcross"


#endif
