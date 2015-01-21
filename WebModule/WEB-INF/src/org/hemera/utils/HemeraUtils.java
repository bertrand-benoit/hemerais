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

package org.hemera.utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.NamingException;

import org.apache.log4j.Logger;

import com.opensymphony.xwork2.ActionContext;

/**
 * Hemera - Intelligent System
 * Utilities.
 * 
 * @author Bertrand Benoit <hemerais@bertrand-benoit.net>
 * @since 0.2
 */
public class HemeraUtils {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private static final Logger logger = Logger.getLogger("org.hemera.web");

    /** Hemera WebApp. */
    static String HEMERA_WEBAPP_ROOT = null;

    /** Hemera sysconfig file and installation directory. */
    static final String SYSCONFIG_FILE = "/etc/sysconfig/hemera";
    static String INSTALL_DIR = null;

    /** Hemera properties file. */
    static final String CONFIGURATION_FILE_SUBPATH = "config/hemera.conf";
    static Properties HEMERA_CONFIGURATION = null;

    /** Hemera ChangeLog. */
    static final String CHANGELOG_FILE_SUBPATH = "ChangeLog";

    /** Hemera run queue directory. */
    static final String HEMERA_RUNQUEUE_DIRECTORY = "run/queue/input";

    /****************************************************************************************/
    /*                                                                                      */
    /* Utilities methods: directories & configuration                                       */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return the root directory of this webApp (working in development mode, or in exploitation mode (as WAR file)).
     * @throws NamingException
     */
    public static final String getWebAppRoot() throws NamingException {
        // Checks if it has already been registered.
        if (HEMERA_WEBAPP_ROOT != null) {
            logger.debug("Giving already loaded Hemera WebApp root.");
            return HEMERA_WEBAPP_ROOT;
        }

        HEMERA_WEBAPP_ROOT = ((Context) ActionContext.getContext().getApplication().get("org.apache.catalina.resources")).getNameInNamespace();
        logger.info("Hemera WebApp root defined to '" + HEMERA_WEBAPP_ROOT + "'.");
        return HEMERA_WEBAPP_ROOT;
    }

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
        final File configurationFile = new File(installDir, CONFIGURATION_FILE_SUBPATH);
        final Properties properties = new OrderedProperties();

        // Adds some information.
        properties.put("hemera.installDir", installDir);

        logger.info("Opening configuration file '" + configurationFile + "'.");
        FileInputStream inputStream;
        try {
            inputStream = new FileInputStream(configurationFile);
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

    /****************************************************************************************/
    /*                                                                                      */
    /* Utilities methods: file contents                                                     */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @param path
     *            the path of the file whose contents is wanted.
     * @param formatSpaces
     *            <code>true</code> if spaces must be formatted as HTML spaces (&nbsp;), <code>false</code> otherwise.
     * @param formatEmails
     *            <code>true</code> if e-mail adresses must be formatted (mailto ...), <code>false</code> otherwise.
     * @return the contents of the file corresponding to specified path.
     */
    public static final Collection<String> getFileContent(final String path, final boolean formatSpaces, final boolean formatEmails) {
        final List<String> fileContents = new ArrayList<String>(64);
        logger.info("Opening file '" + path + "'.");
        FileInputStream inputStream;
        try {
            inputStream = new FileInputStream(path);
        }
        catch (final FileNotFoundException e) {
            throw new IllegalStateException("Unable to find specified file '" + path + "'.", e);
        }

        // Loads configuration as properties.
        try {
            final BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            while ((line = reader.readLine()) != null) {

                // N.B.: in case email format and space format is activated, we do NOT want that created
                //  <a> link is broken when formatting spaces just after; using temporary a special characters sequence
                //  which will be replaced just after space formatting.
                if (formatEmails && line.contains("@"))
                    line = line.replaceAll("[ ]([a-zA-Z][a-zA-Z ]*)[ ]<([a-zA-Z0-9.-]*@[a-zA-Z0-9.-]*)>", " <a€£href='mailto:$2'>$1</a> ");

                if (formatSpaces)
                    line = line.replaceAll(" ", "&nbsp;");

                if (formatEmails)
                    line = line.replaceAll("€£", " ");

                fileContents.add(line);
            }
        }
        catch (final Exception e) {
            throw new IllegalStateException("Unable to read specified file '" + path + "'.", e);
        }
        finally {
            try {
                inputStream.close();
            }
            catch (final IOException e) {
                throw new IllegalStateException("Unable to close specified file '" + path + "'.", e);
            }
        }

        logger.info("Successfully loaded file '" + path + "'.");
        return fileContents;
    }

    /**
     * @return the contents of changeLog.
     */
    public static final Collection<String> getChangeLogContents() {
        return getFileContent(getInstallDir() + "/" + CHANGELOG_FILE_SUBPATH, true, true);
    }

    /****************************************************************************************/
    /*                                                                                      */
    /* Utilities methods: input queue                                                       */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return the count of input in specified sub directory.
     */
    private static final int getInputCount(final String subDir, final FilenameFilter filter) {
        final File dir = new File(getInstallDir(), HEMERA_RUNQUEUE_DIRECTORY + "/" + subDir);
        // Ensures it exists (it won't be the case if Hemera is not started).
        if (!dir.exists())
            return 0;

        // Returns the count of input.
        final File[] files = dir.listFiles(filter);
        return files == null ? 0 : files.length;
    }

    /**
     * @return the count of input in new.
     */
    public static final int getNewInputCount() {
        return getInputCount("new", null);
    }

    /**
     * @return the count of input in error.
     */
    public static final int getErrorInputCount() {
        return getInputCount("err", null);
    }

    /**
     * @param type
     *            the type of input to count, among: speech, speech_recognitionResult, recognitionResult.
     * @return the count of specific input in cur.
     */
    public static final int getCurInputCount(final String type) {
        return getInputCount("cur", new FilenameFilter() {

            @Override
            public boolean accept(final File dir, final String name) {
                return name.startsWith(type);
            }
        });
    }

}
