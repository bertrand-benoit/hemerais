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

import java.util.Collection;

import org.hemera.utils.HemeraUtils;

/**
 * Hemera - Intelligent System
 * Web Service changeLog model.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 0.2
 */
public final class ChangeLogModel {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private static final Collection<String> CHANGELOG_CONTENT = HemeraUtils.getChangeLogContents();

    /****************************************************************************************/
    /*                                                                                      */
    /* Getters / Setters                                                                    */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return the contents of changeLog.
     */
    public final Collection<String> getContents() {
        return CHANGELOG_CONTENT;
    }

}
