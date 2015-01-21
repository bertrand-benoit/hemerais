/*
 * Hemera - Intelligent System (http://hemerais.bertrand-benoit.net)
 * Copyright (C) 2010-2015 Bertrand Benoit <hemerais@bertrand-benoit.net>
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

import com.opensymphony.xwork2.ActionSupport;

/**
 * Hemera - Intelligent System
 * Web Service changeLog controller.
 * 
 * @author Bertrand Benoit <hemerais@bertrand-benoit.net>
 * @since 0.2
 */
public final class ChangeLogAction extends ActionSupport {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private static final long serialVersionUID = 5479166205681488821L;

    /****************************************************************************************/
    /*                                                                                      */
    /* Attributes                                                                           */
    /*                                                                                      */
    /****************************************************************************************/

    private static final ChangeLogModel changeLogModel = new ChangeLogModel();

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
     * @return the ChangeLogModel.
     */
    public final ChangeLogModel getChangeLogModel() {
        return changeLogModel;
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
