class specification VLlocateCmd (1:0) of CEO_LOCATE;



#include	"vscmd.h"


instance VLlocateCmd
{
   	struct		GRid			VLwindow;
   			IGRpoint		AcceptPoint;
   			IGRpoint		SavePoint;
   	struct		GRobj_env		Loc_env;
   	struct		GRvg_construct		cst;
			IGRint			Cnt1;
			IGRint			Cnt2;
			IGRint			Cnt3;
	struct		GRobj_env		*Lst1;
	struct		GRobj_env		*Lst2;
	struct		GRobj_env		*Lst3;
   	struct		GRmd_env		Current;
			IGRint			Response;
	struct		GRid			Globals;
	struct		GRobj_env		GrdCsys;
			IGRint			JigType;
			IGRint			FileMode;
			IGRchar			*fileForm;
			VSfileFormInfo		Rfile;	/* Read mode   */
			VSfileFormInfo		Wfile;	/* Write mode  */
			VSfileFormInfo		Afile;	/* Append mode */
			IGRdouble		ActiveTextSize;
			IGRboolean		StatusDisplay;
			IGRboolean		Stacked;
	struct		GRobj_env		ToQueue;
			IGRulong		VStype;
			IGRint			VLtype;
};


override init;

override sleep;

override wakeup;

override delete;

message VLloadCst ( long * sts );

message VLstoreResponse ( long * sts );

message VLstoreLocate ( long * sts );

message VLfreeList ( IGRlong * sts ; IGRint flag );

message VLstoreList ( IGRlong * sts ; IGRint make_indx ; IGRint flag );

message VLnameOccurence (	IGRlong 		*sts;
				IGRchar			*target_dir, 
							*common_name,
							*occ_name );

message VLgetSymbDirName (	IGRlong 		*sts; 
				IGRchar 		*matchKey;
				struct GRid 		*matchId;
				IGRchar			*common_name;
				struct GRsymbology 	*tar_symb; 
				IGRchar			*tar_dir;
				IGRchar			*occ_name );

message VLsetSymbNameDisp (	IGRlong			*sts;
			       	IGRchar 		*name, *matchKey; 
				struct	GRid		*matchId, tar_id;
			   	enum	GRdpmode	*dpmode );

message VLsetGlobals (	IGRlong		*sts;
				IGRchar		*path );

message VLupdGlobals (	IGRlong		*sts );

message VLgetGlobals (	IGRlong		*sts;
				IGRchar		*name;
				IGRdouble	*value );

message VLmodGlobals (	IGRlong		*sts;
				IGRchar		*name;
				IGRdouble	value );

message VLsymbNameDir (       	IGRlong         	*msg;
                             	IGRchar         *matchKey;
			struct	GRid            *matchId;
                                IGRchar         *common_name;
                         struct	GRsymbology     *tar_symb;
                                IGRchar         *tar_dir;
                                IGRchar         *occ_name;
                         struct	GRid            tar_id;
                         enum  	GRdpmode        *dpmode );

message VLstoreCoorSyst ( long * sts );

message VLcreateFileForm ( long * sts );

message fileFormDismissed( int dismissType ) ;

message VLtoggleCommand ( long * sts );

message VLwriteGlobalsInASCII ( long * sts );

message VLreadGlobalsFromASCII ( long * sts );

message VLplateActionHandlerOn ( long * sts );

message VLbeamActionHandlerOn ( long * sts );

message VLstructActionHandlerOff ( long * sts );

message VLisSurfacePlanarAHon ( long * sts );

message VLisSurfacePlanarAHof ( long * sts );

end specification VLlocateCmd;
