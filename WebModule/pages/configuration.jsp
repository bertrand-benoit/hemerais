<!--
  Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
  Copyright (C) 2010-2015 Bertrand Benoit <projettwk@users.sourceforge.net>
 
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License
  along with this program; if not, see http://www.gnu.org/licenses
  or write to the Free Software Foundation,Inc., 51 Franklin Street,
  Fifth Floor, Boston, MA 02110-1301  USA 
-->

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
 <head>
   <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">  
   <link rel="stylesheet" href="<s:url value="pages/styles/default.css"/>" type="text/css" />  
   <title><s:text name="hemera.title"/> - <s:text name="menu.configuration"/></title>
   <h1><s:text name="hemera.title"/> - <s:text name="menu.configuration"/></h1>
 </head>

 <body>
  <table id="properties">
    <s:iterator value="configurationModel.propertySet" status="propertyStatus">      
     <tr class="<s:if test="#propertyStatus.odd == true ">propertiesTR1</s:if><s:else>propertiesTR2</s:else>">
       <td><s:property value="key"/></td>
       <td><s:property value="value"/></td>
     </tr>   
    </s:iterator>
  </table>

  <s:include value="/pages/part_back2index.jsp"/>
  <s:include value="/pages/part_languages_select.jsp"/>
 </body>
</html>
