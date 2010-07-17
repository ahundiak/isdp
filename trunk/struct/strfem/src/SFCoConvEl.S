class specification SFCoConvEl (1:0) of CEO_LOCATE;



#include "growner.h"

#define  SF_INIT_PLATES  2
#define  SF_INIT_STFNS	 2
#define  SF_INIT_BEAMS	 2

#define  FP_EL		me^^CEO.forms[0].form_ptr
#define  FP_PL		me^^CEO.forms[1].form_ptr
#define  FP_STFND_PL	me^^CEO.forms[2].form_ptr
#define  FP_BM		me^^CEO.forms[3].form_ptr


instance SFCoConvEl
{
 int			     PlateCount;
			     /* no. of plates selected for conversion */

 variable struct  GRobj_env  VSplateList[SF_INIT_PLATES];
			     /* struct plate ids and envs */

 variable int		     StfnsOnPl[SF_INIT_PLATES];
			     /* No. of beams on each plate */

 variable struct GRid	     FEplateList[SF_INIT_PLATES];
			     /* fem plate ids */

 int			     StfnCount;
			     /* Total no. of beams  */

 variable struct  GRobj_env  VSstfnList[SF_INIT_STFNS];
			     /* struct beam list  */

 variable struct  GRid	     FEstfnAxisList[SF_INIT_STFNS];
			     /* fem beam axis list  */

 variable char		     PlMatCreateFlag[SF_INIT_PLATES];
			     /* TRUE : material has been created for that plate
				       which will be deleted if form is deleted.
				FALSE: material has not been created  */

 variable char		     PlPrpCreateFlag[SF_INIT_PLATES];
			     /* same as materials */

 variable char		     StfMatCreateFlag[SF_INIT_BEAMS];
			     /* TRUE : material has been created for that beam
				       which will be deleted if form is deleted.
				FALSE: material has not been created  */

 variable char		     StfPrpCreateFlag[SF_INIT_BEAMS];
			     /* same as materials */

 int			     BeamCount;
			     /* no. of beams selected for conversion */

 variable struct  GRobj_env  VSbeamList[SF_INIT_BEAMS];
			     /* struct beam ids and envs */

 variable struct  GRid	     FEbeamAxisList[SF_INIT_BEAMS];
			     /* struct beam centroidal axis list  */

 variable char		     BmMatCreateFlag[SF_INIT_BEAMS];
			     /* TRUE : material has been created for that beam
				       which will be deleted if form is deleted.
				FALSE: material has not been created  */

 variable char		     BmPrpCreateFlag[SF_INIT_BEAMS];
			     /* same as materials */

 struct  GRmd_env	     MyEnv;
			     /* this is same as ModuleInfo except that
				MyEnv.md_id.objid = NULL_OBJID. All the
				manipulations are done outside range tree.
				FEbeamAxisList is added to range tree when the
				form is accepted */
};


message set_all ( long * sts );

message erase_hilite ( long * sts );

message hilite_selected ( long * sts );

message verifyLogin ( long *msg);

message AddToList ( long * sts );

message GetElementsData ( long * sts );

message ElementsSelected ( long *msg );

message disp_form ( long * sts );

end specification SFCoConvEl;
