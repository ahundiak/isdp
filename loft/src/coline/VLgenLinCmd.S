class specification VLgenLinCmd (1:0) of VLlocateCmd;

instance VLgenLinCmd
{
  struct GRid		hull;
  struct GRid		old_hull;
  struct GRid		previous;
  struct GRid		old_previous;
  struct GRid		cs;
  struct GRid		old_cs;
  struct GRid		allow_dir;
  struct GRid		old_allow_dir;
  struct GRid		pt_select;
  struct GRid		old_pt_select;
  variable struct GRid	cl_line[1];
  variable struct GRid	old_cl_line[1];
  variable int    	num_cl_line[2];
  int			nb_cl_line;
  int			old_nb_cl_line;
  int                   locate_hull;/* indicate the HULL button state  */
  int                   locate_prev;/* indicate the PREVIOUS button state  */
  int                   locate_add;/* indicate the ADD button state  */
  int                   locate_del;/* indicate the DELETE button state  */ int                   locate_pt_select; int                   locate_modif; int                   point2; /* indicate if you will locate first or second
                                   point for direction  vector */
  int                   old_point2;/* old flag value of point2 field */
  struct GRid           to_modify; /* object to modify */
  struct GRid           old_to_modify; /* object to modify */
  IGRdouble             length; 
  int                   dev;
  int                   old_dev;
  IGRdouble             allowence;
  IGRdouble             ext_allow;

  struct GRid           box;
  struct GRid           *vect;
  struct GRid           al_plug;
  struct GRid           pt_plug;
  char			*form_ptr;
};


message VLchaine_locate (int *sts ;long respo ; int gadget1, gadget2, flag);

message VLcontrol_hull (int *sts; int gadget1, gadget2, gadget3, code);

message VLis_hull_defined (int *sts ; int gadget1);

message VLcontrol_data1 ( int *sts);

message VLcontrol_data2 (int *sts; int gadget1, gadget2);

message VLcontrol_cl_line (int *sts; int code, gadget);

message VLadd_1_cl_line (int *msg ; struct GRid *obj ; GRclassid super);

message VLcontrol_obj (int *sts; int code, gadget1, gadget2);

message VLcontrol_data (int *sts; int gadget1, gadget2);

message VLparse_str ( int *sts ; char *direction ; struct GRid *obj);

message VLcontrol_pt2 (int *sts ; int gadget1, gadget2);

message VLcontrol_exp (int *sts ; int gadget1, gadget2);

message VLcontrol_exp2 (int *sts ; int gadget1, gadget2);

message VLcontrol_exp_sel (int *sts ; int gadget1, gadget2);

message VLcontrol_sel_pt (int *sts ; int gadget1, gadget2);

end specification VLgenLinCmd;
