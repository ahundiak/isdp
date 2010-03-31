class specification NMptflp (1:0) of NMfeaturelp, EMSptgralp;

override debug, NMflpinit;

from NMfeaturelp inherit 
	EMupdate_feature, 
	EMintcopy, 
	delete, 
	EMgetsurface_info, 
	EMnesting, 
	EMdisplay, 
	EMget_edges;
	
end specification NMptflp;
