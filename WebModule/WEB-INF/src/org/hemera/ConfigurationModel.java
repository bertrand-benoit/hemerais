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

import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;

import org.hemera.utils.HemeraUtils;

/**
 * Hemera - Intelligent System
 * Web Service config model.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 0.2
 */
public final class ConfigurationModel {

    /****************************************************************************************/
    /*                                                                                      */
    /* Attributes                                                                           */
    /*                                                                                      */
    /****************************************************************************************/

    private final String installDir;
    private final String changeLog;
    private final Properties properties;

    /****************************************************************************************/
    /*                                                                                      */
    /* Constructors                                                                         */
    /*                                                                                      */
    /****************************************************************************************/

    public ConfigurationModel() {
        installDir = HemeraUtils.getInstallDir();
        changeLog = HemeraUtils.getInstallDir();
        properties = HemeraUtils.getConfiguration();
    }

    /****************************************************************************************/
    /*                                                                                      */
    /* Getters / Setters                                                                    */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return the installDir
     */
    public final String getInstallDir() {
        return installDir;
    }

    /**
     * @return the changeLog
     */
    public final String getChangeLog() {
        return changeLog;
    }

    public final Set<Entry<Object, Object>> getPropertySet() {
        return properties.entrySet();
    }

    /****************************************************************************************/
    /*                                                                                      */
    /* Specific methods                                                                     */
    /*                                                                                      */
    /****************************************************************************************/

}
