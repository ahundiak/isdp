/*****************************************************************
Author	: B. Demars 
Date	: February , 1989 .



	   +------------------------------------------------+
	   |		DATA STRUCTURE DEFINITION	    |
	   +------------------------------------------------+


Dependancies : 	gr.h
		dpstruct.h
		parametric.h
		
*****************************************************************/

#ifndef dim13_include
#define dim13_include

/*------ dimensioning plane description structure -----------*/

struct DMplan
	{
		struct GRid macro; /* id of the macro dim_plan */
		struct GRid plane; /* id of the plane pretend  */
		struct GRid xaxis_id;  /* id of the xpos pretend  */
		struct GRid yaxis_id;  /* id of the ypos pretend  */
		double matrix[16]; /* plane matrix */
		double xaxis[3];   /* X axis coordinates */
		double yaxis[3];   /* Y axis coordinates */
		double zaxis[3];   /* Z axis coordinates */
	};


/*------ description of the two dimensioning planes associated to a window */

struct DMplanes
	{
		struct DMplan winplan; /* describes the window plane */
		struct DMplan actplan; /* describes the active plane */
	};

/*----- arguments' structure for the DMdraw_axes function -----*/

struct DMaxes
	{
		IGRlong 		*msg;	/* (O)return code */
		struct DMplan		*plan;  /* (I)plane supporting the axes */
		IGRdouble		*coord; /* (I)axes intersection coord */
	};

/*----- description of the event used as root for dimensioning graph */

struct DMevent
	{
		struct GRid	object;	/* id of the dimension root */
	};


/*----- dimension graph description list ---------------------------*/


struct DMid
	{
		struct GRid	dat_cmpx; /* This structure stores the ids */
		struct GRid	dim_orig; /* of every macros composing the */
		struct GRid	dim_meas; /* graph */
		struct GRid	dim_sque;
		struct GRid	dat_elem;
		struct GRid	dim_elem;
		struct GRid	dim_box;
		struct GRid	dim_under;
	};

/*----- dimension internal instances ---------------------------*/

struct DMdat_elem
 {
  double good_alignement;
  char   release[16];

	char  sub_type;

  	char  mea_type; 
  	char  mea_mode; 

	short dim_layr;
	char  dim_colr;
	char  dim_weig;
	char  txt_weig;
	char  tol_weig;

	char ter_disp; 
	char wit_disp; 
	char lin_disp; 
	char rad_disp; 

 	char txt_orie;
 	char txt_posn;
  	char txt_side;
  	char txt_just;
  	char txt_loca_mode;
  	char txt_loca;
  	char ter_type_mode;
  	char ter_type;
  	char ter_loca_mode;
  	char ter_loca;

  	char dimn_mode;
  	char tole_mode;
  	char dual_mode;
	char dual_disp;
  	char dual_dimn;
  
  	char   val_unit[2];
	char   val_dimn_value_type[2];
	char   val_tole_up_type[2];
	char   val_tole_low_type[2];

        char   add_text;
  	char   prefix[16];
  	char   pre_symbol[2];
  	char   post_symbol[2];
  	char   suffix[16];
 
	char flag_dim_symb;
	char flag_txt_strg;
	char flag_txt_form;
	char flag_exp_grap;
	char flag_exp_text;

        char   mod_comp;
        char   box_type;
	char   sym_disp;

        char   ter_type0_mode;
        char   ter_type0;
        char   not_scal;
	char   feet_n_inches;	   /* use one future_char for feet_inches */
        char   future_char[18];

        double sca_fact;

  	double val_dimn_value[2];
  	double val_tole_up[2];
  	double val_tole_low[2];
 
  	char   si_unit[8];
  	double si_unit_factor;
  	char   si_form_d[16];
  	char   si_form_t[16];

  	char   us_unit[8];
  	double us_unit_factor;
  	char   us_form_d[16];
  	char   us_form_t[16];

  	double txt_heig;
  	double txt_widt;
  	double ter_heig;
  	double ter_widt;
	double txt_xoff_r;
	double txt_yoff_r;
  	double wit_offs_r;
  	double wit_extn_r;
  	double pnt_inte_r;
  	double pnt_exte_r;
  	double lea_leng_r;

        double future_double[18];

  char   _end;
 };


struct DMdat_cmpx
 {
  double good_alignement;
  char   release[16];

        char mac_type;

  	char mea_type;
  	char mea_axis;
	char mea_disp;

        char future_char[16];

  	double txt_heig;
  	double lin_orig_r;
  	double lin_offs_r;
  	double wit_angl;

        double future_double[6];

  char _end;
 };

/*----- dimensioning parameters structures --------------------*/

struct DMdat_environ
 {
  double good_alignement;
  char   release[16];

  char   mod_flag;

 /*
  * standard
  */

  char   dim_stan[8]; 	/* standard, only for display 	*/
  char   mea_unit;	/* measurement units: DRAWING or MODEL */

  char   mod_asso;	/* associativity : ON or OFF*/	

 /*
  * symbology
  */
  
  short  dim_layr; 	/* layer			*/
  char   dim_colr;	/* color			*/

  char   dim_weig;  	/* weight for witness and dimension lines	*/
  char   txt_weig;  	/* weight for dimension value text		*/
  char   tol_weig;	/* weight for tolerance text 			*/

  char   sym_posn  ;	/* positon of diameter symbol: BEFORE or AFTER */
  char   txt_rati  ;	/* aspect ratio	: ON or OFF			*/
  char   trk_posn  ;    /* type of track point placement :ABSOLUTE or RELATIVE*/
  char   sym_disp;	/* AUTO, SUPRESSED, RADIAL or DIAMETER */
  char   pnt_disp;	/* AUTO or SUPRESSED */
  char   feet_n_inches;	/* Use one future_char for feet and inches */
  char   future_char[20];

 /* 
  * text attributes ( see text attributes in dimdef.h ).
  */

  short fnt_numb;
  char  fnt_name[160];
  short fnt_locl[10];
  char  fnt_char[10];
  
  /* text_string escape_sequences */

  short  double_number;
  char   double_names[160];
  double double_values[20];


  char   fnt_name_s[80];
  short  fnt_locl_s[5];
  char   fnt_char_s[5];

  char   editable[8];

  char   future_data[81];

  double txt_rati_r;  	/* ratio only if (txt_ratio == on)		*/
  double txt_heig  ;	/* text height, if (on) = txt_widt/ txt_rati_r	*/
  double txt_widt  ; 	/* text width , if (on) = txt_heig* txt_rati_r	*/
  double car_spac_r;	/* character spacing				*/

  double ter_heig_r;
  double ter_heig  ; 	/* auto = txt_heig* ter_heig_r			*/
  double ter_widt_r;
  double ter_widt  ; 	/* auto = txt_widt* ter_widt_r 			*/
  
 /*
  * graphic attributes
  */

  double txt_xoff_r;	
  double txt_yoff_r;
  double lin_orig_r;
  double lin_offs_r;	/* stack clearance				*/
  double wit_angl  ;
  double wit_offs_r;	/* witness line gap				*/
  double wit_extn_r;	/* projection above				*/
  double pnt_inte_r;	/* minimum spacing				*/
  double pnt_exte_r;
  double lea_leng_r;


  char   df_unit[8];
  double txt_heig_u;
  double txt_widt_u;

/* allocate space for 4 short values */

  short short_number;
  short kludge[3];
  char  short_names[32];
  short short_values[4];

  double future_double[5];

  char   _end;
 }; 	


struct DMdat_local
 {
  double good_alignement;
  char   release[16];

	char mod_flag;
	char mac_type;	/* SYMBOL_MACRO or NESTED_MACRO */
  	char mea_type;	/* LINEAR, ANGULAR, RADIAL or COORDINATE */
  	char mea_axis;	/* measurement axis: AXEX, AXEY, BY2PT, AXEX_WIND,
  			   AXEY_WIND or ORTHOGONAL */
  	char mea_mode;	/* ABSOLUTE, RELATIVE, HALF or SYMMETRICAL */
  	char mea_disp;	/* CHAINED, STACKED, RADIAL, DIAMETER, COORDINATE */
	char ter_disp;	/* terminator line display:OFF, LEFT,RIGHT,BOTH*/
	char wit_disp;	/* projection line display:OFF, LEFT,RIGHT,BOTH*/
	char lin_disp;  /* display of complete dimension line:OFF,ON  */
	char rad_disp;  /* display of complete radius line:OFF,ON  */
 	char txt_orie;	/* text orientation: PARALELL,	HORIZONTAL	*/
	char txt_posn;	/* text position: ABOVE,	EMBEDDED	*/
  	char txt_side;	/* text side:	MIDDLE,	FIRST,SECUND	*/
 	char txt_just;	/* text just:CENTERED ,LEFT,RIGHT ,AUTO_JUST */
  	char txt_loca_mode; /* text location mode: AUTO,INTERNAL,EXTERNAL*/
  	char txt_loca;	/* text location: INTERNAL,EXTERNAL*/
  	char ter_loca_mode; /* terminator location mode:AUTO,INTERNAL,EXTERNAL*/
  	char ter_loca;	/* terminator location	: INTERNAL,EXTERNAL*/
	char ter_type;	/* terminator type: see terminator type in dimdef.h*/
  	char dimn_mode; /* text placing mode:AUTO ,MANUAL , SEMI_MANUAL */
  	char tole_mode;	/* tolerance display:see tolerance display in dimdef.h*/
  	char dual_mode;	/* units : OFF or ON */
	char dual_disp; /* dual display: ABOVE or SLASH ..not implemented yet*/
  	char dual_dimn; /* dual mode: AUTO,MANUAL */
  	char   val_unit[2];/* see val_unit in dimdef.h */
        char   val_dimn_value_type[2];/* see val_dimn in dimdef.h */
  	char   val_tole_up_type[2];/* see val_dimn in dimdef.h */
  	char   val_tole_low_type[2];/* see val_dimn in dimdef.h */
	char add_text;	/* text insertion : see add_text in dimdef.h */
  	char prefix[16];
  	char pre_symbol[2];
  	char post_symbol[2];
  	char suffix[16];

        char mod_comp; /* dimension measurement mode : STATIC, DYNAMIC */
	char box_type; /* dimension box display mode : OFF, ON */
	char ang_dimn_value_type;
	char ang_tole_up_type;
	char ang_tole_low_type;
	
        char ter_type0_mode; /* terminator location mode: AUTO, MANUAL */
        char ter_type0; /* same as ter_type */

        char not_scal; /* under_line text: ON or OFF */

        char editable[8];

        char future_char[15];

        double sca_fact;
  	double val_dimn_value[2];
  	double val_tole_up[2];
  	double val_tole_low[2];
 
  	char   si_unit[16];
  	double si_unit_factor;
  	char   si_form_d_deci[16];
  	char   si_form_t_deci[16];

  	char   us_unit[16];
  	double us_unit_factor;
  	char   us_form_d_deci[16];
  	char   us_form_t_deci[16];

	double ang_dimn_value;
	double ang_tole_up;
	double ang_tole_low;
	
  	char   an_unit[16];
  	double an_unit_factor;
  	char   an_form_d_deci[16];
  	char   an_form_t_deci[16];

        double future_double[1];

  char _end;
 };





struct DMdat_geom
  {
   double good_alignement;
   char   release[16];
  
   char leader_flag;
   char leader;
   char arrow;
   char just;
   
   char tolerance;
   char material;
   char diameter;
   char shape;
   char box_flag;
  

   short fnt_numb;
   char  fnt_name[480];
   short fnt_locl[30];
   char  fnt_char[30];

   char _end;
  };


/*----- dimension construction list ---------------------------*/
	/* - It is initialized by two function:
			DMinit_cnstlis() 
			DMupdt_cnstlis() */


struct DMconstruct
	{
		/* - Data depending on the type of dimension */
		
		IGRchar	macros_names[9][14];  /* selection of the macros that
					      will be in the dimension
					      graph. There are 6 macros
					      building the graph, the 7th
					      element is the name of the
					      additional squeleton in a
					      complex dimension, and the
					      8th and 9th elements are the
					      box and under line that can
					      be added to the dimension text */
		/* - Graphics elements description */
		
		IGRint	num_graphics;	   /* number of graphic macros
					      composing dim_elem */
		IGRchar *gr_entries[9];    /* names of the locations
					      available within dim_elem */
		IGRchar *gr_macros[9];	  /* names of the graphic macros
					      corresponding to the entries */

		IGRint  prefix_len[9];	  /* to optimize the graphic macros
					     names initialization */
		/* - Dimension parameters */

		struct DMdat_cmpx	dat_cmpx;  /* dimension complex parameters */
		struct DMdat_elem	dat_elem;  /* dimension local parameters */

		/* - Dimension geometric parameters */
		
		struct ret_struct	dim_line;  /* dimension line description */
		IGRdouble		brk_pt[3]; /* break point coordinates */
		
		IGRboolean		leader;	   /* leader line exists ? */
		IGRdouble		lea_pt[3]; /* leader point coordinates */

		IGRboolean		offset;	   /* text has been offset */
		IGRdouble		off_pt[3]; /* astext instances */

/*----- storage of the instance data of a text object, except symbology ------*/

		struct 
		  {
		   struct GRdpb_text_symb text_attr;
		   char  *text_string;
		   short  text_length;
		  }      		text[3];   /* instance data of text  */
                                                   /* for the 2 arrows and   */
                                                   /* the dimension text     */
                char text_string[MAX_TEXT_STRING]; /* buffer to store the 3  */
                                                   /* text_strings:          */
                                                   /*   car 0= first arrow   */
	                                           /*   car 1= second arrow  */
                                                   /*   car 2,...= dim_text  */
	};

/*----- structure to store a text_string containing null characters which
        do not represent end_of_string -------*/
        
struct DMnon_ascii_text 
  {
   char  *string;
   short index;
   short length;
   short size; 
  };

/*-------- description of the sub_strings used to concatenate text_string ---*/

struct DMdat_fields
  {
   double good_alignement;
   char   release[16];
   char   buffer_string[4096];
   struct DMnon_ascii_text buffer[1];
   struct DMnon_ascii_text fields[32];

   char   _end;
  };

#endif
