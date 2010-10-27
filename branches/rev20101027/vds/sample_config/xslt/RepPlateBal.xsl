<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
     <table name ="Plate Balancement Report"
	    description="Plate Balancement Report">
        <xsl:for-each select="SMS_PRS/SMS_PRS_UNIT/SMS_BALANCEMENTS/SMS_BALANCEMENT"
		order-by="INDEX">
	  <layout>
	    <column title="Index"             column_no="1"/>
	    <column title="On Ground X-Coord" column_no="2"/>
	    <column title="On Ground Y-Coord" column_no="3"/>
	    <column title="On Ground Z-Coord" column_no="4"/>
	    <column title="In Ship X-Coord"   column_no="5"/>
	    <column title="In Ship Y-Coord"   column_no="6"/>
	    <column title="In Ship Z-Coord"   column_no="7"/>
	  </layout>
	  <row>
              <cell column_no="1" value="" />
              <cell column_no="2" value="Name: {@NAME}\nNumber of Elements: {@NUM_ELEM}\nX-Angle: {@X_ANGLE}\nY-Angle: {@Y_ANGLE}\nZ-Angle: {@Z_ANGLE}" />
	      <cell column_no="3" value="" /> 
	      <cell column_no="4" value="" />
	      <cell column_no="5" value="" />
	      <cell column_no="6" value="" />
	      <cell column_no="7" value="" />
	  </row>
	  <row>
	    <cell column_no="1" value="Index"             />
	    <cell column_no="2" value="On Ground X-Coord" />
	    <cell column_no="3" value="On Ground Y-Coord" />
	    <cell column_no="4" value="On Ground Z-Coord" />
	    <cell column_no="5" value="In Ship X-Coord"   />
	    <cell column_no="6" value="In Ship Y-Coord"   />
	    <cell column_no="7" value="In Ship Z-Coord"   />
	  </row>
          <xsl:for-each select="SMS_CORNER_INFO" order-by="CORNER_INDEX">
	    <row>
              <cell column_no="1" value="{@CORNER_INDEX}" />
              <cell column_no="2" value="{SMS_ON_GROUND/@ON_GROUND_X}" />
	      <cell column_no="3" value="{SMS_ON_GROUND/@ON_GROUND_Y}" />
	      <cell column_no="4" value="{SMS_ON_GROUND/@ON_GROUND_Z}" />
	      <cell column_no="5" value="{SMS_ON_GROUND/@IN_SHIP_X}" />
	      <cell column_no="6" value="{SMS_ON_GROUND/@IN_SHIP_Y}" />
	      <cell column_no="7" value="{SMS_ON_GROUND/@IN_SHIP_Z}" />
            </row>
         </xsl:for-each>
       </xsl:for-each>
     </table>
   </xsl:template>
</xsl:stylesheet>
