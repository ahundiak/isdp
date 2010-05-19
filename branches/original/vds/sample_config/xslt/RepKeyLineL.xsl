<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" standalone="yes" indent="yes"/>
  <xsl:template match="/SMS_PRS/SMS_PRS_UNIT/SMS_KEYLINES/SMS_KEYLINE/SMS_LONG_INFO">
    <table desc="Longitudinal keylines">
      <layout>
	 <column title="-" />
	 <xsl:for-each select="SMS_ROW_DATA[position()=1]/SMS_COL_DATA">
	   <column title="{@SMS_COL_NAME}"/>
         </xsl:for-each>
      </layout>
      <row>
        <cell column_no="1" value="" />
        <xsl:for-each select="SMS_ROW_DATA[position()=1]/SMS_COL_DATA">
	   <cell column_no="{position()+1}" value="{@SMS_COL_NAME}" />
        </xsl:for-each>
      </row>
      <xsl:for-each select="SMS_ROW_DATA">
	 <row>
	    <cell column_no="1" value="{@SMS_ROW_NAME}" />
            <xsl:for-each select="SMS_COL_DATA">
               <cell column_no="{position()+1}" value="{@DISTANCE}" />
            </xsl:for-each>
	  </row>
      </xsl:for-each>
    </table>
  </xsl:template>
</xsl:stylesheet>
