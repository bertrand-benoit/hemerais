<!--
  Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
  Copyright (C) 2010-2011 Bertrand Benoit <projettwk@users.sourceforge.net>
 
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

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
 <head>
   <link rel="stylesheet" href="<s:url value="pages/styles/default.css"/>" type="text/css" />
   <title><s:text name="hemera.title"/></title>
   <h1><s:text name="hemera.title"/></h1>
 </head>

 <body>
    <ul> 
      <s:iterator var="menuItem" value="indexModel.menu">            
        <s:url var="itemURL" action="%{#menuItem}" />      
        <li>
         <s:a href="%{itemURL}">
          <s:text name="menu.%{#menuItem}"/>
         </s:a>
        </li><br />
      </s:iterator>
    </ul>
    
    <s:include value="/pages/part_languages_select.jsp"/>
 </body>
</html>
