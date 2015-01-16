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

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import javax.naming.NamingException;

import org.hemera.utils.HemeraUtils;

/**
 * Hemera - Intelligent System
 * Web Service license model.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 0.2
 */
public final class LicenseModel {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private final String tpLicenseName;

    /****************************************************************************************/
    /*                                                                                      */
    /* Constructor                                                                          */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @param tpLicenseName
     *            the name of the third-party tool whose license must be shown (<code>null</code> if none).
     */
    public LicenseModel(final String tpLicenseName) {
        super();
        this.tpLicenseName = tpLicenseName;
    }

    /****************************************************************************************/
    /*                                                                                      */
    /* Getters / Setters                                                                    */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return the name of license to show (<code>null</code> if none).
     */
    public final String getLicenseName() {
        return tpLicenseName;
    }

    /****************************************************************************************/
    /*                                                                                      */
    /* Specific methods                                                                     */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @param fileName
     *            the file name of the license.
     * @return the name of the corresponding third-party tool.
     */
    private static final String convertFileToName(final String fileName) {
        return fileName.replaceFirst("LICENSE-(.*)[.]txt", "$1");
    }

    /**
     * @param name
     *            the name of the third-party tool.
     * @return the file name of the corresponding license file.
     */
    private static final String convertNameToFile(final String name) {
        return "LICENSE-" + name + ".txt";
    }

    /**
     * @return the list of available licenses.
     * @throws NamingException
     */
    public final Collection<String> getLicenses() throws NamingException {
        final File webAppRoot = new File(HemeraUtils.getWebAppRoot());

        // Gets the list of available licenses.
        final String[] fileNames = webAppRoot.list(new FilenameFilter() {

            @Override
            public final boolean accept(final File dir, final String name) {
                return name.matches("LICENSE-.*.txt");
            }
        });

        final List<String> licenses = new ArrayList<String>(0);
        if (fileNames == null)
            return licenses;

        for (final String fileName : fileNames) {
            licenses.add(convertFileToName(fileName));
        }

        Collections.sort(licenses);
        return licenses;
    }

    /**
     * @return the contents of license to show.
     * @throws NamingException
     */
    public final Collection<String> getContents() throws NamingException {
        if (tpLicenseName == null)
            return new ArrayList<String>(0);

        final String fileName = convertNameToFile(tpLicenseName);
        return HemeraUtils.getFileContent(HemeraUtils.getWebAppRoot() + "/" + fileName, true, false);
    }

}
