/*
 * Hemera - Intelligent System (https://github.com/bertrand-benoit/hemerais)
 * Copyright (C) 2010-2020 Bertrand Benoit <hemerais@bertrand-benoit.net>
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

package hemera;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Hemera - Intelligent System
 * Hemera specific class loader (allowing to configuration file automatically).
 * 
 * @author Bertrand Benoit <hemerais@bertrand-benoit.net>
 * @since 1.0.0
 */
public final class HemeraClassLoader extends ClassLoader {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constants */
	/*                                                                                      */
	/****************************************************************************************/

	/** Property allowing definition of properties file. */
	public static final String HEMERA_PROPERTIES_FILE_PROPERTY = "hemera.property.file";

	/** Hemera properties file. */
	public static final String HEMERA_PROPERTIES_FILE = System.getProperty(HEMERA_PROPERTIES_FILE_PROPERTY);

	/****************************************************************************************/
	/*                                                                                      */
	/* Attributes */
	/*                                                                                      */
	/****************************************************************************************/

	/****************************************************************************************/
	/*                                                                                      */
	/* Constructors */
	/*                                                                                      */
	/****************************************************************************************/

	/****************************************************************************************/
	/*                                                                                      */
	/* Constructors */
	/*                                                                                      */
	/****************************************************************************************/

	public HemeraClassLoader() {
		super();
		initialization();
	}

	public HemeraClassLoader(final ClassLoader parent) {
		super(parent);
		initialization();
	}

	/****************************************************************************************/
	/*                                                                                      */
	/* Specific methods */
	/*                                                                                      */
	/****************************************************************************************/

	/**
	 * Method initialization.
	 */
	private final void initialization() {
		if (HEMERA_PROPERTIES_FILE == null) {
			System.err.println("Warning: Hemera properties file '" + HEMERA_PROPERTIES_FILE_PROPERTY + "' is not defined.");
			return;
		}

		try {
			final File propertiesFile = new File(HEMERA_PROPERTIES_FILE);
			if (!propertiesFile.exists()) {
				System.err.println("Unable to find Hemera properties file '" + HEMERA_PROPERTIES_FILE + "'.");
				return;
			}

			// Load Hemera properties file.
			System.getProperties().load(new BufferedReader(new InputStreamReader(new FileInputStream(HEMERA_PROPERTIES_FILE))));
		} catch (final IOException e) {
			System.err.println("Failed loading Hemera properties file '" + HEMERA_PROPERTIES_FILE + "'.");
			e.printStackTrace();
		}
	}

}
