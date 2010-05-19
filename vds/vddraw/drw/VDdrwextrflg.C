/*
	I/VDS	Copy.
*/

static char		VD_Gc_newExtraction	= 1 ;
/*----------------------------------------------------------------------------*/
void VD_drwSetExtractionFlg( new ) int new ; { VD_Gc_newExtraction = new ; }
/*----------------------------------------------------------------------------*/
int VD_drwIsNewExtraction() { return VD_Gc_newExtraction ; }
/*----------------------------------------------------------------------------*/

