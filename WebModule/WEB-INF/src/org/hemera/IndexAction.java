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
 * Web Service index controller.
 * 
 * @author Bertrand Benoit <hemerais@bertrand-benoit.net>
 * @since 0.2
 */
public final class IndexAction extends ActionSupport {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private static final long serialVersionUID = 1405439634571138061L;

    /****************************************************************************************/
    /*                                                                                      */
    /* Attributes                                                                           */
    /*                                                                                      */
    /****************************************************************************************/

    private IndexModel indexModel;

    /****************************************************************************************/
    /*                                                                                      */
    /* Implementation of ActionSupport                                                      */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @see com.opensymphony.xwork2.ActionSupport#execute()
     */
    @Override
    public final String execute() throws Exception {
        indexModel = new IndexModel();
        return SUCCESS;
    }

    /****************************************************************************************/
    /*                                                                                      */
    /* Getters / Setters                                                                    */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return the indexModel
     */
    public final IndexModel getIndexModel() {
        return indexModel;
    }

}
