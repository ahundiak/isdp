/*
  ABSTRACT

  This class represents surfaces that are spheres.


  HISTORY

  05/24/91        msm     Override GRreport, GRreport_defaults, GRupdate_
                          gadgets. Removed override GRloadform, GRgetsfsize.
  01-Aug-88	    RV	    removed EMsurfintgrl override.
  05/16/88        dhm     Overrode GRloadform and GRgetsfsize.
  23 Mar 88       AIC     Override EMgetRuleLineTable.
  12/02/87  PP            Replaced EMget_sphere_props with
                          EMget_params
  13 October 87   AIC     Conversion to EMS 1.1
                           Suclasses EMSrevconic and EMSquadaric.
  gk 21-may-87     override EMsurfintgrl method
  JBK 06-MAY-1987 : removed override of EMintplane_notrim
  RLW     09/21/86 : The beginning
*/

class specification EMSsphere (2:0) of EMSrevol;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetRuleLineTable;

#ifndef BASE_EMS

message EMsphere_by_center_radius
(
  struct GRvg_construct *construct_list;
  IGRpoint center;
  IGRdouble radius;
);

override
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets,
  EMget_natedge_info,
  EMget_params;
    
#endif

end specification EMSsphere;
