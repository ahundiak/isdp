#include	"../include/WFstruct.h"

extern  char    NFM_APP_ID[4];
extern  char    NFM_WF_CACHED[21];

extern  struct  nfm_cmd	**NFMcmds,**APPcmds;
extern  struct  nfm_tbl	**NFMtables;
extern  struct  nfm_state **NFMstates;
extern  struct  nfm_trans **ADMtrans,**SDPtrans,**CATtrans,**PROJtrans;
extern  struct  nfm_trans  **ITEMtrans, **APPtrans;
extern  struct  nfm_wf  NFMwfs[];

extern  struct  WFstruct  WFinfo;

extern  int	CURR_CMD, NO_NFM_CMDS, NO_APP_CMDS, NO_STATES, NO_TABLES;
extern  int	SDP_TRANS, ADM_TRANS;
extern  int	PROJ_TRANS, CAT_TRANS, ITEM_TRANS;
extern  int	APP_TRANS;
extern  int 	sdp_wfno, admin_wfno, item_wfno, cat_wfno, proj_wfno;
extern  int	app_wfno, NFMcmd_pointer, NFMstate_pointer;

extern  int	SDPindex1;
extern  int	SDPindex2;
extern  int	ADMindex1;
extern  int	ADMindex2;
extern  int	CATindex1 ;
extern  int	CATindex2 ;
extern  int	PROJindex1;
extern  int	PROJindex2;
extern  int	ITEMindex1;
extern  int	ITEMindex2;
extern  int	APPindex1 ;
extern  int	APPindex2 ;
