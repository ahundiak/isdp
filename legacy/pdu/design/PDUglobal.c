#include 	<OMlimits.h>
#include 	<PDUint.h>
#include 	<PDUintdef.h>
#include 	<PDUproto.h>

extern IGRint    PDU_status_temp;		/* Temp storage for status */
extern IGRchar	  PDU_last_file [OM_K_MAXOSNAME_LEN];
extern IGRshort  PDU_spi_flag;
extern IGRint    PDU_invis_file_index;
extern IGRint    PDU_file_type;
extern IGRint    PDU_new_part;
extern IGRint    PDUactive_checkin;
extern IGRshort  PDU_tree_attach;
extern IGRshort  PDU_nfs_flag;			/* NFS usage flag */
extern IGRmatrix PDUrot_mat;			/* ALIGN- trans rot matrix */
extern IGRmatrix PDUal_view_rot;		/* ALIGN- part's rot matrix */
extern IGRchar   *PDU_save;


int	PDUnfs_toggle ()
  {
  IGRint        status;			/* return status */

  _pdm_debug("In the function PDUnfs_toggle, on/off flag = %d", (char *)PDU_nfs_flag);
  /* toggle the NFS flag */
  if ( PDU_nfs_flag == ON )
     {
     PDU_nfs_flag = OFF;
     status = PDM_I_NFS_OFF;
     }
  else
     {
     PDU_nfs_flag = ON;
     status = PDM_I_NFS_ON;
     }

  _pdm_debug("on/off flag changes to = %d", (char *)PDU_nfs_flag );

  return (status);
  }


int	PDUtree_toggle ()
  {
  IGRint        status;
  extern IGRshort  PDU_tree_attach;

  _pdm_debug("In the function PDUtree_toggle, on/off flag = %d", (char *)PDU_tree_attach);

  /* toggle the tree attach flag */
  if ( PDU_tree_attach == ON )
     {
     PDU_tree_attach = OFF;
     status = PDM_I_TREE_ATTACH_OFF;
     }
  else
     {
     PDU_tree_attach = ON;
     status = PDM_I_TREE_ATTACH_ON;
     }

  _pdm_debug("on/off flag changes to = %d", (char *)PDU_tree_attach );

  return (status);
  }


