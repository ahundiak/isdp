/* contains definitions for curve/linestring editor */
#ifndef ASCVMDH_DEFINED
#define ASCVMDH_DEFINED

#define TENTATIVE_KEY "GRSlTnPnKy\0"

#define dflT2 0

#define RANGE_DIV 		0.3 /* for vector drawing in window */
#define  EPS    1e-4
#define PI      3.141592654
#define EPS1    1e-3
#define EPS2    1e-6
#define MMIN     1e-5 /* base tolerance */
#define DEL     1e-2 /* chor height tolerance */
#define CURSOR_SENS0  600
#define CURSOR_SENS1  1
#define POLE_WEIGHT1  3
#define WEIGHT_LIMIT  20
#define RED 2
#define YELLOW 4
#define DASHED 2
#define FULL 0
#define SMALLEST 0

#define NON_RATIONAL 0
#define RATIONAL 1
#define HIT 1
#define NOHIT 2

/* defaults for var array length */
#define DFT_VX 50
#define DFT_PT DFT_VX * 3
#define DFT_ET 20
#define DFT_EMP 10


#define RECOMP_FUNC_NAM "LSas_crv\0"

/* hot keys */
#define PRODIST   'z'
#define DISTANCE  'd'
#define CURVATURE 'c'
#define HEDGEHOG  'h'
#define POLYGON   'p'
#define SHAPE     'a'
#define RANGE     'r'
#define SYMETRIC  'y'
#define PLANAR    'n'
#define ANFANG    'b'
#define ENDE      'n'
#define PLUS      '+'
#define MINUS     '-'
#define GREAT     '>'
#define LESS      '<'
#define IDLS      'i'
#define PROJECT   'j'
#define FROMTO    'm'
#define STPT      's'
#define OPTIONS   'o'
#define EPT       'e'
#define ESC       '\033'
#define FINIS     '\374'
#define FIX       'x'
#define FREE      'f'
#define TANGENT   't'
#define CURVA     'u'
#define VERTICES  'v'
#define MARK      'm'
#define SMOOTH    'g'

#define SHAPE_MIN 0
#define SHAPE_MAX 50
#define SHAPE_DFLT 25
#define BED_A     1
#define BED_E     1
#define N_ANF     0
#define N_END     0
#define ON 1
#define OFF 0

#define X 0
#define Y 1
#define Z 2
#define X2 3
#define Y2 4
#define Z2 5
#define X3 6
#define Y3 7
#define Z3 8

#define ANZ_NORM 150
#define FAKT -5
/* status Form position */
#define main_WLOX                    1000
#define main_WLOY                    400




/* common buttons */ 
#define ACCEPT_B 		  1
#define RESET_B                   3
#define REJECT_B                  4


/* slider form gadgets */
#define S_LSIDFID_CI              63  /* lienstring identified */
#define S_IDLS_B                  25  /* identify linestring */
#define S_SHVE_B                  42  /* show vertices */
#define S_RANGE_B                 20  /* range button */
#define S_SYM_B                   28  /* symetric button */
#define S_LEFT_B                  29  /* left button */   
#define S_RIGHT_B                 30  /* right button */ 
#define S_SHAPE_B                 21  /* shape button */ 
#define S_CURSOR_S                16  /* cursor sensitivity  toggle */
#define S_SHCU_B                  26  /* show curvature button */
#define S_SHDI_B                  22  /* show distance button */
#define S_SHPO_B                  14  /* show polygon button */
#define S_FROMTO_B                15  /* from -> to or to - to button */
#define S_MINUS_B                 18  /* minus button */
#define S_PLUS_B                  19  /* plus button */
#define S_STARTPT_B               31  /* start point */
#define S_ENDPT_B                 32  /* end point */
#define S_SFREE_B                 51  /* start pt free button */
#define S_SFIX_B                  54  /* start pt fix button */
#define S_STA_B                   61  /* start pt tangent button */
#define S_SCURV_B                 62  /* start pt curvature button */
#define S_EFREE_B                 35  /* end pt free button */
#define S_EFIX_B                  36  /* end pt fix button */
#define S_ETA_B                   37  /* end pt tangent button */
#define S_ECURV_B                 38  /* end pt curvature button */
#define S_PLANAR_B                40  /* curve planar button */
#define S_LRANGE_F                56  /* range left value */
#define S_RRANGE_F                45  /* range right value */
#define S_LSHAPE_F                55  /* shape left value */
#define S_RSHAPE_F                43  /* shape right value */
#define S_SMOOTH_B                64  /* smooth button */
#define S_LESS_B                  66  /* less button */
#define S_GREAT_B                 67  /* greater button */
#define S_SMFAC_F                 65  /* smoothing factor field */
#define S_PRODIST_F               68  /* projection point distance button*/
#define S_PRODIST_B               69  /* set common projection dist button */

#define MSG_F_L  65                   /*length of a message field */
#define M_MSG_F                   9   /*message field */


/* command execute states */
#define GET_CURVE                 1
#define GET_FROM_POINT            2
#define GET_TO_POINT              3
#define GET_LINESTRING            4
#define MAIN_PROCESS              5
#define EXECUTE_COMMAND           6
#define FINISH                    99



#define OPTFORM     1
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

/* structure for dynamic bsp move shape function istruct*/
    struct istruct {
        IGRboolean *first;
        IGRboolean *common_dist;
        IGRboolean *idls_req;
        IGRboolean *ex_cmd_pressed;
        IGRboolean *ex_pocket_pressed;
        IGRboolean ls_found;
        IGRboolean *range_mode;
        IGRboolean *shape_mode;
        IGRboolean *keep_planar;
        IGRint     *shape;
        IGRint     *range;
        IGRint     *shape_amount_left;
        IGRint     *shape_amount_right;
        IGRint     *bed_a;
        IGRint     *bed_e;
        IGRint     *n_anf;
        IGRint     *n_end;
        IGRint     *beg_old;
        IGRint     *fin_old;
        IGRboolean *smooth;
        IGRboolean fromto;
        IGRboolean polygon;
        IGRboolean distance;
        IGRboolean curvature;
        IGRboolean hedgehog;
        IGRint    *nvx;        /* no of points in linestring */
        IGRdouble  *vx;         /* linestring */
        IGRdouble *bpoints;
        IGRdouble *prodist;
        IGRdouble *smfac;
        IGRdouble *point_t;
        IGRdouble *mark_px;
        IGRdouble *mark_py;
        IGRdouble *mark_pz;
        IGRdouble *plocp;
        IGRdouble *par_vec;
        IGRdouble *cv_pts;
        IGRdouble *dists;
        IGRdouble *knot; 
        IGRdouble *pols_x;
        IGRdouble *pols_y;
        IGRdouble *pols_z;
        IGRdouble *pol_x;
        IGRdouble *pol_y;
        IGRdouble *pol_z;
        IGRdouble *vec_x;
        IGRdouble *vec_y;
        IGRdouble *vec_z;
        IGRdouble *l_vek;
        IGRdouble *bf;
        IGRdouble *weigh;
        IGRdouble *p_par;
        IGRdouble *pole;
        IGRdouble *ugpole;
        IGRdouble *opole;
        IGRpoint  pnt_lot;
        IGRint    *p_s;
        IGRint    *m_p;
        IGRint    *p_min;
        IGRint    *p_max;
        IGRint    *t_min;
        IGRint    *t_max;
        IGRdouble *u_par;
        IGRdouble *d;
        IGRint    *cms; /* cursor movement sensitivity */
        IGRdouble *px_old;
        IGRdouble *py_old;
        IGRdouble *pz_old;
        OM_S_OBJID my_id;
        struct IGRplane *plane;
        struct GRmd_env *md_env;
        struct IGRbsp_curve *ocrv;
        struct DPele_header dyn_elements[6];
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

#endif  
