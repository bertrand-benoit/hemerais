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

package org.hemera.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

import org.apache.log4j.Logger;

/**
 * Hemera - Intelligent System
 * Utilities.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 0.2
 */
public class HemeraUtils {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private static final Logger logger = Logger.getLogger("org.hemera.web");

    /** Hemera sysconfig file and installation directory. */
    static final String SYSCONFIG_FILE = "/etc/sysconfig/hemera";
    static String INSTALL_DIR = null;

    /** Hemera properties file. */
    static final String CONFIGURATION_FILE_SUBPATH = "config/hemera.conf";
    static Properties HEMERA_CONFIGURATION = null;

    /****************************************************************************************/
    /*                                                                                      */
    /* Utilities methods */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return Hemera installation directory.
     */
    public static final String getInstallDir() {
        // Checks if it has already been registered.
        if (INSTALL_DIR != null) {
            logger.debug("Giving already loaded Hemera installation directory.");
            return INSTALL_DIR;
        }

        // Opens the sysconfig file.
        logger.info("Opening sysconfig file '" + SYSCONFIG_FILE + "' to extract installation directory.");
        final Properties properties = new Properties();
        FileInputStream inputStream;
        try {
            inputStream = new FileInputStream(SYSCONFIG_FILE);
        }
        catch (final FileNotFoundException e) {
            throw new IllegalStateException("Unable to find Hemera sysconfig file '" + SYSCONFIG_FILE + "'. You must setup Hemera first.", e);
        }

        // Loads sysconfig as properties.
        try {
            properties.load(inputStream);
        }
        catch (final Exception e) {
            throw new IllegalStateException("Unable to load Hemera sysconfig file '" + SYSCONFIG_FILE + "'.", e);
        }
        finally {
            try {
                inputStream.close();
            }
            catch (final IOException e) {
                throw new IllegalStateException("Unable to close Hemera sysconfig file '" + SYSCONFIG_FILE + "'.", e);
            }
        }

        // Finally registers the Hemera installation directory.
        INSTALL_DIR = properties.getProperty("installDir").replaceAll("\"", "");
        logger.info("Installation directory defined to '" + INSTALL_DIR + "'.");
        return INSTALL_DIR;
    }

    /**
     * @return Hemera ChangeLog file path.
     */
    public static final String getChangeLogFilePath() {
        return getInstallDir() + "/ChangeLog";
    }

    /**
     * @return Hemera configuration as properties.
     */
    public static final Properties getConfiguration() {
        // Checks if it has already been registered.
        if (HEMERA_CONFIGURATION != null) {
            logger.debug("Giving already loaded Hemera configuration.");
            return HEMERA_CONFIGURATION;
        }

        // Opens the configuration file.
        final String installDir = getInstallDir();
        final File configuratioFile = new File(installDir, CONFIGURATION_FILE_SUBPATH);
        final Properties properties = new OrderedProperties();

        // Adds some information.
        properties.put("hemera.installDir", installDir);

        logger.info("Opening configuration file '" + configuratioFile + "'.");
        FileInputStream inputStream;
        try {
            inputStream = new FileInputStream(configuratioFile);
        }
        catch (final FileNotFoundException e) {
            throw new IllegalStateException("Unable to find Hemera configuration file '" + CONFIGURATION_FILE_SUBPATH + "'. You must configure Hemera first.", e);
        }

        // Loads configuration as properties.
        try {
            properties.load(inputStream);
        }
        catch (final Exception e) {
            throw new IllegalStateException("Unable to load Hemera configuration file '" + CONFIGURATION_FILE_SUBPATH + "'.", e);
        }
        finally {
            try {
                inputStream.close();
            }
            catch (final IOException e) {
                throw new IllegalStateException("Unable to close Hemera configuration file '" + CONFIGURATION_FILE_SUBPATH + "'.", e);
            }
        }

        // It is fully loaded, registers it.
        logger.info("Hemera configuration file successfully loaded.");
        HEMERA_CONFIGURATION = properties;
        return HEMERA_CONFIGURATION;
    }

}
