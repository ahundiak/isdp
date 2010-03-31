/* contains definitions for curve/linestring editor */

#define dflT2 0

#define RANGE_DIV 		0.3 /* for vector drawing in window */
#define  EPS 1e-4
#define PI 3.141592654
#define EPS1 1e-3
#define EPS2 1e-6
#define MIN_CV_ORDER 3
#define MAX_CV_ORDER 16
#define MIN_POLES 3


/* defaults for var array length */
#define DFT_VX 50
#define DFT_PT DFT_VX * 3
#define DFT_ET 20
#define DFT_EMP 10


#define COLOR_FIELD  11
#define WEIGHT_FIELD 12

#define MARKER "ZXCDSAWQE\0"
#define RECOMP_FUNC_NAM "LSas_crv\0"
#define FUNC_NAM_LEN 8
#define OFFSET_INFO 16

#define CURVE_EXISTS 0

#define ON 1
#define OFF 0
#define SMOOTH_FACTOR 1.0

#define X 0
#define Y 1
#define Z 2
#define X2 3
#define Y2 4
#define Z2 5
#define X3 6
#define Y3 7
#define Z3 8




/* execute process actions */
#define PROCESS_DRAW_CURVE       'a'
#define PROCESS_DELETE_VERTEX    'b'
#define PROCESS_EDIT_VERTEX      'h'
#define PROCESS_SET_TANGENT      'c'
#define PROCESS_INSERT_VERTEX    'd'
#define PROCESS_SET_FIXPOINT     'f'
#define PROCESS_STOP_EDITING     'j'
#define PROCESS_STOP_COMMAND     'k'
#define PROCESS_TOGGLE_FIXPT     'l'
#define PROCESS_SHOW_FIXPT       'm'
#define PROCESS_SHOW_TA          'n'
#define PROCESS_CURVATURE        'o'
#define PROCESS_LOCATE_ABORT     'p'
#define PROCESS_RJT_MOVEON       'q'
#define PROCESS_MOVE_KNOT        'r'
#define PROCESS_DUPL_KNOT        's'
#define PROCESS_DEL_KNOT         't'
#define PROCESS_INS_KNOT         'u'
#define PROCESS_SEL_REF_CURVE_KNOTS    'v'
#define PROCESS_SEL_REF_CURVE_PARAS    'w'
#define PROCESS_MOVE_VERTEX            'x'
#define PROCESS_NEXT_LS          'y'
#define PROCESS_SELECT           'z'



/* option Form position */
#define opt_WLOX                    750
#define opt_WLOY                    125

/* main Form position */
#define main_WLOX                   50
#define main_WLOY                   125

/* table Form position */
#define edt_WLOX                    50
#define edt_WLOY                    110


/* Forms form and gadget processing */
#define MAINFORM 		1
#define OPTFORM                 2
#define EDTFORM                 3


/* common buttons */ 
#define ACCEPT_B 		1
#define REJECT_B           4


/* main form gadgets */
#define M_MSG_F                   9   /* message field */
#define M_ORDER_F                 12  /* curve order field */
#define M_SPANS_F                 13  /* curve no of spans field */
#define M_POLES_F                 14  /* curve no of poles field */
#define M_SMOOTH_F                15  /* curve smoothing field */
#define M_ITERA_F                 33  /* iterative impr. field */
#define M_APTOL_F                 34  /* approx. tol. field */
#define M_PARA_F                  16  /* curve parameter field */
#define M_KNOT_F                  17  /* curve knot field */
#define M_EDLS_B                  24  /* edit linestring button */
#define M_NEXTLS_B                25  /* process next linestring button */
#define M_DRCV_B                  35  /* draw curve button */
#define M_SHOW_T                  31  /* show text */
#define M_SHCU_B                  28  /* show curvature button */
#define M_SGDI_B                  26  /* show distance button */
#define M_SHPO_B                  36  /* show poles button */
#define M_SHKN_B                  27  /* show knots button */
#define M_LSVISIBLE_B             32  /* linestring visible toggle */
#define M_POWER_F                 39  /* power field */
#define M_PARA_T                  22  /* parameter text gadget */
#define M_KNOT_T                  23  /* parameter text gadget */
#define M_FREE_T                  41  /* free vertex no text gadget */
#define M_BORDER_L                37  /* border line */
#define M_PDIST_B                 44  /* distance parameter options */
#define M_PCURV_B                 45  /* curvature parameter options */
#define M_PPOLE_B                 46  /* poles parameter options */
#define M_PKNOT_B                 47  /* knots parameter options */
#define M_FREE_F                  42  /* free field */
#define M_FREE_MCF                40  /* free multi col field */
#define M_AFREE_B                 49  /* free end button */
#define M_RFREE_B                 53  /* free end button */
#define M_KKNOT_T                 48  /* comment */ 
#define M_KMOV_B                  43  /* move knot */
#define M_KINS_B                  52  /* insert knot */
#define M_KDUP_B                  50  /* duplicate knot */
#define M_KDEL_B                  51  /* delete knot */
#define M_KACC_B                  54  /* accept knot subform */
#define M_ANLS_B                  56  /* analyze linestring */
#define MSG_F_L  65 /* length of a message field */

/* edtform gadgets  */
#define E_ACC_B                   1   /* accept button */
#define E_MSG_F                   9   /* message field */     
#define E_VERTEX_F                11  /* select vertex field */
#define E_MCOL_F                  12  /* multi row column edit field */
#define E_JUMPF_B                 19  /* jump to first vertex button */
#define E_JUMPL_B                 21  /* jump to last vertex button */
#define E_JUMP_F                  33  /* jump to vertex no field */
#define E_EDT_B                   30  /* move/edit vertex button */
#define E_INS_B                   13  /* insert vertex button */
#define E_MOV_B                   32  /* move vertex button */
#define E_DEL_B                   14  /* delete vertex button */
#define E_UNDO_B                  20  /* undo last edit button */
#define E_AFIX_B                  17  /* set/delete all fixpoints */
#define E_TA1_B                   22  /* set/delete tangent constraint */
#define E_CURV_B                  18  /* curvature button */
#define E_DRCV_B                  39  /* Draw Curve */ 
#define E_SHFIX_B                 31  /* show all fix points */
#define E_SHTA_B                  36  /* show all tangents */
#define E_SIFIX_B                 41  /* toggle single fix button */
#define E_SHCURVA_B               40  /* show curvature button */
#define E_LSVISIBLE_B             42  /* linestring visible toggle */


/* undo types */
#define UNDO_TYPE_DELETE 0
#define UNDO_TYPE_INSERT 1
#define UNDO_TYPE_MODIFY 2
#define UNDO_COMPLETED   4

/* command execute states */
#define GET_LINESTRING       	  1
#define GET_CURVE                 2
#define PROCESS         	  3
#define GET_TANGENT_OR_CURVATURE  4
#define GET_USTART                5
#define GET_UEND                  6
#define GET_UPAR                  7
#define GET_ACCPT                 8
#define GET_INSERT_POINT          9
#define GET_MOVE_POINT            10
#define GET_KMOVE_POINT           11
#define GET_REF_CURVE             12
#define CREATE_LINESTRING         13
#define FINISH                    99


/* form messages */
#define ASSOC_OFF "Curve not created; switch associativity on"
#define WRONG_ELEMENT "Wrong element identified"
#define WRONG_ORDER "Order and/or no of poles of reference curve incorrect"
#define IDENT_REF_CURVE "Identify reference curve"
#define KNOT_DUPLICATES_LIMIT "duplicates limit exceeded; knot not created"
#define KNOT_NOT_TOSELECT "not allowed to select first or last knot"
#define SELECT_POINT_TOINS "Select point to insert knot"
#define SELECT_KNOT_TODEL "Select knot to delete"
#define SELECT_KNOT_TODUP "Select knot to duplicate"
#define SELECT_KNOT_TOMOV "Select knot to move"
#define NO_CURVE_EXISTS "No curve exists"
#define CURV_NOT_CREAT "Curve not created"
#define SEL_IN_TABL "You selected to insert in table"
#define LOCATE_RJT_MOVEON "Hit Reject/Moveon button to abort locate"
#define CLEAR_MSG "                                                     " 
#define INCORRECT_VERTEX "Incorrect vertex selected"
#define RADIUS_PICKED "Radius picked"
#define GIVE_RADIUS "Keyin Radius or select point on curve (curvature)"
#define SEL_FIRST_OR_LAST "Select first or last vertex in table or LS"
#define SEL_TANG_OR_LINE "Select point on a curve or line"
#define SEL_ROW_OR_SEG  "Select row in table or segment on linestring"
#define SEL_ROW_OR_PT  "Select row in table or vertex on linestring"
#define SEL_ROW "Select vertex in table or in linestring"
#define SEL_LS "Select vertex in linestring"
#define DELVXQ     "Are you shure you want to delete? select again" 
#define WRONGROW   "You worked on a wrong row"
#define ROW_DELETED "Vertex deleted"
#define DEL_NOT_ROW_0 "Vertex 0 cannot be deleted"
#define DEL_NOT_1_LINE "Only one line exists; you cannot delete more"
#define TANGENT_PICKED "Tangent picked"
#define CURVATURE_PICKED "Curvature picked"
#define TANGENT_REMOVED "Tangent removed"
#define CURVATURE_REMOVED "Curvature removed"
#define VDEL_UNDONE "Vertex delete undone"
#define VMOD_UNDONE "Vertex modification  undone"
#define CURV_CREAT "Curve created"
#define CURV_MODIF "Curve modified"
#define SMOOTH "smoothing factor,"
#define POLES_SPANS "No of poles, no of spans "
#define CHANGED " changed"
#define COMMA ", "
#define UNKNOWN_PAR_TYP "Unknown curve parameter type"
#define UNKNOWN_KNOT_TYP "Unknown curve knot type"
#define ENTER_POWER "Enter power value"
#define PAR_VEC_ABORT "Parameter vector inconsistent; curve not created"
#define KNOT_VEC_ABORT "Knot vector inconsistent; curve not created"
#define MAX_GLOBAL_DIST "Max global distance = "

/* types of curve parameters and knots */
#define EQUIDISTANT 1
#define CENTRIPEDAL 2
#define CHORDAL 3
#define POWER 4
#define PROJECT 5
#define REF_CURVE 6
#define AFFIN_INV 7
#define FREE 8
#define UNIFORM 9
#define HUBS 10
#define NOT_A_KNOT 11
#define INTERACTIVE 12
#define NODE 13
#define EQUIDISTANT_T "EQUIDISTANT"
#define CENTRIPEDAL_T "CENTRIPEDAL"
#define CHORDAL_T "CHORDAL"
#define POWER_T "POWER"
#define PROJECT_T "PROJECT"
#define REF_CURVE_T "REF CURVE"
#define AFFIN_INV_T "AFFIN INV"
#define FREE_T "FREE"
#define INTERACTIVE_T "INTERACTIVE"
#define UNIFORM_T "UNIFORM"
#define HUBS_T "AVERAGE"
#define NOT_A_KNOT_T "NOT A KNOT"
#define NODE_T "NODE"
           
#define NVIS_ROWS 3 /* no of visible rows in multi col field edt.form */

#define VNC  0 /* vertex no in col 0 */
#define XC   0 /* vertex x pos in col 1 */
#define YC   1 /* vertex y pos in col 2 */
#define ZC   2 /* vertex z pos in col 3 */
#define FXC  3 /* fix pt mark in col 4 */
#define FAC  4 /* factor in col 5 */
#define TAC  5 /* tangent mark in col 6 */
#define TAX  6 /* tangent vector x */
#define TAY  7 /* tangent vector y */
#define TAZ  8 /* tangent vector z */

#define NUM_TA 2 /* number of characters in tangent marker column */


/* main form parameters */
struct mainform_par {
  IGRint order;
  IGRint nspans;
  IGRint npole;
  IGRdouble smfac;
  IGRdouble  cv_vector[6]; /* curvature at start and end point */
  IGRshort   opt_curv0; /* curvature in start point */
  IGRshort   opt_curv1; /* curvature in end point */
  IGRshort   opt_iter; /* no of iterations */
  IGRdouble  rad0; /* radius start point */
  IGRdouble  rad1; /* radius end point */
  IGRdouble  power; /* power */
  IGRchar para_type[12];
  IGRchar knot_type[12];
};

/* the vertex_tbl struct holds relevant information per vertex */
struct vertex_tbl {
  IGRint    nvno;
  IGRdouble xp;
  IGRdouble yp;
  IGRdouble zp;
  IGRchar   fxp[4];
  IGRdouble fac;
  IGRpoint  tav;
  IGRchar   edt_flag;
  IGRchar   ta[3];
};

/* knot vector interactive edit table */
struct eknot_tbl {
  IGRdouble knot;
  IGRshort  dup;
};

  
/* the ta_tbl struct holds tangent information */
struct ta_tbl {
  IGRint nvno;
  IGRvector tav;
};


/* the fxp_tbl struct holds fix point information */
struct fxp_tbl {
  IGRint  nvno;
};

/* the fac_tbl struct holds factor information */
struct fac_tbl {
  IGRint nvno;
  IGRdouble fac;
};


struct v_info {
  IGRchar    marker[12]; /* marks the info block that it was created by the
                            curve/linestring editor command */
  IGRshort   pdim; /*  dimension of points (pdim=2,3,4) */
  IGRshort   opt_par; /* optional parameter distribution */
  IGRshort   opt_curv0; /* curvature in start point */
  IGRshort   opt_curv1; /* curvature in end point */
  IGRshort   opt_wg; /* points have factors (weights) */
  IGRshort   opt_end; /* same tangent in start and end points */
  IGRshort   order; /* curve order */
  IGRshort   opt_sm; /* smoothing factor available */
  IGRshort   opt_iter; /* number of iterations to optimize curve */
  IGRshort   dum0; /* dummy short */
  IGRshort   dum1;
  IGRshort   dum2;
  IGRint     nknot; /* no of knots in knot vector */
  IGRint     npara; /* number of parameters in parameter vector */
  IGRint     npole; /* number of poles */
  IGRint     nspans; /* no of curve spans */
  IGRdouble  power; /* power */
  IGRlong    nvx; /* no of vertices in linestring */
  IGRlong    nfp; /* no of fixpoints constraints */
  IGRlong    nta; /* no of tangent constraints */
  IGRlong    nfa; /* no of factors */
  IGRdouble  cv_vector[6]; /* curvature at start and end point */
  IGRdouble  rad0; /* radius in start point */
  IGRdouble  rad1; /* radius in end point */
  IGRdouble  smfac; /* smoothing factor */
  IGRdouble  max_err; /* maximum distance linestring vertex - curve */
  IGRdouble  rho; /* radius of curvature */
  IGRchar    para_type[12]; /* parameter type */
  IGRchar    knot_type[12]; /* knot type */
  IGRchar    char_data[1]; /* variable area for fix pts, tangents, factors, 
                              knot-vector, and parameter-vector */
};

/*	Letzte Aenderung : 23.08. 1994, uwa
*/

#define OPTF_EXSA_B  4
#define OPTF_QUIT_B  1
#define OPTF_CVRA_B 12
#define OPTF_DIST_B 15
#define OPTF_SPOL_B 13
#define OPTF_SKNT_B 14
#define CVRA_EXSA_B  4
#define CVRA_RUN__B  2
#define CVRA_REST_B  3
#define CVRA_QUIT_B  1
#define CVRA_ANZN_F 12
#define CVRA_LAYR_F 13
#define CVRA_COLO_F 14
#define CVRA_WEIT_F 15
#define CVRA_STYL_F 16
#define CVRA_USTR_F 31
#define CVRA_UEND_F 32
#define CVRA_U_P1_F 34
#define CVRA_FACT_F 38
#define CVRA_LETH_F 39
#define CVRA_CURA_T 22
#define CVRA_NOGR_T 23
#define CVRA_FASL_T 26
#define CVRA_PAR2_B 26
#define CVRA_DEFL_B 27
#define CVRA_PAR1_B 28
#define CVRA_MYSY_T 29
#define CVRA_CVIN_T 37
#define CVRA_MAXL_B 45
#define CVRA_SCAF_B 46
#define DIST_EXSA_B  4
#define DIST_RUN__B  2
#define DIST_REST_B  3
#define DIST_QUIT_B  1
#define DIST_GRAP_T 75
#define DIST_ALLN_T 24
#define DIST_LOCA_T 32
#define DIST_GLOB_T 31
#define DIST_MYSY_T 29
#define DIST_OUTP_T 58
#define DIST_WIFI_T 12
#define DIST_APNF_T 57
#define DIST_NUMB_T 54
#define DIST_LSPO_T 53
#define DIST_PRPO_T 55
#define DIST_DIST_T 59
#define DIST_LETH_F 39
#define DIST_FACT_F 38
#define DIST_PROJ_B 65
#define DIST_CONN_B 68
#define DIST_MIXE_B 70
#define DIST_MAXL_B 78
#define DIST_SCAF_B 79
#define DIST_GRLA_F 22
#define DIST_ALLA_F 13
#define DIST_LMLA_F 33
#define DIST_GMLA_F 34
#define DIST_GRCO_F 64
#define DIST_ALCO_F 14
#define DIST_LMCO_F 35
#define DIST_GMCO_F 36
#define DIST_GRWT_F 69
#define DIST_ALWT_F 15
#define DIST_LMWT_F 44
#define DIST_GMWT_F 45
#define DIST_GRST_F 74
#define DIST_ALST_F 16
#define DIST_LMST_F 46
#define DIST_GMST_F 47
#define DIST_TEXT_F 66
#define DIST_FLNA_F 27
#define DIST_INPT_B 67
#define SPOL_EXSA_B  4
#define SPOL_RUN__B  2
#define SPOL_REST_B  3
#define SPOL_QUIT_B  1
#define SPOL_LSLA_F 18
#define SPOL_PTLA_F 19
#define SPOL_LSCO_F 20
#define SPOL_PTCO_F 23
#define SPOL_LSWT_F 21
#define SPOL_PTWT_F 24
#define SPOL_LSST_F 22
#define SPOL_TOPO_T 13
#define SPOL_PNTS_T 16
#define SPOL_LSTR_T 17
#define SPOL_MYSY_T 29
#define SKNT_EXSA_B  4
#define SKNT_RUN__B  2
#define SKNT_REST_B  3
#define SKNT_QUIT_B  1
#define SKNT_LSLA_F 18
#define SKNT_PTSL_F 31
#define SKNT_PTML_F 32
#define SKNT_LSCO_F 20
#define SKNT_PTSC_F 23
#define SKNT_PTMC_F 19
#define SKNT_LSWT_F 21
#define SKNT_PTSW_F 33
#define SKNT_PTMW_F 24
#define SKNT_LSST_F 22
#define SKNT_LSTR_T 13
#define SKNT_PNTS_T 17
#define SKNT_PNTM_T 16
#define SKNT_MYSY_T 29


#define CVRAFORM    1 
#define OPTFORM     2
#define SPOLFORM    3
#define SKNTFORM    4
#define DISTFORM    5
#define CVRA_B     12
#define DIST_B     15
#define SPOL_B     13
#define SKNT_B     14
#define ON          1
#define OF          0
#define opt_WLOX    0
#define opt_WLOY   50
#define cvra_WLOX  50
#define cvra_WLOY 150
#define dist_WLOX  50
#define dist_WLOY 150 
#define spol_WLOX 150
#define spol_WLOY 150
#define sknt_WLOX 150
#define sknt_WLOY 150



/*	Curvature - Radius  -  cvra                                           */
struct cvra_frm
{
 IGRint    wlox;    /* window lower x                                         */
 IGRint    wloy;    /* window lower y                                         */
 IGRint    exsa;    /* Exit and Save Button                                   */
 IGRint    runn;    /* Run   Button                                           */
 IGRint    rest;    /* Reset   Button                                         */
 IGRint    quit;    /* Quit Button                                            */
 IGRint    cura;    /* Toggle Curvature or Radius                             */
 IGRint    nogr;    /* Toggle Normals or Graph                                */
 IGRint    fasl;    /* Toggle Normals Display  FAst SLow                      */
 IGRint    mysy;    /* Toggle My Symbology - Active Symbology                 */
 IGRint    cvin;    /* Toggle anz Normals in Interval - along Curve           */
 IGRint    par2;    /* case two Parameters to define the Interval             */
 IGRint    defl;    /* case define parameters later                           */
 IGRint    par1;    /* case one Parameter to define the Interval              */
 IGRint    scaf;    /* case Scaling All Normals are scaled with fac           */
 IGRint    maxl;    /* case Longest Normal defines fac                        */
 IGRint    anzn;    /* Number of Normals or vertices of the Graph             */
 IGRint    layr;    /* Layer for the Output if my_sym is ON                   */
 IGRint    colo;    /* Color for the Output if my_sym is ON                   */
 IGRint    weit;    /* Weightfor the Output if my_sym is ON                   */
 IGRint    styl;    /* Style for the Output if my_sym is ON                   */
 IGRdouble ustr;    /* Start- and       of the Intervall if it is defined     */
 IGRdouble uend;    /* Endparameter     in the form   -   par2 is ON          */
 IGRdouble u_st;    /* Start- and       of the Intervall if it is defined     */
 IGRdouble u_en;    /* Endparameter     later  defl is ON                     */
 IGRdouble u_p1;    /* One parameter from the form  -  par1 is ON             */
 IGRdouble u_p2;    /* One parameter defined later  -  par1 is ON             */
 IGRdouble fact;    /* Scalingfactor, if scaf is ON                           */
 IGRdouble leth;    /* Length of the longest normal, if maxl is ON            */
 IGRchar   flna;    /* default file name                                      */
 IGRchar   text;    /* default output                                         */
};
/*	Distance  -  dist                                                     */
struct dist_frm
{
 IGRint    wlox;    /* window lower x                                         */
 IGRint    wloy;    /* window lower y                                         */
 IGRint    exsa;    /* Exit and Save  Button                                  */
 IGRint    runn;    /* Run     Button                                         */
 IGRint    rest;    /* Reset   Button                                         */
 IGRint    quit;    /* Quit    Button                                         */
 IGRint    prco;    /* Toggle Project - Connect                               */
 IGRint    grap;    /* Toggle Graph Yes - No                                  */
 IGRint    alln;    /* Toggle all Normal Yes - No                             */
 IGRint    loca;    /* Toggle local max Yes - No                              */
 IGRdouble leth;    /* Length of the longest normal, if maxl is ON            */
 IGRdouble fact;    /* Scalingfactor, if scaf is ON                           */
 IGRint    glob;    /* Toggle global max Yes - No                             */
 IGRint    mysy;    /* Toggle My Symbology - Active Symbology                 */
 IGRint    outp;    /* Toggle Output Yes - No                                 */
 IGRint    wifi;    /* Toggle Output window - file                            */
 IGRint    apnf;    /* Toggle Append Output - Create new file                 */
 IGRint    numb;    /* Toggle Number of each point Yes - No                   */
 IGRint    lspo;    /* Toggle Coordinates of the Linestring Vertices Yes - No */
 IGRint    prpo;    /* Toggle Coordinates of the Projected points Yes - No    */
 IGRint    dist;    /* Toggle Distance between points Yes - No                */
 IGRint    proj;    /* case Project Endpoints                                 */
 IGRint    conn;    /* case Connect Endpoints                                 */
 IGRint    mixe;    /* case Mix between Project and Connect Endpoints         */
 IGRint    maxl;    /* case Longest Normal defines fact                       */
 IGRint    scaf;    /* case Scaling All Normals are scaled with fact          */
 IGRint    grla;    /* Layer for Graph if my_sym is ON                        */
 IGRint    alla;    /* Layer for the Output of all normals if my_sym is ON    */
 IGRint    lmla;    /* Layer for local max Normals if my_sym is ON            */
 IGRint    gmla;    /* Layer for global max Normal if my_sym is ON            */
 IGRint    grco;    /* Color for Graph if my_sym is ON                        */
 IGRint    alco;    /* Color for the Output of all normals if my_sym is ON    */
 IGRint    lmco;    /* Color for local max Normals if my_sym is ON            */
 IGRint    gmco;    /* Color for global max Normal if my_sym is ON            */
 IGRint    grwt;    /* Weightfor Graph if my_sym is ON                        */
 IGRint    alwt;    /* Weightfor the Output of all normals if my_sym is ON    */
 IGRint    lmwt;    /* Weightfor local max Normals if my_sym is ON            */
 IGRint    gmwt;    /* Weightfor global max Normal if my_sym is ON            */
 IGRint    grst;    /* Style for Graph if my_sym is ON                        */
 IGRint    alst;    /* Style for the Output of all normals if my_sym is ON    */
 IGRint    lmst;    /* Style for local max Normals if my_sym is ON            */
 IGRint    gmst;    /* Style for global max Normals if my_sym is ON           */
 IGRint    inpt;    /* Button to put text into file                           */
 IGRchar   flna[20];/* Filename for Output                                    */
 IGRchar   text[80];/* Text - Headerline                                      */
};
/*      Knotvector  -  knve                                                   */
struct knve_frm
{
 IGRint    wlox;    /* window lower x                                         */
 IGRint    wloy;    /* window lower y                                         */
 IGRint    exsa;    /* Exit and Save  Button                                  */
 IGRint    runn;    /* Run     Button                                         */
 IGRint    rest;    /* Reset   Button                                         */
 IGRint    quit;    /* Quit    Button                                         */
 IGRint    defa;    /* Toggle Knotvector default                              */
 IGRint    ubsp;    /* Toggle Knotvector uniform                              */
 IGRint    hbsp;    /* Toggle Knotvector half uniform                         */
 IGRint    rfrc;    /* Toggle Knotvector from Reference curve                 */
 IGRint    free;    /* Toggle Knotvector free - User defined                  */
};
/*	Move Pole  -  mpol                                                    */
struct mpol_frm
{
 IGRint    wlox;    /* window lower x                                         */
 IGRint    wloy;    /* window lower y                                         */
 IGRint    exsa;    /* Exit and Save  Button                                  */
 IGRint    runn;    /* Run     Button                                         */
 IGRint    rest;    /* Reset   Button                                         */
 IGRint    quit;    /* Quit    Button                                         */
 IGRint    sing;    /* case move single Pole                                  */
 IGRint    mult;    /* case move multiple Poles                               */
 IGRint    glob;    /* case move all Poles - Regard Preserve Restrictions     */
 IGRint    line;    /* case move Pole[s] free, all the same direction         */
 IGRint    norm;    /* case move Pole[s] normal to the surface                */
};
/*	Modify Shape  -  mhsp                                                 */
struct mshp_frm
{
 IGRint    wlox;    /* window lower x                                         */
 IGRint    wloy;    /* window lower y                                         */
 IGRint    exsa;    /* Exit and Save  Button                                  */
 IGRint    runn;    /* Run     Button                                         */
 IGRint    rest;    /* Reset   Button                                         */
 IGRint    quit;    /* Quit    Button                                         */
 IGRint    mini;    /* case minimal modification                              */
 IGRint    loca;    /* case local modification                                */
 IGRint    glob;    /* case global modification - Regard Preserve Restrictions*/
 IGRint    topt;    /* case only to point                                     */
 IGRint    frpt;    /* case from point -> to point                            */
};
/*      Parametervector  -  pave                                              */
struct pave_frm
{
 IGRint    wlox;    /* window lower x                                         */
 IGRint    wloy;    /* window lower y                                         */
 IGRint    exsa;    /* Exit and Save  Button                                  */
 IGRint    runn;    /* Run     Button                                         */
 IGRint    rest;    /* Reset   Button                                         */
 IGRint    quit;    /* Quit    Button                                         */
 IGRint    defa;    /* Toggle Parametervector default                         */
 IGRint    powe;    /* Toggle Parametervector power defined                   */
 IGRint    eque;    /* Toggle Parametervector equidistant                     */
 IGRint    cent;    /* Toggle Parametervector centripedal                     */
 IGRint    cord;    /* Toggle Parametervector chordal                         */
 IGRint    line;    /* Toggle Parametervector project from line               */
 IGRint    rfci;    /* Toggle Parametervector from Reference curve            */
 IGRint    free;    /* Toggle Parametervector free - User defined             */
 IGRdouble pova;    /* Power value for option power defined                   */
};
/*      Show Knots  -  sknt                                                   */
struct sknt_frm
{
 IGRint    wlox;    /* window lower x                                         */
 IGRint    wloy;    /* window lower y                                         */
 IGRint    exsa;    /* Exit and Save  Button                                  */
 IGRint    runn;    /* Run     Button                                         */
 IGRint    rest;    /* Reset   Button                                         */
 IGRint    quit;    /* Quit    Button                                         */
 IGRint    lstr;    /* Toggle Linestring connecting knots                     */
 IGRint    pnts;    /* Toggle Points in single knots                          */
 IGRint    pntm;    /* Toggle Points in multiple knots                        */
 IGRint    mysy;    /* Toggle My Symbology - Active Symbology                 */
 IGRint    lsla;    /* Layer for Linestring                                   */
 IGRint    lsco;    /* Color for Linestring                                   */
 IGRint    lswt;    /* Weightfor Linestring                                   */
 IGRint    lsst;    /* Style for Linestring                                   */
 IGRint    ptsl;    /* Layer for the Points in the single Knots               */
 IGRint    ptsc;    /* Color for the Points in the single Knots               */
 IGRint    ptsw;    /* Weightfor the Points in the single Knots               */
 IGRint    ptml;    /* Layer for the Points in the multiple Knots             */
 IGRint    ptmc;    /* Color for the Points in the multiple Knots             */
 IGRint    ptmw;    /* Weightfor the Points in the multiple Knots             */
};
/*      Show pole  -  spol                                                    */
struct spol_frm
{
 IGRint    wlox;    /* window lower x                                         */
 IGRint    wloy;    /* window lower y                                         */
 IGRint    exsa;    /* Exit and Save  Button                                  */
 IGRint    runn;    /* Run     Button                                         */
 IGRint    rest;    /* Reset   Button                                         */
 IGRint    quit;    /* Quit    Button                                         */
 IGRint    topo;    /* Toggle Polygon ON - OFF                                */
 IGRint    mysy;    /* Toggle My Symbology - Active Symbology                 */
 IGRint    lstr;    /* Toggle Linestring dispayes Polygon                     */
 IGRint    pnts;    /* Toggle Points in the Poles                             */
 IGRint    lsla;    /* Layer for Linestring                                   */
 IGRint    lsco;    /* Color for Linestring                                   */
 IGRint    lswt;    /* Weightfor Linestring                                   */
 IGRint    lsst;    /* Style for Linestring                                   */
 IGRint    ptla;    /* Layer for the Points in the Poles                      */
 IGRint    ptco;    /* Color for the Points in the Poles                      */
 IGRint    ptwt;    /* Weight for the Points in the Poles                     */
};



#define PRINT(str) \
    {  \
             fprintf(stderr,"%s\n",str); \
    }
#define PRINT2(x,y,str) \
    {  \
             fprintf(stderr,"%s\n",str); \
             fprintf(stderr,"stat_OM = %d   rcode = %d\n", x, y); \
    }
#define PRINTM(x,str) \
    {  \
             fprintf(stderr,"%s\nmath error no: %d\n",str,x); \
    }

#define OMREPORT(x) \
    { \
          if(x != OM_W_ABORT) \
             om$report_error(sts = x); \
    }
#define REPORT_ERROR(x,y,str,label) \
    { \
          x = y; \
          if(!(x & SUCC)) { \
             PRINT(str); \
             OMREPORT(y); \
             ex$message(msgnumb = EMS_I_WARNING_MESSAGE); \
             goto label; \
	  } \
    }
#define TEST_ERROR(x,y,str,label) \
    { \
      if(!(x & y & SUCC)) {  \
          PRINT2(x, y, str); \
          OMREPORT(x); \
          ex$message(msgnumb = EMS_I_WARNING_MESSAGE); \
          goto label; \
      } \
    }



#define ABORT_ON_ERROR(x,y,str,label) \
    { \
      if(!(x & y & SUCC)) {  \
          *response = TERMINATE; \
          PRINT(str); \
          OMREPORT(x); \
          me->command = PROCESS_STOP_COMMAND; \
          if(me->form_event_handling) \
             switch_to_process_state(&me->accev,PROCESS_STOP_COMMAND); \
          ex$message(msgnumb = EMS_I_ABORT_MESSAGE); \
          goto label; \
      } \
    }
#define TEST_MATH_ERROR(x,str,label) \
    { \
      if(x != BSSUCC) {  \
          PRINTM(x,str); \
          stat_OM = INFO; \
          ex$message(msgnumb = EMS_I_WARNING_MESSAGE); \
          goto label; \
      } \
    }

