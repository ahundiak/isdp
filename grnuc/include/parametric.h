#ifndef parametric_def
#define parametric_def


#define line_generic      0x00000001    /* this element is a line segment  */

#define point_generic     0x00000002    /* this element is a point         */
 
#define conic_generic     0x00000004    /* this element is circular        */
#define circle_type       0x00010004    /*  - circle			   */
#define arc_type          0x00020004    /*  - circular arc		   */

#define parameter_generic 0x00000010    /* this element is an expresison   */
#define double_type       0x00010010    /*  - numeric expression           */
#define text_type         0x00020010    /*  - text string                  */

#define debug_type        0x00000040

#define lbs_generic       0x00000400   /* This element is a "local bounded */
				       /* system": geometric description   */
				       /* of a text			   */
#define lbs_flipped       0x00010400   
#define lbs_not_flipped   0x00000400

#define ref_generic       0x00000100   /* this element is a coord. syst.   */
#define plan_type         0x00010100   /* reserved to implement plane      */

#define macro_generic     0x00000800   /* this element is macro header     */

#define class_generic     0x00001000   /* locate with specific class        */

#define curve_generic     0x00002000   /* this element is a wireframe       */

#define surface_generic   0x00004000   /* surface			    */

#define solid_generic     0x00008000   /* solid 			    */


#define set_generic 	  0x10000000   /* set (like fence contents)         */

#define other_generic     0x04000000   /* this element has an unknown       */
				       /* geoemtric type                    */


/* Macro to test if 2 elements have the same kind of geometric              */

#define geom_mask         0x0000ffff
#define IS_SAME_GEOM(type1,type2) ( ((type1)&(type2))&(geom_mask|other_generic))

struct ref_data {
                 IGRmatrix t;     /* absolute matrix of referential      */
		 IGRint last_t;   /* obsolete info 			 */
                };


struct debug_data { 
                    IGRint value, mark_id, state;
                  };

struct point_data {
                    IGRpoint pt;
                  };

struct circle_data { 
                     IGRpoint cent_p;
                     IGRdouble start_angle, sweep_angle;
                     IGRdouble rad;
                     IGRmatrix mat;
                   };

struct line_data {
                   IGRpoint p0, p1, v0;
                 };

struct root_parameter_data {
                             IGRdouble 	value;
                           };


struct macro_data {
                    char name[20];
                    int  hdr_type;
                  };


struct text_data {
		  IGRchar text_string[80];
		 };


struct lbs_data {
		 IGRdouble matrix[16];
		 IGRdouble diag_pt1[3],diag_pt2[3];
       		};

struct class_data {
		   IGRchar name[80];
		  };



struct ret_struct {
                 IGRint type /* the type of the union */;

                 union {
			 int junk[44];             /* maximal size */
                         struct debug_data dbg_st; 
                         struct circle_data circle_st;
                         struct line_data line_st;
                         struct point_data point_st;
                         struct root_parameter_data root_pm_st;
                         struct ref_data ref_st;
                         struct text_data text_st;
			 struct macro_data macro_st;
			 struct lbs_data lb_st;
			 struct class_data class_st;
                       } var;
               } ;


/* Structure used to construct an associative element */

struct GRas
 {
  OMuint num_parents;    /*  number of parents                                */
  struct GRid *parents;  /*  pointer to parents GRid                          */
  struct GRid *context;  /*  pointer to parent context GRid if the parent is  */
			 /*  in a reference file. NULL_GRid if not            */
  IGRchar *as_attr;      /*  pointer to specific attributes for as object     */
  IGRchar *go_attr;      /*  pointer to specific attributes for go object     */
  struct GRid go_objid;  /*  graphic object objid                             */
  struct GRid my_context;/*  context of the graphic object                    */
 };


#endif
