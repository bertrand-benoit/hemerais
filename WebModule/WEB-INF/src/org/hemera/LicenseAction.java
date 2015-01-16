/*
 * Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
 * Copyright (C) 2010-2015 Bertrand Benoit <projettwk@users.sourceforge.net>
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

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionSupport;

/**
 * Hemera - Intelligent System
 * Web Service license controller.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 0.2
 */
public final class LicenseAction extends ActionSupport {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private static final long serialVersionUID = -1732170254768204032L;

    /****************************************************************************************/
    /*                                                                                      */
    /* Attributes                                                                           */
    /*                                                                                      */
    /****************************************************************************************/

    /****************************************************************************************/
    /*                                                                                      */
    /* Constructors                                                                         */
    /*                                                                                      */
    /****************************************************************************************/

    /****************************************************************************************/
    /*                                                                                      */
    /* Getters / Setters                                                                    */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return the LicenseModel.
     */
    public final LicenseModel getLicenseModel() {
        // Gets the specified license (if any).
        final String[] specifiedLicense = (String[]) ActionContext.getContext().getParameters().get("license");

        return new LicenseModel((specifiedLicense == null || specifiedLicense.length == 0) ? null : specifiedLicense[0]);
    }
    /****************************************************************************************/
    /*                                                                                      */
    /* Specific methods                                                                     */
    /*                                                                                      */
    /****************************************************************************************/

    /****************************************************************************************/
    /*                                                                                      */
    /* Overrides                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

}
