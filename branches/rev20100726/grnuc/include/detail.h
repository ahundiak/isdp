struct GRdvattach_class_attr
{
   IGRchar        *scale;
   IGRchar        *desc;
   IGRint         orientation;
   struct GRid    ref_file;
   struct GRid    coord_sys;
};

struct GRdrawview_class_attr
{
   struct GRid                   da_id;
   struct GRdvattach_class_attr  da_class_attr;
};

struct GRdsborder_class_attr
{
   IGRint         proj_angle;
   IGRchar        *desc;
   struct GRid    polygon_id;
   struct GRid    border_id;
};

struct GRdrawsheet_class_attr
{
   struct GRid                   db_id;
   struct GRdsborder_class_attr  db_class_attr;
};
