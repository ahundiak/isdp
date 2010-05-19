<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
     <table name="Pin Jig Corners Report" description="Pin Jig Corners Report">
        <xsl:for-each select="SMS_PRS/SMS_PRS_UNIT/SMS_PINJIGS/SMS_PINJIG">
           <layout>
	      <column title="Corner Pin Name" column_no="1"/>
	      <column title="Pin X-Position"  column_no="2"/>
	      <column title="Pin Y-Position"  column_no="3"/>
	      <column title="Pin Z-Position"  column_no="4"/>
	      <column title="Nearest Pin"     column_no="5"/>
           </layout>
           <xsl:for-each select="SMS_CORNER_DATA/CORNER_DATA" order-by="NAME">
	      <row>
                 <cell column_no="1" value="{@NAME}" />
                 <cell column_no="2" value="{@PIN_X_POS}" />
	         <cell column_no="3" value="{@PIN_Y_POS}" />
	         <cell column_no="4" value="{@PIN_Z_POS}" />
	         <cell column_no="5" value="{@REF_PIN_NAME}" />
              </row>
           </xsl:for-each>
        </xsl:for-each>
     </table>
  </xsl:template>
</xsl:stylesheet>
