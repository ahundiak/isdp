/*
	I/STRUCT
*/

static char		VS_Gc_newExtraction	= 1 ;
/*----------------------------------------------------------------------------*/
void VSdrwSetExtractionFlg( new ) int new ; { VS_Gc_newExtraction = new ; }
/*----------------------------------------------------------------------------*/
int VSdrwIsNewExtraction() { return VS_Gc_newExtraction ; }
/*----------------------------------------------------------------------------*/

