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

package hemera;

/**
 * Hemera - Intelligent System General Hemera exception.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 1.0.0
 */
public class HemeraException extends Exception {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constants */
	/*                                                                                      */
	/****************************************************************************************/

	private static final long serialVersionUID = -763585387153528066L;

	/****************************************************************************************/
	/*                                                                                      */
	/* Constructors */
	/*                                                                                      */
	/****************************************************************************************/

	/**
	 * Constructor.
	 */
	public HemeraException() {
		super();
	}

	/**
	 * Constructor.
	 * 
	 * @param message
	 */
	public HemeraException(String message) {
		super(message);
	}

	/**
	 * Constructor.
	 * 
	 * @param cause
	 */
	public HemeraException(Throwable cause) {
		super(cause);
	}

	/**
	 * Constructor.
	 * 
	 * @param message
	 * @param cause
	 */
	public HemeraException(String message, Throwable cause) {
		super(message, cause);
	}

}
