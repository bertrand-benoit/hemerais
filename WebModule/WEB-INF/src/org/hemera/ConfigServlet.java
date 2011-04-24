/*
 * Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
 * Copyright (C) 2010-2011 Bertrand Benoit <projettwk@users.sourceforge.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses
 * or write to the Free Software Foundation,Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA 02110-1301  USA
 */

package org.hemera;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Hemera - Intelligent System
 * Web Service config servlet.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 1.0.0
 */
public final class ConfigServlet extends HttpServlet {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants */
    /*                                                                                      */
    /****************************************************************************************/

    private static final long serialVersionUID = 1966094966098169686L;

    /****************************************************************************************/
    /*                                                                                      */
    /* Implementation of HttpServlet */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
     */
    @Override
    protected void doGet(final HttpServletRequest request, final HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("text/html");
        final PrintWriter out = response.getWriter();

        out.println("<h1>Hemera Configuration</h1>");
        final String installDir = HemeraUtils.getInstallDir();
        out.println("   installation directory: " + installDir + "<br />");
        final Properties configuration = HemeraUtils.getConfiguration();
        for (final Map.Entry<?, ?> entry : configuration.entrySet()) {
            out.println("   " + entry.getKey() + ": " + String.valueOf(entry.getValue()).replaceAll("\"", "") + "<br />");
        }
    }
}
